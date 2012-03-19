module Browsernizer

  class Browser

    attr_reader :name, :version

    def initialize(name, version)
      @name = name.to_s
      if version === false
        @version = false
      else
        @version = BrowserVersion.new version.to_s
      end
    end

    def meets?(requirement, version_check = :bigger_or_equal)
      if name.downcase == requirement.name.downcase
        if requirement.version === false
          false
        else
          case version_check
          when :bigger_or_equal
            version >= requirement.version
          when :equal
            version == requirement.version
          when :smaller_or_equal
            version <= requirement.version
          when :bigger
            version > requirement.version
          when :smaller
            version < requirement.version
          end
        end
      else
        nil
      end
    end

  end

end
