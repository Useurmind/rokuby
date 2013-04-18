module Rokuby
  
  # This is a processor that takes SourceUnitInstances to build a doxyfile from it.
  class DoxygenBuilder < ProcessChain
    
    def initialize(name=nil, app=nil, project_file=nil)
      super(name, app, project_file)
      
      @ProjectFinder = defineProc ProjectFinder, _GetProcessorName("ProjFinder")
      @DoxygenDocWriter = defineProc DoxygenDocWriter, _GetProcessorName("DoxyDocWriter")
      
      _ConnectProcessors()
    end
    
    def intialize_copy(original)
      super(original)
      @ProjectFinder = original.ProjectFinder
      @DoxygenDocWriter = original.DoxygenDocWriter
    end
    
    def AdaptName(newName)
      oldName = name()
      
      super(newName)
      
      projecFinderName = _AdaptProcessorName(newName, oldName, @ProjectFinder.to_s)
      doxygenDocWriterName = _AdaptProcessorName(newName, oldName, @DoxygenDocWriter.to_s)
      
      @ProjectFinder = @ChainProcessors[projecFinderName]
      @DoxygenDocWriter = @ChainProcessors[doxygenDocWriterName]
      
      _ConnectProcessors()
    end
    
    def _ConnectProcessors
      Connect(:in, @ProjectFinder.to_s, @DoxygenDocWriter.to_s, :out)
      Connect(:in, @DoxygenDocWriter.to_s)
    end
  end
  
end
