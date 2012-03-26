module RakeBuilder

# The processor base class upon which all processors are build.
# It defines basic concepts of the class like inputs and outputs and the interface
# for the processing step.
# Each processor is a special sort of task. Therefore it is defined as any other task
# with the corresponding class.
# Processor can use the advantages of tasks. But there is one thing that needs to be
# considered here. The tasks must be defined during the setup phase, which means in the
# initialize or extend method (triggered by the user). If the task is defined during the
# process phase then it could be that the task is not found because the dependend task
# has already been tried to invoke.
# Processor can also use a cache infrastructure. This works as follows:
# - In at least the one iteration the processor builds up a cache that saves all the outputs
#   that this processor created in this iteration.
# - In the next iteration instead of creating outputs from the inputs of the processor, the
#   outputs will be loaded from cache.
# - To enable the execution of activities that cannot be cached, the processor has also the 
#   possibility to execute additional functionality after this processing took place (this
#   is called post processing).
# It is important to understand that you should not use inputs of the processor in the post
# processing because they may not be in the form you need them (they are not processed when cache
# is used). The same hold for the processing step of the inputs: do not assume that it is executed
# because it won't if the cache is used.
# [Name] The name of the processor to uniquely identify it.
# [ThrowOnUnknownInput] Throw an exception when an unknown input occures.
# [UseCache] Use the cache for this processor.
class Processor < Rake::ProcessorTask
  include GeneralUtility
  
  attr_accessor :Name
  attr_accessor :ThrowOnUnknownInput
  attr_accessor :UseCache
  
  def Outputs
    @outputs
  end
  
  def Inputs
    @inputs
  end
  
  def KnownInputClasses
    @knownInputClasses
  end
  
  alias initialize_processortask initialize
  def initialize(name=nil, app=nil, project_file=nil)    
    name = (name || GetUUID())
    
    #puts "in init processor #{name}"
    initialize_processortask(name, app, project_file)
    
    @Name = name
    @ThrowOnUnknownInput = false
    
    @knownInputClasses = []  # list of classes that can be processed by this processor, define in actual processor
    
    @inputs = []
    @outputs = []
    
    @UseCache = false
    if(project_file != nil)
      @Cache = project_file.ProcessCache
    end
    
    @processing = false
    @processingDone = false
  end
  
  # This can only be called after invoking the task.
  def _InputProcessors    
    inputProcs = {}
    
    #puts "pres of #{name}: #{prerequisites}"
    
    prerequisites.uniq().each() do |pre|
      t = lookup_prerequisite(pre)
      if(t.is_a?(Processor))
        inputProcs[pre] = t
      end
    end
    
    #puts "input processors: #{inputProcs}"
    return inputProcs
  end
  
  def _InputKnown(input)
    @knownInputClasses.each do |knownInputType|
      if(input.is_a?(knownInputType))
        return true
      end
    end
    
    return false
  end
  
  def _FetchInputs
    #puts "in FetchInputs of processor #{self}"
    _InputProcessors().each() do |name, inputProcessor|
      #puts "collecting outputs in #{@Name} from processor #{name}: #{inputProcessor.Outputs()}"
      inputProcessor.Outputs().each() do |output|
        AddInput(output)
      end
    end
  end
  
  # Execute all input processors, fetch their outputs and process them to create own output.
  # Returns true if processing took place and false else.
  def Process(task_args=nil, invocation_chain=nil)
    if(!InTaskHierarchy?())  # Only do checking for processors that are integrated into the task hierarchy
      _ProcessInputs()
      return true
    end
    
    if(@processing == true)
      raise "Circular dependency detected in processor chain"
    end
    
    if(@processingDone)
      return false
    end
    
    @processing = true
    
    if(Rake.application.options.trace)
      $stderr.puts "** Invoking pres in #{@ProjectFile.Path.RelativePath}:#{name}"
    end    
    InvokePrerequisites(task_args, invocation_chain)
    
    if(Rake.application.options.trace)
      $stderr.puts "** Fetching inputs in #{@ProjectFile.Path.RelativePath}:#{name}"
    end
    _FetchInputs()
      
    
    if(@UseCache && @Cache != nil)
      if(Rake.application.options.trace)
        $stderr.puts "** Loading outputs from cache in #{@ProjectFile.Path.RelativePath}:#{name}"#": #{@inputs}"
      end
      @outputs = @Cache.GetProcessorCache(self)
    else
      if(Rake.application.options.trace)
        $stderr.puts "** Processing outputs from inputs in #{@ProjectFile.Path.RelativePath}:#{name}"#": #{@inputs}"
      end
      #puts "Inputs for #{@ProjectFile.Path.RelativePath}:#{name}:#{@inputs}"
      _ProcessInputs(task_args)
      @Cache.UpdateProcessorCache(self)
    end
    
    if(Rake.application.options.trace)
      $stderr.puts "** Executing post processing in #{@ProjectFile.Path.RelativePath}:#{name}"
    end
    _ExecutePostProcessing(task_args)
        
    if(Rake.application.options.trace)
      $stderr.puts "** Executing actions in #{@ProjectFile.Path.RelativePath}:#{name}"
    end
    Execute(task_args)
    
    @processing = false
    
    @processingDone = true
    return true
  end
  
  # This method can be overloaded to deal with the case that cached values are used.
  # _ProcessInputs is then not called.
  # Some processor will still need to execute some actions even in this case.
  def _ExecutePostProcessing(taskArgs=nil)
    #raise "_ProcessCacheValues not defined in #{self.class.name}"
  end
  
  # This function needs to be overloaded by derived classes.
  # It should process the inputs that are already filled in the @inputs member
  # and fill the corresponding @outputs list with the processed output information.
  def _ProcessInputs(taskArgs=nil)
    raise "_ProcessInputs not defined in #{self.class.name}"
  end
  
  # Add one or several inputs to the input queue of this class.
  # If at least one of the inputs was not successfully added returns false, else true.
  def AddInput(input)
    if(input.class == Array)
      inputsDone = true
      input.each() do |inp|
        inputsDone = inputsDone and _AddInput(inp)
      end
      return inputsDone
    else
      return _AddInput(input)
    end    
  end
  
  def _AddInput(input)
    #puts "Adding input to #{@Name}: #{input}"
    if(_InputKnown(input))
      if(_OnAddInput(input))
        @inputs.push(input)      
        return true
      else
        return false
      end
    end
    
    if(@ThrowOnUnknownInput)
      raise "Got unknown input in processor #{self.class.name}: #{input.to_s()}"
    end
    
    return false
  end
  
  # Overwrite this if you need to take action when input is added
  # Returns true if the input should really be added (this should be default).
  # If it should not be added instead return false.
  def _OnAddInput(input)
    return true
  end
  
  def GetOutputByClass(cls)
    outputsWithClass = GetOutputsByClass(cls)
    if(outputsWithClass.length == 0)
      return nil
    end
    return outputsWithClass[0]
  end
  
  def GetOutputsByClass(cls)
    outputsWithClass = []
    @outputs.each() do |output|
      if(output.is_a?(cls))
        outputsWithClass.push output
      end
    end
    return outputsWithClass
  end
  
  # Extend/set the attributes of the processor.
  def Extend(valueMap, executeParent=true)
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
    end
    
    dependencies = valueMap[:Dependencies] || valueMap[:deps]
    if(dependencies)
      prerequisites.push(dependencies)
    end
  end
end

end