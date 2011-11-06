module RakeBuilder
  
  # Represents a library and delivers the right library for each configuration.
  # Input Values:
  # [Name] The name of the library that is represented by this container.
  # [Configurations] The different configurations for the library.
  # Output Values:
  # The output values of the different libraries.
  # All getters use a specific input parameter bag which states the configuration for which
  # the value should be retrieved. 
  # If the configuration is not supported the next lower level configuration is used.
  # They return nil if no valid configuration can be found.
  class Library
    attr_accessor :Name
    
    def initialize
      @configurations = []
    end   
    
    def initialize_copy(original)
      @configurations = Clone(original.configurations)
    end
    
    # Add a configuration for a certain system configuration.
    # [lib] The library configuration to add.
    def AddConfiguration(lib)      
      @configurations.push(lib)
    end
    
    # Get all configurations that match the description in the parameter bag.
    # If exact is not set to true attributes can be ignored and a list sorted
    # by the best matches is returned. The best match is determined on which attributes
    # match. Id is most important, conf least important.
    # See class comment on getters.
    # [id] The id of a specific configuration that should be used.
    # [os] The os that should be supported by the library.
    # [arch] The cpu architecture that should be supported by the library.
    # [conf] The type of configuration that should be supported by the library.
    # [exact] Delivers only exact matches (default false).
    def GetConfigurations(conf)
      id = paramBag[:id] || nil
      os = paramBag[:os] || nil
      arch = paramBag[:arch] || nil
      conf = paramBag[:conf] || nil
      exact = paramBag[:exact] || false
      
      matchPoints = [] # a list of point values for the best matches id: 8, os: 4, arch: 2, conf:1
      matchingConfiguration = []
      
      @configurations.each do |configuration|
        matchId = id == nil || configuration.Id == id
        matchOs = os == nil || configuration.Os == os
        matchArch = arch == nil || configuration.Architecture == arch
        matchConf = conf == nil || configuration.Configuration == conf
        matchExact = !exact || matchId && matchOs && matchArch && matchConf
        if(matchExact && (matchId || matchOs || matchArch || matchConf))
          matchingConfiguration.push(configuration)
          points = 0
          points += matchId ? 8 : 0
          points += matchOs ? 4 : 0
          points += matchArch ? 2 : 0
          points += matchConf ? 1 : 0
          matchPoints.push(points)
        end
      end
      
      return matches
    end
    
    # Get the name of the file that should be linked under this configuration.
    def LibraryFileName(conf)
      rep = GetConfigurations(conf)
      if(!rep)
        return nil
      end
      
      return rep.LibraryFileName()
    end
    
    # Get the name of the file that should be linked under this configuration.
    def LinkFileName(conf)
      rep = GetConfigurations(conf)
      if(!rep)
        return nil
      end
      
      return rep.LinkFileName()
    end
    
    def Library(representationKey)
      lib = @libraries[representationKey]
      if(lib)
        lib.Fill()
      end
      return lib
    end
  end
  
end