module RakeBuilder
  # This class is able to cache the outputs of the different processors to
  # improve the speed of project building.
  class ProcessCache
    attr_accessor :CacheFilePath
    
    def initialize(cacheFilePath)
      @CacheFilePath = cacheFilePath
      
      @CacheObject = nil
    end
    
    def exist?
      return (@CacheFilePath != nil and @CacheFilePath.exist?() and @CacheFilePath.file?())
    end
    
    def Save
      if(Rake.application.options.trace)
        $stderr.puts "** Saving cache to #{@CacheFilePath}..."
      end
      File.open(@CacheFilePath.AbsolutePath(), "w") do |f|
        f.write(YAML::dump(@CacheObject))
      end
    end
    
    def _GetCacheObject
      if(!@CacheObject)
        _LoadCacheObject()
      end
      return @CacheObject
    end
    
    def _LoadCacheObject
      if(exist?())
        if(Rake.application.options.trace)
          $stderr.puts "** Loading cache from #{@CacheFilePath}..."
        end
        @CacheObject = YAML::load(File.open(@CacheFilePath.AbsolutePath()))
      end
      
      if(!@CacheObject)
        @CacheObject = {}
      end
    end
    
    def UpdateProcessorCache(processor)
      _GetCacheObject()[processor.to_s().to_sym()] = Clone(processor.Outputs)
    end
    
    def GetProcessorCache(processor)
      return _GetCacheObject()[processor.to_s().to_sym()]
    end
  end
end
