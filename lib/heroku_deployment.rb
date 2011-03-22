Dir["#{File.dirname(__FILE__)}/heroku_deployment/**/*.rb"].each {|f| require f}

module HerokuDeployment
  class Rails

    def initialize
      HerokuDeployment::Config.commit_files = []
    end

    def generate_css_and_js
      js_files = HerokuDeployment::Config.js_files
      css_files = HerokuDeployment::Config.css_files
      puts "Generating all the Javascripts and CSS as production"
      system %(rm #{(js_files.collect{|j| "public/javascripts/#{j}"} + css_files.collect{|c| "public/stylesheets/#{c}"}).join(" ")} 2> /dev/null)
      HerokuDeployment::Config.commit_files << 'public/javascripts/'
      HerokuDeployment::Config.commit_files << 'public/stylesheets/'
      res = !!system(%(RAILS_ENV=production ./script/rails runner "Rails.application.config.action_controller.perform_caching = false; require 'rails/console/app' ; app.get '#{HerokuDeployment::Config.generate_url}'"))
      HerokuDeployment::Config.commit_files.each do |f|
        unless File.exist?(f)
          puts "File '#{f}' did not get created! Deploy failed"
          return false
        end
      end
      res
    end

    def db_migrate
      system %(heroku rake db:migrate --app #{HerokuDeployment::Config.app})
    end

    def deploy
      HerokuDeployment::Git.push
      unless HerokuDeployment::Config.generate_url.to_s == ""
        raise "JS & CSS generation failed" unless generate_css_and_js
      end
      if HerokuDeployment::Config.compress_js
        HerokuDeployment::Config.js_files.each do |js|
          HerokuDeployment::Packer.compress_js("public/javascripts/#{js}")
        end
      end
      if HerokuDeployment::Config.compress_css
        HerokuDeployment::Config.css_files.each do |css|
          HerokuDeployment::Packer.compress_css("public/stylesheets/#{css}")
        end
      end
      HerokuDeployment::Git.commit
      if HerokuDeployment::Config.skip_push_to_heroku
        HerokuDeployment::Git.push_remote
        HerokuDeployment::Git.pull_remote
      end
      HerokuDeployment::Git.push
      HerokuDeployment::Git.pull
      db_migrate if HerokuDeployment::Config.migrate
      HerokuDeployment::Hoptoad.deployed! if HerokuDeployment::Config.hoptoad
    end

  end
end
