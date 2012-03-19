module RakeBuilder
  # Simple Processor whose output is his input.
  class PassthroughProcessor < Processor
    def initialize(name=nil, app=nil, projectFile=nil)
      super(name, app, projectFile)
    end
    
    def _InputKnown(input)
      return true
    end
    
    def _ProcessInputs
      @outputs = @inputs
    end
  end
end
