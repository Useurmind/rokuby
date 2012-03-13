module RakeBuilder
  # A class to manage the processor structure.
  # A process chain is a directed graph structure of processors that are connected and
  # propagate their outputs to the next processors in the graph.
  class ProcessChain < Processor
    attr_accessor :InputProcessor
    attr_accessor :OutputProcessor
    
    def initialize(name)
      super(name)
      @processors = []
      @processorInputs = {}
      @InputProcessor = "#{@Name}_in"
      @OutputProcessor = "#{@Name}_out"
      AddProcessor(@InputProcessor)
      AddProcessor(@OutputProcessor)
    end
    
    def _InputKnown(input)
      return true
    end
    
    def _ProcessInputs
      @InputProcessor.AddInput(@inputs)
      @OutputProcessor.Process()
      @outputs = @OutputProcessor.Outputs()
    end
    
    # Add a processor to this process chain.
    def AddProcessor(procName)
      if(@processors[procName] == nil)
        prerequisites.push(procName)
      end
    end
    
    # State that the first processor should be input processor to the second
    # processor.
    def Connect(*args)
      if(args.length == 0)
        return
      end
      
      procNames = args
      if(args[0].respond_to?("length"))
        procNames = args[0]
      end
      
      lastProcName = nil
      procNames.each() do |procName|
        if(lastProcName)
          Rake::DSL::task procName => [lastProcName]
        end
        lastProcName = procName
      end      
    end
  end
end
