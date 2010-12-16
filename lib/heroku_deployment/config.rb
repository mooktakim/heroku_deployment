module HerokuDeployment
  class Config
    class << self
      def setup &block
        yield self
      end

      [:app, :remote, :generate_url, :js_files, :css_files, :commit_files, :compress_js, :compress_css, :migrate, :hoptoad].each do |meth|
        class_eval <<-END
          @@#{meth} = nil
          def #{meth}
            @@#{meth}
          end
          def #{meth}=(val)
            @@#{meth} = val
          end
        END
      end

    end
  end
end