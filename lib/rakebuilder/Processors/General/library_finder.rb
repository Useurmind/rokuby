module RakeBuilder
  
  # A class that is meant to find the different configurations of libraries on the system.
  # Input values to this processor are LibrarySpecifications.
  # Outputs are the found libraries in form of Library instances.
  class LibraryFinder < Processor
    include FindFile
    include PlatformTester
    
    def initialize(name=nil, app=nil, project_file=nil)
      super(name, app, project_file)
      
      @knownInputClasses.push(RakeBuilder::LibrarySpecification)
    end
    
    def _ProcessInputs(taskArgs=nil)
      libraries = {}
      
      @inputs.each() do |libSpec|
        if(!TargetedAtPlatforms(libSpec.Platforms))
          next
        end
        
        library = libraries[libSpec.Name]
        if(!library)
          library = Library.new()
          library.Name = libSpec.Name
          libraries[libSpec.Name] = library
        end
        
        libInstance = LibraryInstance.new()
        libInstance.AddDefinesFrom(libSpec)        
        libInstance.Platforms = libSpec.Platforms
        
        libInstance.FileSet.LibraryFileSet = FindFile(libSpec.Location.LibraryFileSpec)
        libInstance.FileSet.LinkFileSet = FindFile(libSpec.Location.LinkFileSpec)
        libInstance.FileSet.IncludeFileSet = FindFile(libSpec.Location.IncludeFileSpec)
        
        library.AddInstance(libInstance)
        #puts "Found library instance: #{[libInstance]}"
      end
      
      libraries.each()do |name, lib|
        @outputs.push(lib)
      end
    end
  end
end
