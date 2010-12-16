module HerokuDeployment
  class Hoptoad
    class << self
      def deployed!
        system %(rake hoptoad:deploy TO=production REVISION=#{HerokuDeployment::Git.current_version} REPO=#{HerokuDeployment::Config.app} USER=$USER)
      end
    end
  end
end