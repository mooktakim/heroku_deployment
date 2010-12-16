Dir["#{File.dirname(__FILE__)}/heroku_deploy/**/*.rb"].each {|f| require f}

module HerokuDeploy
  class Rails
    
    def initialize
      HerokuDeploy::Config.commit_files = []
    end

    def generate_css_and_js
      puts "Generating all the Javascripts and CSS as production"
      # system %(rm #{(js_files.collect{|j| "public/javascripts/#{j}"} + css_files.collect{|c| "public/stylesheets/#{c}"}).join(" ")} 2> /dev/null)
      HerokuDeploy::Config.commit_files << 'public/javascripts/'
      HerokuDeploy::Config.commit_files << 'public/stylesheets/'
      !!system(%(RAILS_ENV=production ./script/rails runner "require 'rails/console/app' ; app.get '#{HerokuDeploy::Config.generate_url}'"))
    end
    
    def db_migrate
      system %(heroku rake db:migrate --app #{HerokuDeploy::Config.app})
    end

    def deploy
      HerokuDeploy::Git.push
      unless HerokuDeploy::Config.generate_url.to_s == ""
        raise "JS & CSS generation failed" unless generate_css_and_js
      end
      if HerokuDeploy::Config.compress_js
        HerokuDeploy::Config.js_files.each do |js|
          HerokuDeploy::Packer.compress_js("public/javascripts/#{js}")
        end
      end
      if HerokuDeploy::Config.compress_css
        HerokuDeploy::Config.css_files.each do |css|
          HerokuDeploy::Packer.compress_css("public/stylesheets/#{css}")
        end
      end
      HerokuDeploy::Git.commit
      HerokuDeploy::Git.push_remote
      HerokuDeploy::Git.pull_remote
      HerokuDeploy::Git.push
      HerokuDeploy::Git.pull
      db_migrate if HerokuDeploy::Config.migrate
      HerokuDeploy::Hoptoad.deployed! if HerokuDeploy::Config.hoptoad
    end

  end
end