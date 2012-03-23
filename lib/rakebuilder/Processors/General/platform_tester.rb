module RakeBuilder
  module PlatformTester
    def TargetPlatforms=(val)
      @TargetPlatforms = val
    end

    def TargetPlatforms
      @TargetPlatforms
    end

    def initialize(*args)
      super(*args)

      @TargetPlatforms = []
    end
    
    def TargetedAtPlatform(platform)
      if(@TargetPlatforms.length == 0)
        return true
      end

      @TargetPlatforms.each() do |targetPlatform|
        if(targetPlatform <= platform)
          return true
        end
      end
      return false
    end

    def TargetedAtPlatforms(platforms)
      platforms.each() do |platform|
        if(TargetedAtPlatform(platform))
          return true
        end
      end
      return false
    end

    # Extend/set the attributes of the processor.
    def Extend(valueMap, executeParent=true)
      if(valueMap == nil)
        return
      end

      if(executeParent)
        super(valueMap)
      end

      targetPlatforms = valueMap[:TargetPlatforms] || valueMap[:targPlat]
      if(targetPlatforms)
        @TargetPlatforms.concat(targetPlatforms)
      end
    end
  end
end