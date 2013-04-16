module Rokuby
  
  # This is a processor that takes SourceUnitInstances to build a doxyfile from it.
  class DoxygenBuilder < Processor
    def _InitProc
      @knownInputClasses.push(Rokuby::DoxygenConfiguration)
      @knownInputClasses.push(Rokuby::SourceUnitInstance)
    end
    
    def _ProcessInputs(taskArgs=nil)
      @inputs.each() do |fileSpec|
        
      end
    end
    
    
  end
  
end
