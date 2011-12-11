module RakeBuilder
  
  # A class that is meant to find the different configurations of libraries on the system.
  # Input values to this processor are LibrarySpecifications.
  # Outputs are the found libraries in form of Library instances.
  class LibraryFinder < Processor
    include FindFile
    
    def initialize(name)
      super(name)
      
      @knownInputClasses.push(RakeBuilder::LibrarySpecification)
    end
    
    def _ProcessInputs
      libraries = {}
      
      @inputs.each() do |libSpec|
        library = libraries[libSpec.Name]
        if(!library)
          library = Library.new()
        end
        
        libInstance = LibraryInstance.new()
        libInstance.GetDefines(libSpec)        
        libInstance.Platform = libSpec.Platform
        
        libInstance.FileSet.LibraryFileSet = FindFile(libSpec.LibraryLocation.LibFileSpec)
        libInstance.FileSet.LinkFileSet = FindFile(libSpec.LibraryLocation.LinkFileSpec)
        libInstance.FileSet.IncludeFileSet = FindFile(libSpec.LibraryLocation.IncludeFileSpec)
        
        library.AddInstance(libInstance)
      end
      
      libraries.each()do |name, lib|
        @outputs.push(lib)
      end
    end
  end
end
