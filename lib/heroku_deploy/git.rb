module HerokuDeploy
  class Git
    class < self
      def current_version
        `git show HEAD | head -n 1`.split(" ").last.strip
      end
      
      def push
        system %(git push >/dev/null 2>&1)
      end
    end
  end
end