module RakeBuilder
  # This class is responsible for managing processors and process chains that are
  # needed for a process build.
  # ATTENTION: Some function calls assume that this module is included into the ProjectFile class.
  module ProcessManager
    attr_accessor :Processors
    attr_accessor :ProcessChains
    
    def initialize()
      super
      @Processors = {}
      @ProcessChains = {}
    end
    
    # The args for the processor include the following:
    # For examples how this can be formatted see the unit tests (-> Test_ProcessManager).
    # - [name]: The name of the processor (required).
    # - [procIns]: An array or list of input args (optional)
    # - [valueMap]: A map of values that should be used to configure the processor with extend (optional).
    # - [procArgs]: A list of input arguments for the task (optional).
    # - [procDeps]: An array of dependencies for the task (optional)
    def DefineProcessor(procClass, *args, &block)      
      name, args = _GetProcessorName(*args)
      
      if(!name)
        return nil
      end
      
      processor = _GetProcessor(procClass, name)
      
      inputs, valueMap, taskArgs, taskDeps = _ParseProcessorArgs(*args)
      
      processor.enhance(taskDeps, &block)
      processor.set_arg_names(taskArgs)
      
      inputs.each() do |input|
        processor.AddInput(input)
      end      
      processor.Extend(valueMap)
      
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
      
      args = args.drop(1)  # drop the name
      
      _ParseProcessChainArgs(args)
    end
    
    # Retrieves the processor name and the rest of the arguments
    def _GetProcessorName(*args)
      if(args.length < 1 || (args[0].class != String && args[0].class != Symbol))
        return nil, args
      end
      
      return args[0], args.drop(1)
    end
    
    def _ParseProcessorArgs(*args)
      inputs = []
      valueMap = {}
      taskArgs = []
      taskDeps = []
      
      if(args.length < 1 || args[0].class != Hash)
        return inputs, valueMap, taskArgs, taskDeps
      end
      
      hash = args[0]
      
      hash.keys.each() do |key|
        if(key == :procIns)
          inputs = hash[key]
          elsif(key == :procArgs)
            taskArgs = hash[key]
        elsif(key == :procDeps)
          taskDeps = hash[key]
        else
          valueMap[key] = hash[key]
        end
      end
      
      return inputs, valueMap, taskArgs, taskDeps
    end
     
    def _ParseProcessChainArgs(*args)
      procChainArgs = nil
      procArgs = nil
      
      return name, procArgs, procChainArgs
    end
    
    # Parse an array containing processors and/or processor input maps
    def _ParseProcessorChain(processorChain)
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
        return @Processors[name]
      end
      
      @Processors[name] = intern(procClass, name)
       
      return @Processors[name]
    end
  end
end
