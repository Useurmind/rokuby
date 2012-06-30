module Rokuby
  # This class finds all necessary parts for a project instance that is given
  # through a project specification.
  # Allowed inputs are ProjectSpecifications, SourceUnitSpecifications and
  # LibrarySpecifications.
  # Output is one ProjectInstance that contains all the gathered information.
  class ProjectFinder < ProcessChain
    include PlatformTester
    
    attr_reader :ProjSplitter
    attr_reader :SuFinder
    attr_reader :LibFinder
    attr_reader :ProjJoiner
    
    def initialize(name=nil, app=nil, project_file=nil)
      super(name, app, project_file)
      
      @ProjSplitter =  defineProc ProjectSplitter, _GetProcessorName("Splitter")
      @SuFinder = defineProc SourceUnitFinder, _GetProcessorName("SuFinder")
      @LibFinder = defineProc LibraryFinder, _GetProcessorName("LibFinder")
      @ProjJoiner = defineProc ProjectJoiner, _GetProcessorName("Joiner")
      
      _ConnectProcessors()
    end
    
    def intialize_copy(original)
      super(original)
      @ProjSplitter = original.ProjSplitter
      @SuFinder = original.SuFinder
      @LibFinder = original.LibFinder
      @ProjJoiner = original.ProjJoiner
    end
    
    def AdaptName(newName)
      oldName = name()
      
      super(newName)
      
      projSplitterName = _AdaptProcessorName(newName, oldName, @ProjSplitter.to_s)
      suFinderName = _AdaptProcessorName(newName, oldName, @SuFinder.to_s)
      libFinderName = _AdaptProcessorName(newName, oldName, @LibFinder.to_s)
      projJoinerName = _AdaptProcessorName(newName, oldName, @ProjJoiner.to_s)
      
      @ProjSplitter = @ChainProcessors[projSplitterName]
      @SuFinder = @ChainProcessors[suFinderName]
      @LibFinder = @ChainProcessors[libFinderName]
      @ProjJoiner = @ChainProcessors[projJoinerName]
      
      _ConnectProcessors()
    end
    
    def _ConnectProcessors
      Connect(:in, @ProjSplitter.to_s)
      Connect(@ProjSplitter.to_s, @LibFinder.to_s, @ProjJoiner.to_s)
      Connect(@ProjSplitter.to_s, @SuFinder.to_s, @ProjJoiner.to_s)
      Connect(@ProjJoiner.to_s, :out)
    end
    
    def _InitProc
      @knownInputClasses.push(Rokuby::ProjectSpecification)
      @knownInputClasses.push(Rokuby::SourceUnitSpecification)
      @knownInputClasses.push(Rokuby::LibrarySpecification)
    end
  end
end
