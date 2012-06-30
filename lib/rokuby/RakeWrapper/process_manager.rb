module Rokuby
  # This class is responsible for managing processors and process chains that are
  # needed for a process build.
  # ATTENTION: Some function calls assume that this module is included into the ProjectFile class.
  module ProcessManager
    include TaskPathUtility
    
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
    
    # Create a clone of a given processor
    # [newName] The name of the new processor.
    # [oldName] The name of the processor to clone.
    # A clone of a processor depends on the implementation of the initialize_copy function of the processor.
    # The basic rules for cloning processors is:
    # - Only clone processors that were created in the current project file.
    # - Only the processor is cloned with the state of when it is cloned.
    # - Cloning process chains will also lead to cloning subprocessors of the chains and adapting their names.
    def CloneProcessor(newName, oldPath)
      processor, sourceProjectFile = _GetProcessor(nil, oldPath)     
      
      newProcessor = initialize_copy(processor)
      newProcessor.AdaptName(newName)
      
      @Processors[newName] = newProcessor
      
      return newProcessor
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
        raise "No correct arguments for processor definition, missing name."
      end
      
      processor, sourceProjectFile = _GetProcessor(procClass, name)
      
      if(processor == nil)
        raise "Could not find or allocate processor #{name} in #{@Path}" # Path is from ProjectFile
      end
      
      inputs, valueMap, taskArgs, taskDeps = _ParseProcessorArgs(*args)
      
      #puts "enhancing processor task #{name}: #{inputs}, #{valueMap}, #{taskArgs}, #{taskDeps}"
      
      mappedTaskDeps = taskDeps
      if(sourceProjectFile != self)
        mappedTaskDeps = taskDeps.map() do |dep|
          
          #puts "Mapping dep #{dep}:"
          absoluteDep = AbsoluteTaskPath(dep, self)
          #puts "Absolute dep: #{absoluteDep}"
          usedDep = MakeRelativeTo(absoluteDep, sourceProjectFile)
          #puts "Used dep: #{usedDep}"
          
          usedDep
        end  
      end     
      
      processor.AddDependencies(mappedTaskDeps)
      processor.enhance(nil, &block)
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
      proc = nil
      sourceProjectFile = self
      
      if(@Processors[name])
        proc = @Processors[name]
        return proc, sourceProjectFile
      end
      
      if(procClass == nil)
        
        # find processor in appplication
        # puts "Trying to find proc #{name} from #{Path()}"
        taskPath = ApplicationBasedTaskPath(name, self)
        
        proc, sourceProjectFile = Rake.application.FindProcessor(taskPath)
        #puts "Found processor #{proc.FullName()}"
        return proc, sourceProjectFile
      end
      
      @Processors[name] = intern(procClass, name)
       
      proc = @Processors[name]
      
      return proc, sourceProjectFile
    end
  end
end