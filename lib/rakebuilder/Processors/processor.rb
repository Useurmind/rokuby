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
# [Name] The name of the processor to uniquely identify it.
# [ThrowOnUnknownInput] Throw an exception when an unknown input occures.
class Processor < Rake::ProcessorTask
  include GeneralUtility
  
  attr_accessor :Name
  attr_accessor :ThrowOnUnknownInput
  
  def Outputs
    @outputs
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
    
    if(Rake.application.options.trace)
      $stderr.puts "** Processing inputs in #{@ProjectFile.Path.RelativePath}:#{name}"#: #{@inputs}"
    end
    _ProcessInputs()
    
    if(Rake.application.options.trace)
      $stderr.puts "** Executing actions in #{@ProjectFile.Path.RelativePath}:#{name}"
    end
    Execute(task_args)
    
    @processing = false
    
    @processingDone = true
    return true
  end
  
  # This function needs to be overloaded by derived classes.
  # It should process the inputs that are already filled in the @inputs member
  # and fill the corresponding @outputs list with the processed output information.
  def _ProcessInputs
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
    if(_InputKnown(input))
      @inputs.push(input)
      return true
    end
    
    if(@ThrowOnUnknownInput)
      raise "Got unknown input in processor #{self.class.name}: #{input.to_s()}"
    end
    
    return false
  end
  
  # Overwrite this if you need to take action when input is added
  def _OnAddInput(input)
    
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