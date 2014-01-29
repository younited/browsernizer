module Browsernizer

  class Router
    attr_reader :config

    def initialize(app, &block)
      @app = app
      @config = Config.new
      yield(@config)
    end

    def call(env)
      raw_browser, browser = get_browsers(env)
      env["browsernizer"] = {
        "supported" => supported?(raw_browser, browser),
        "status"  => get_browser_status(raw_browser, browser),
        "browser" => browser.name.to_s,
        "version" => browser.version.to_s
      }
      redirect_request(env) || @app.call(env)
    end

  private

    def redirect_request(env)
      return if path_excluded?(env)
      if env["browsernizer"]["status"] == :unsupported
        return redirect_to_specified if @config.get_location && !on_redirection_path?(env)
      elsif on_redirection_path?(env)
        return redirect_to_root
      end
    end

    def redirect_to_specified
      [307, {"Content-Type" => "text/plain", "Location" => @config.get_location}, []]
    end

    def redirect_to_root
      [303, {"Content-Type" => "text/plain", "Location" => "/"}, []]
    end

    def path_excluded?(env)
      @config.excluded? env["PATH_INFO"]
    end

    def on_redirection_path?(env)
      @config.get_location && @config.get_location == env["PATH_INFO"]
    end

    def get_browsers(env)
      raw_browser = ::Browser.new :ua => env["HTTP_USER_AGENT"]
      browser = Browsernizer::Browser.new raw_browser.name.to_s, raw_browser.full_version.to_s
      [raw_browser, browser]
    end

    def get_browser_status(raw_browser, browser)
      return :unsupported unless supported?(raw_browser, browser)
      return :deprecated if deprecated?(raw_browser, browser)
      return custom_status(raw_browser, browser) || :supported
    end

    # supported by default
    def supported?(raw_browser, browser)
      !@config.get_by_status(:supported).any? do |requirement|
        supported = if requirement.respond_to?(:call)
          requirement.call(raw_browser)
        else
          browser.meets?(requirement)
        end
        supported === false
      end
    end

    # deprecated if version equals or is lower
    def deprecated?(raw_browser, browser)
      @config.get_by_status(:deprecated).any? do |requirement|
        if requirement.respond_to?(:call)
          requirement.call(raw_browser)
        else
          browser.meets?(requirement, :smaller_or_equal)
        end
        supported === true
      end
    end

    # check if a custom status is set on the browser
    def custom_status(raw_browser, browser)
      return nil if @config.get_by_status.empty?
      @config.get_by_status.reject{|k, _| [:deprecated, :supported].include?(k) }.each do |status, requirements|
        requirements.each do |requirement|
          supported = if requirement.respond_to?(:call)
            requirement.call(raw_browser, :smaller_or_equal)
          else
            browser.meets?(requirement)
          end
          return status if supported === true
        end
      end
      nil
    end

  end

end
