module Rokuby
  # This information unit can be used to change the behaviour of how a project is
  # reused in another project as a dependency.
  # [Guid] The guid of the project to which this usage should be applied (only needed if it is input to the preprocessor).
  class VsProjectUsage < InformationUnit
    attr_accessor :Guid
    attr_accessor :Private
    attr_accessor :ReferenceOutputAssembly
    attr_accessor :CopyLocalSatelliteAssemblies
    attr_accessor :LinkLibraryDependencies
    attr_accessor :UseLibraryDependencyInputs
    
    def initialize(valueMap=nil)
      @Guid = nil
      @Private = nil
      @ReferenceOutputAssembly = nil
      @CopyLocalSatelliteAssemblies = nil
      @LinkLibraryDependencies = nil
      @UseLibraryDependencyInputs = nil
      
      super(valueMap)
      
      Extend(valueMap, false)
    end
    
    def initialize_copy(original)
      super(original)
      
      @Guid = Clone(original.Guid)
      @Private = Clone(original.Private)
      @ReferenceOutputAssembly = Clone(original.ReferenceOutputAssembly)
      @CopyLocalSatelliteAssemblies = Clone(original.CopyLocalSatelliteAssemblies)
      @LinkLibraryDependencies = Clone(original.LinkLibraryDependencies)
      @UseLibraryDependencyInputs = Clone(original.UseLibraryDependencyInputs)
    end
    
    def Extend(valueMap, callParent=true)
      if(valueMap == nil)
        return
      end
      
      if(callParent)
        super(valueMap)
      end
      
      private = valueMap[:Private] || valueMap[:priv]
      if(private != nil)
        @Private = private
      end
      
      referenceOutputAssembly = valueMap[:ReferenceOutputAssembly] || valueMap[:refOutput]
      if(referenceOutputAssembly != nil)
        @ReferenceOutputAssembly = referenceOutputAssembly
      end
      
      copyLocalSatelliteAssemblies = valueMap[:CopyLocalSatelliteAssemblies] || valueMap[:copyLocal]
      if(copyLocalSatelliteAssemblies != nil)
        @CopyLocalSatelliteAssemblies = copyLocalSatelliteAssemblies
      end
      
      linkLibraryDependencies = valueMap[:LinkLibraryDependencies] || valueMap[:linkLibs]
      if(linkLibraryDependencies != nil)
        @LinkLibraryDependencies = linkLibraryDependencies
      end
      
      useLibraryDependencyInputs = valueMap[:UseLibraryDependencyInputs] || valueMap[:useLibInputs]
      if(useLibraryDependencyInputs != nil)
        @UseLibraryDependencyInputs = useLibraryDependencyInputs
      end
      
      guid = valueMap[:Guid] || valueMap[:guid]
      if(guid != nil)
        @Guid = guid
      end
    end
  end
end
