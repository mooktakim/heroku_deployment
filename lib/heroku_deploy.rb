require 'heroku_deploy/config'
require 'heroku_deploy/hoptoad'
require 'heroku_deploy/packer'
require 'heroku_deploy/git'

module HerokuDeploy
  class Rails
    
    attr_reader :commit_files, :result, :css_files, :js_files

    def generate_css_and_js
      puts "Generating all the Javascripts and CSS as production"
      # system %(rm #{(js_files.collect{|j| "public/javascripts/#{j}"} + css_files.collect{|c| "public/stylesheets/#{c}"}).join(" ")} 2> /dev/null)
      @commit_files << 'public/javascripts/'
      @commit_files << 'public/stylesheets/'
      @result = !!system(%(RAILS_ENV=production ./script/rails runner "require 'rails/console/app' ; app.get '#{HerokuDeploy::Config.generate_url}'"))
    end
    
    def db_migrate
      system %(heroku rake db:migrate --app #{HerokuDeploy::Config.app})
    end

    def deploy
      raise [HerokuDeploy::Config.app, HerokuDeploy::Config.remote].inspect
      HerokuDeploy::Git.push
      generate_css_and_js
      raise "JS & CSS generation failed" unless result
      js_files.each do |js|
        HerokuDeploy::Packer.compress_js("public/javascripts/#{js}")
      end
      css_files.each do |css|
        HerokuDeploy::Packer.compress_css("public/stylesheets/#{css}")
      end
      HerokuDeploy::Git.commit(commit_files)
      HerokuDeploy::Git.push_remote
      HerokuDeploy::Git.pull_remote
      HerokuDeploy::Git.push
      HerokuDeploy::Git.pull
      db_migrate
      HerokuDeploy::Hoptoad.deployed!
    end

  end
end