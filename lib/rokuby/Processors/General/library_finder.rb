module Rokuby
  
  # A class that is meant to find the different configurations of libraries on the system.
  # Input values to this processor are LibrarySpecifications or LibrarySpecificationSets.
  # Outputs are the found libraries in form of Libraries.
  class LibraryFinder < Processor
    include FindFile
    include PlatformTester
    
    def _InitProc
      if(!Rake.application.options.no_cache && !Rake.application.options.no_lib_cache)
        @UseCache = true
      end
      @knownInputClasses.push(Rokuby::LibrarySpecification)
      @knownInputClasses.push(Rokuby::LibrarySpecificationSet)
    end
    
    def _SortInputs
      @libSpecs = []
      @inputs.each() do |input|
        if(input.is_a?(Rokuby::LibrarySpecification))
          @libSpecs.push(input)
        elsif(input.is_a?(Rokuby::LibrarySpecificationSet))
          @libSpecs += input.Specifications
        end
      end
    end
    
    def _ProcessInputs(taskArgs=nil)
      libraries = {}
      
      #puts "Searching libraries..."
      
      _SortInputs()
      
      @libSpecs.each() do |libSpec|
        if(!TargetedAtPlatforms(libSpec.Platforms))
          next
        end
        
        #puts "Library spec is #{[libSpec]}"
        
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
        
        
        #puts "Library instance is #{[libInstance]}"
        
        library.AddInstance(libInstance)
        #puts "Found library instance: #{[libInstance]}"
      end
      
      libraries.each()do |name, lib|
        #puts "Pushing library #{[lib]} to output of lib finder."
        @outputs.push(lib)
      end
    end
  end
end
