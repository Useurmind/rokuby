module RakeBuilder
  # This class is responsible for managing processors and process chains that are
  # needed for a process build.
  module ProcessManager
    attr_accessor :Processors
    attr_accessor :ProcessChains
    
    def initialize()
      super
      @Processors = {}
      @ProcessChains = {}
    end
    
    # The args for the processor include the following:
    # - [name]: The name of the processor.
    # - [valueMap]: A map of value that should be used to configure the processor with extend.
    # - [taskArgs]: 
    def DefineProcessor(procClass, *args, &block)
      name, valueMap, taskArgs = _ParseProcessorArgs(args)
      
      if(!name)
        return nil
      end
      
      processor, newProcessor = _GetProcessor(procClass, name)
      processor.Extend(valueMap)
      if(newProcessor)
        processor.Task = Processor.define_task(taskArgs, &block)
      end
      
      return processor
    end
    
    def ChangeProcessChain(chainClass, *args, &block)
      name = _GetProcessChainName(chainClass, *args)
      if(!name)
        return nil
      end
      
      processChain, newChain = _GetProcessChain(chainClass, name)
      if(newChain)
        processChain.Task = Processor.define_task(taskArgs, &block)
      end
      
      args.drop(1)  # drop the name
      
      _ParseProcessChainArgs(args)
    end
    
    def _GetProcessChainName(chainClass, *args)
      if(args.length < 0 || args[0].class == Hash || args[0].class == Array)
        return nil
      end
      return args[0]
    end
    
    def _ParseProcessChainArgs(*args)
      procChainArgs = nil
      procArgs = nil
      
      return name, procArgs, procChainArgs
    end
    
    # Parse an array containing processors and/or processor input maps
    def _ParseProcessorChain(processorChain)
    end
    
    def _ParseProcessorArgs(*args)
      name = nil
      valueMap = nil
      taskArgs = nil
      
      return name, valueMap, taskArgs
    end
        
    def _GetProcessChain(procChainClass, name)
      if(@ProcessChains[name])
        return @ProcessChains[name], false
      end
      
      @ProcessChains[name] = procChainClass.new(name)
      return @ProcessChains[name], true
    end
    
    def _GetProcessor(procClass, name)      
      if(@Processors[name])
        return @Processors[name], false
      end
      
      @Processors[name] = procClass.new(name)
      return @Processors[name], true
    end
  end
end
