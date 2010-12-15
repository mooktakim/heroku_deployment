module HerokuDeploy
  class Git
    class < self
      def current_version
        `git show HEAD | head -n 1`.split(" ").last.strip
      end
    end
  end
end