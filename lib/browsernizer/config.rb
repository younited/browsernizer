module Browsernizer
  class Config

    def initialize
      @statusses = Hash.new {|hash, key| hash[key] = [] }
      @location = nil
      @exclusions = []
      @handler = lambda { }
    end

    def supported(*args, &block)
      status(:supported, *args, &block)
    end

    def deprecated(browser, version)
      status(:deprecated, *args, &block)
    end

    def status(status, *args, &block)
      if args.length == 2
        @statusses[status] << Browser.new(args[0], args[1])
      elsif block_given?
        @statusses[status] << block
      else
        raise ArgumentError, "accepts either (browser, version) or block"
      end
    end

    def location(path)
      @location = path
    end

    def exclude(path)
      @exclusions << path
    end

    def get_supported
      get_by_status :supported
    end

    def get_by_status(status = nil)
      return @statusses if status.nil?
      @statusses[status]
    end

    def get_location
      @location
    end

    def excluded?(path)
      @exclusions.any? do |exclusion|
        case exclusion
        when String
          exclusion == path
        when Regexp
          exclusion =~ path
        end
      end
    end

  end
end
