module RakeBuilder
  
  # A set of representations for the libraries for different configurations.
  # Input Values:
  # [Name] The name of the library that is represented by this container.
  # [Libraries] The representations for the library defined in this container.
  # Output Values:
  # The output values of the different libraries.
  # All getters use a specific input parameter bag which states the configuration for which
  # the value should be retrieved. 
  # If the configuration is not supported the next lower level configuration is used.
  # They return nil if no valid configuration can be found.
  # [os] The OS for which the library representation is meant.
  # [arch] The architecture for which the library representation is meant.
  # [conf] The configuration for which the library representation is meant.
  class LibraryContainer < SystemInformationSet
    attr_accessor :Name
    
    def initialize
      @libraries = {}
    end   
    
    def initialize_copy(original)
      @libraries = Clone(original.libraries)
    end
    
    # Add a representation for a certain system configuration.
    # The configuration can be gradualy defined.
    # Highest level is the OS for which the library is compiled. Second level is
    # the architecture and third level is the configuration.
    # [os] The OS for which the library representation is meant.
    # [arch] The architecture for which the library representation is meant.
    # [conf] The configuration for which the library representation is meant.
    # [lib] The library representation to add.
    def AddRepresentation(paramBag)
      os = paramBag[:os] or ""
      arch = paramBag[:arch] or ""
      conf = paramBag[:conf] or ""
      
      representationKey = os + arch + conf
      
      @libraries[representationKey] = paramBag[:lib]
    end
    
    # Get a representation for a certain system configuration.
    # See class comment on getters.
    def GetRepresentation(conf)
      os = paramBag[:os] or ""
      arch = paramBag[:arch] or ""
      conf = paramBag[:conf] or ""
      
      representationKey = os + arch + conf
      if(@libraries[representationKey])
        return @libraries[representationKey]
      end
      
      representationKey = os + arch
      if(@libraries[representationKey])
        return @libraries[representationKey]
      end
      
      representationKey = os
      if(@libraries[representationKey])
        return @libraries[representationKey]
      end
      
      return nil
    end
    
    # Get the name of the file that should be linked under this configuration.
    def GetLibraryFileName(conf)
      rep = GetRepresentation(conf)
      if(!rep)
        return nil
      end
      
      return rep.LibraryFileName()
    end
    
    # Get the name of the file that should be linked under this configuration.
    def GetLinkFileName(conf)
      rep = GetRepresentation(conf)
      if(!rep)
        return nil
      end
      
      return rep.LinkFileName()
    end
    
    # Fill the file sets that will contain the library and include files.
    def Fill
      @LibraryFileSet.Fill()
      @IncludeFileSet.Fill()
    end
  end
  
end