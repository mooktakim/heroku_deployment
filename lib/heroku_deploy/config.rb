module HerokuDeploy
  class Config
    class < self
      def remote
        "heroku"
      end
      
      def app
        "restlessbeings"
      end
    end
  end
end