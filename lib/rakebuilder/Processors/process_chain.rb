module RakeBuilder
  # A class to manage the processor structure.
  # A process chain is a directed graph structure of processors that are connected and
  # propagate their outputs to the next processors in the graph.
  class ProcessChain < Processor
    include RakeBuilder::DSL
    
    attr_reader :InputProcessorName
    attr_reader :OutputProcessorName
    attr_reader :InputProcessor
    attr_reader :OutputProcessor    
    
    alias initialize_processor initialize    
    def initialize(name=nil, app=nil, projectFile=nil)
      initialize_processor(name, app, projectFile)
      @InputProcessorName = "#{@Name}_in"
      @OutputProcessorName = "#{@Name}_out"
      
      @InputProcessor = defineProc PassthroughProcessor, @InputProcessorName
      @OutputProcessor = defineProc PassthroughProcessor, @OutputProcessorName
      
      AddProcessor(@OutputProcessorName)
    end
    
    def _InputKnown(input)
      return true
    end
    
    def _ProcessInputs
      OutputProcessor().Process()
      @outputs = OutputProcessor().Outputs()
    end
    
    # Add a processor to this process chain.
    def AddProcessor(procName)
      if(!prerequisites.include?(procName))
        prerequisites.push(procName)
      end
    end
    
    alias enhance_old enhance
    def enhance(deps=nil, &block)
      #puts "in enhance of #{name}: #{deps}"
      InputProcessor().enhance(deps)
      enhance_old(nil, &block)
    end
    
    def AddInput(input)
      InputProcessor().AddInput(input)
    end
    
    # Extend/set the attributes of the process_chain.
    # Same as in processor except that the inputs and dependecies are set on the input processor.
    def Extend(valueMap, executeParent=true)
      #puts "in extend of process chain #{name}: #{valueMap}"
      if(valueMap == nil)
        return
      end
      
      inputs = valueMap[:Inputs] || valueMap[:ins]
      if(inputs)
        InputProcessor().AddInput(inputs)
      end
      
      throwOnUnknownInput = valueMap[:ThrowOnUnkownInput] || valueMap[:throwUnknown]
      if(throwOnUnknownInput)
        @ThrowOnUnkownInput = throwOnUnknownInput
        InputProcessor().ThrowOnUnkownInput = throwOnUnknownInput
        OutputProcessor().ThrowOnUnkownInput = throwOnUnknownInput
      end
      
      dependencies = valueMap[:Dependencies] || valueMap[:deps]
      if(dependencies)
        InputProcessor().enhance(dependencies)
      end
    end
    
    # State that the first processor should be input processor to the second
    # processor.
    # The args should be a list of processor name or :in, :out
    def Connect(*args)
      #puts "Connecting processors in #{name}: #{args}"
      if(args.length == 0)
        return
      end
      
      procNames = args
      if(args[0].class == Array)
        procNames = args[0]
      end
      
      lastProcName = nil
      procNames.each() do |procName|
        usedProcName = procName
        if(procName == :in)
          usedProcName = @InputProcessorName
        elsif(procName == :out)
          usedProcName = @OutputProcessorName
        end
        
        if(lastProcName)
          #puts "Adding #{lastProcName} to pres of #{usedProcName}"
          proc usedProcName, :procDeps => [lastProcName]
        end
        lastProcName = usedProcName
      end      
    end
  end
end
