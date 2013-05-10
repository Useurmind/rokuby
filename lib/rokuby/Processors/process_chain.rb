module Rokuby
  # A class to manage the processor structure.
  # A process chain is a directed graph structure of processors that are connected and
  # propagate their outputs to the next processors in the graph.
  class ProcessChain < Processor
    include TaskPathUtility
    include Rokuby::DSL
    
    attr_reader :InputProcessorName
    attr_reader :OutputProcessorName
    attr_reader :InputProcessor
    attr_reader :OutputProcessor
    
    attr_reader :ChainProcessors
    
    alias initialize_processor initialize    
    def initialize(name=nil, app=nil, projectFile=nil)
      initialize_processor(name, app, projectFile)
      
      @ChainProcessors = {}
      
      @InputProcessorName = _GetProcessorName("in")
      @OutputProcessorName = _GetProcessorName("out")
      
      @InputProcessor = defineProc PassthroughProcessor, @InputProcessorName
      @OutputProcessor = defineProc PassthroughProcessor, @OutputProcessorName
      
      AddDependencies_Processor(@OutputProcessorName)
      
      AddProcessor(@InputProcessor)
      AddProcessor(@OutputProcessor)
    end
    
    # do not use this function without calling adapt name afterwards
    # adapt name does the actual copying of the internal processors that can
    # not be done before the name of the process chain is clear.
    alias intialize_copy_processor initialize_copy
    def initialize_copy(original)
      intialize_copy_processor(original)
      
      @ChainProcessors = original.ChainProcessors
      
      @InputProcessorName = Clone(original.InputProcessorName)
      @OutputProcessorName = Clone(original.OutputProcessorName)
      
      @InputProcessor = original.InputProcessor
      @OutputProcessor = original.OutputProcessor      
    end
    
    alias AdaptName_processor AdaptName
    def AdaptName(newName)
      oldName = name()
      
      AdaptName_processor(newName)
      
      _CloneChainProcessors(newName, oldName)
      
      RemoveDependencies(@OutputProcessorName)
      
      @InputProcessorName = _AdaptProcessorName(oldName, newName, @InputProcessorName)
      @OutputProcessorName = _AdaptProcessorName(oldName, newName, @OutputProcessorName)
      
      AddDependencies_Processor(@OutputProcessorName)
      
      @InputProcessor = @ChainProcessors[@InputProcessorName]
      @OutputProcessor = @ChainProcessors[@OutputProcessorName]
      
      AddProcessor(@InputProcessor)
      AddProcessor(@OutputProcessor)
    end
    
    # replace the existing chain processors through new ones that are clones of the old processors
    def _CloneChainProcessors(newName, oldName)
      oldChainProcessors = @ChainProcessors
      @ChainProcessors = {}
      oldChainProcessors.keys().each() do |procName|
        newProcessorName = _AdaptProcessorName(newName, oldName, procName)
        newProcessor = cloneProc newProcessorName procName
        newProcessor.RemoveDependencies(@ChainProcessors.keys())  # all internal dependencies should be removed
        AddProcessor(newProcessor)
      end
    end
    
    # Nothing to be done here
    def _InitProc
    end
    
    # Get a processor name with a custom extension
    def _GetProcessorName(extension)
      return "#{@Name}_#{extension}"
    end
    
    # Replace an old processor name with new one including the new process chain name
    def _AdaptProcessorName(newName, oldName, oldProcessorName)
      return oldProcessorName.gsub(oldName, newName)
    end
    
    def _InputKnown(input)
      return true
    end
    
    def _ProcessInputs(taskArgs=nil)
      #puts "task args in chain are #{taskArgs}"
      @outputs = OutputProcessor().Outputs()
    end
    
    # Add a processor to this process chain.
    def AddProcessor(processor)
      if(!@ChainProcessors[processor.to_s()])
        @ChainProcessors[processor.to_s()] = processor
      end
    end
    
    alias AddDependencies_Processor AddDependencies
    def AddDependencies(deps)
      InputProcessor().AddDependencies(deps)
    end
    
    def _OnAddInput(input)
      InputProcessor().AddInput(input)
      return true
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
        AddInput(inputs)
      end
      
      throwOnUnknownInput = valueMap[:ThrowOnUnkownInput] || valueMap[:throwUnknown]
      if(throwOnUnknownInput)
        @ThrowOnUnkownInput = throwOnUnknownInput
        InputProcessor().ThrowOnUnkownInput = throwOnUnknownInput
        OutputProcessor().ThrowOnUnkownInput = throwOnUnknownInput
      end
      
      dependencies = valueMap[:Dependencies] || valueMap[:deps]
      if(dependencies)
        InputProcessor().AddDependencies(dependencies)
      end
    end
    
    # State that some processors should be chained. The processors in the list
    # will deliver their output to the next processor in the list.
    # The processors should already be defined when calling this function.
    # The args should be a list of processor names or :in, :out
    def Connect(*args)
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
          p = proc usedProcName
          if(!p)
            raise "Could not find processor '#{p.Name}' when trying to connect processor '#{lastProcName}' to its input."
          end
          AddProcessor(p)
          proc usedProcName, :procDeps => [lastProcName]
        end
        lastProcName = usedProcName
      end      
    end
  end
end
