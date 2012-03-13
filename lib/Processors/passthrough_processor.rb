module RakeBuilder
  # Simple Processor whose output is his input.
  class PassthroughProcessor < Processor
    def initialize(name)
      super(name)
    end
    
    def _InputKnown(input)
      return true
    end
    
    def _ProcessInputs
      @outputs = @inputs
    end
  end
end
