module Rokuby
  
  # Represents a library and includes information concerning all found instances of it on this system.
  # When searching for an instance of a library based on a platform, the last version that was added is chosen.
  # [Name] The name of the library that is represented by this container.
  # [instances] The instances of the library that were found.
  class Library < InformationUnit
    attr_accessor :Name
    
    def initialize(valueMap=nil)
      super(valueMap)
      @instances = []
      @Name = nil
      Extend(valueMap, false)
    end
    
    def initialize_copy(original)
      super(original)
      @instances = Clone(original.GetInstances(nil))
    end
    
    def AddInstance(instance)
      @instances.push(instance)
    end
    
    def GetInstance(platform)
      instances = GetInstances(platform)
      if(instances.length > 0)
        return instances[instances.length-1]
      end
      return nil
    end
    
    # Get all library instances that belong to this platform.
    # [platform] The platform for which we need the library (nil for all instances).
    def GetInstances(platform)      
      matchingInstances = []
      
      if(!platform)
        return @instances
      end
      
      @instances.each do |instance|
        instance.Platforms.each() do |instPlat|
          if(instPlat <= platform)
            matchingInstances.push(instance)
            break
          end          
        end        
      end
      
      return matchingInstances
    end
    
    # Get the name of the library file that should be used on this platform.
    def LibraryFileName(platform)
      matchingInstances = GetInstances(platform)
      if(matchingInstances.length() == 0)
        return nil
      end
      
      return matchingInstances[matchingInstances.length()-1].LibraryFileName()
    end
    
    # Get the name of the file that should be linked under on this platform.
    def LinkFileName(platform)
      matchingInstances = GetInstances(platform)
      if(matchingInstances.length() == 0)
        return nil
      end
      
      return matchingInstances[matchingInstances.length()-1].LinkFileName()
    end
    
    def Extend(valueMap, callParent=true)
      if(valueMap == nil)
        return
      end
      
      if(callParent)
        super(valueMap)
      end
      
      name = valueMap[:Name] || valueMap[:name]
      if(name)
        @Name = name
      end
      
      instances = valueMap[:Instances] || valueMap[:insts]
      if(instances)
        instances.each() do |inst|
          AddInstance(inst)
        end
      end
    end
  end
  
end
