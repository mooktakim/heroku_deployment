module HerokuDeploy
  class Hoptoad
    class < self
      def deployed!
        system %(rake hoptoad:deploy TO=production REVISION=#{HerokuDeploy::Git.current_version} REPO=#{HerokuDeploy::Config.app} USER=$USER)
      end
    end
  end
end