module Rokuby
  # Simple Processor whose output is his input.
  class PassthroughProcessor < Processor    
    def _InitProc
      # knows everything per implementation of _InputKnown
    end
    
    def _InputKnown(input)
      return true
    end
    
    def _ProcessInputs(taskArgs=nil)
      @outputs = @inputs
    end
  end
end
