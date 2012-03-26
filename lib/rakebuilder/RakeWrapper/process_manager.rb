module RakeBuilder
  # This class is responsible for managing processors and process chains that are
  # needed for a process build.
  # ATTENTION: Some function calls assume that this module is included into the ProjectFile class.
  module ProcessManager
    attr_accessor :Processors
    attr_accessor :ProcessChains
    attr_accessor :ProcessCache
    
    def initialize()
      super
      @Processors = {}
      @ProcessChains = {}
      @ProcessCache = nil
    end
    
    def SaveCache
      @ProcessCache.Save()
    end
    
    # The args for the processor include the following:
    # For examples how this can be formatted see the unit tests (-> Test_ProcessManager).
    # If procClass is nil only existing processors can be retrieved.
    # - [name]: The name of the processor (required).
    # - [procIns]: An array or list of input args (optional)
    # - [valueMap]: A map of values that should be used to configure the processor with extend (optional).
    # - [procArgs]: A list of input arguments for the task (optional).
    # - [procDeps]: An array of dependencies for the task (optional)
    def DefineProcessor(procClass, *args, &block)
      #puts "DEfineProcessor: #{args}"
      name, args = _GetProcessorName(*args)
      
      if(!name)
        return nil
      end
      
      processor = _GetProcessor(procClass, name)
      
      if(processor == nil)
        return nil
      end
      
      inputs, valueMap, taskArgs, taskDeps = _ParseProcessorArgs(*args)
      
      #puts "enhancing processor task #{name}: #{inputs}, #{valueMap}, #{taskArgs}, #{taskDeps}"
      processor.enhance(taskDeps, &block)
      processor.set_arg_names(taskArgs)
      
      processor.AddInput(inputs)
      processor.Extend(valueMap)
      if(!(Rake.application.options.no_cache ||
           Rake.application.options.no_lib_cache ||
           Rake.application.options.no_src_cache) &&
           @ProcessCache.exist?())
        processor.UseCache = true
      end
      
      return processor
    end
    
    # Define or change a new/existing process chain.
    # The arguments for the process chain are the names of the processors that should be
    # concated.
    def DefineProcessChain(chainClass, *args, &block)
      #puts "in DefineProcessChain: #{chainClass}, #{args}"
      name, args = _GetProcessorName(*args)
      if(!name)
        return nil
      end
      
      #puts "Creating process chain #{name}"
      
      processChain = _GetProcessChain(chainClass, name)
      if(processChain == nil)
        return nil
      end
      
      procNames, procArgs = _ParseProcessChainArgs(*args)
      
      #puts "procNames, procArgs for #{name}: #{procNames}, #{procArgs}"
      
      processChain.Connect(*procNames)
      DefineProcessor(nil, name, procArgs, &block)
    end
    
    # Retrieves the processor name and the rest of the arguments
    def _GetProcessorName(*args)
      #puts "in GetProcessorName: #{args}"
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
      procNames = []
      procArgs = nil
      
      args.each() do |arg|
        if(arg.class == Hash)
          procArgs = arg
        else
          procNames.push(arg)
        end
      end
      
      return procNames, procArgs
    end
        
    def _GetProcessChain(procChainClass, name)
      if(@ProcessChains[name])
        return @ProcessChains[name]
      end
      
      if(procChainClass == nil)
        return nil
      end
      
      processChain = intern(procChainClass, name)
      @ProcessChains[name] = processChain
      @Processors[name] = processChain
      
      return processChain
    end
    
    def _GetProcessor(procClass, name)      
      if(@Processors[name])
        return @Processors[name]
      end
      
      if(procClass == nil)
        return nil
      end
      
      @Processors[name] = intern(procClass, name)
       
      return @Processors[name]
    end
  end
end
