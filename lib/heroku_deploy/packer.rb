require "yui/compressor"

module HerokuDeploy
  class Packer
    
    class < self
      def compress_js(file)
        new(file, :js).compress
      end
      
      def compress_css(file)
        new(file, :css).compress
      end
    end
    
    attr_reader :file, :compressor
    
    def initialize(f, t)
      @file = f
      if t == :js
        @compressor = YUI::JavaScriptCompressor.new(:munge => true)
      elsif t == :css
        @compressor = YUI::CssCompressor.new
      else
        raise "File type '#{t}' is not supported"
      end
    end

    def compress
      compressed_content = compressor.compress(readfile)
      writefile(compressed_content)
    end
    
    private

    def readfile
      f = File.open(file, "r")
      content = f.readlines.join("\n")
      f.close
      content
    end
    
    def writefile(content)
      f = File.open(file, "w")
      f.write(content)
      f.close
    end

  end
end