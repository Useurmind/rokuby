module RakeBuilder
  
  # Represents a library and includes information concerning all found instances of it on this system.
  # [Name] The name of the library that is represented by this container.
  # [instances] The instances of the library that were found.
  class Library < InformationUnit
    attr_accessor :Name
    
    def initialize(valueMap=nil)
      super(valueMap)
      @instances = []
      Extend(valueMap, false)
    end
    
    def initialize_copy(original)
      super(original)
      @instances = Clone(original.instances)
    end
    
    def AddInstance(instance)
      @instances.push(instance)
    end
    
    # Get all library that belong to this platform.
    # [platform] The platform for which we need the library.
    def GetInstances(platform)      
      matchingInstances = []
      
      @instances.each do |instance|
        if(platform.eql?(instance.Configuration.Platform))
          matchingInstances.push(instance)
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
      
      return matchingInstances[0].LibraryFileName()
    end
    
    # Get the name of the file that should be linked under on this platform.
    def LinkFileName(platform)
      matchingInstances = GetInstances(platform)
      if(matchingInstances.length() == 0)
        return nil
      end
      
      return matchingInstances[0].LinkFileName()
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