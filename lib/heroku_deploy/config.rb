module HerokuDeploy
  class Config
    @@remote = nil
    @@app = nil
    @@generate_url = nil
    class << self
      def setup &block
        yield self
      end

      [:app, :remote, :generate_url, :js_files, :css_files, :commit_files].each do |meth|
        eval %{
          def #{meth}
            @@#{meth}
          end
          def #{meth}=(val)
            @@#{meth} = val
          end
        }
      end

    end
  end
end