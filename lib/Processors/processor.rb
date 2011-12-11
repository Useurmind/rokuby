module RakeBuilder

# The processor base class upon which all processors are build.
# It defines basic concepts of the class like inputs and outputs and the interface
# for the processing step.
# [Name] The name of the processor to uniquely identify it.
# [ThrowOnUnknownInput] Throw an exception when an unknown input occures.
class Processor
  include GeneralUtility
  
  attr_accessor :Name
  attr_accessor :ProcessChain
  attr_accessor :ThrowOnUnknownInput
  
  def Outputs
    @outputs
  end
  
  def initialize(name)
    if(!name)
      name = GetUUID()
    end
    
    @Name = name
    @ProcessChain = nil
    @ThrowOnUnknownInput = true
    
    @knownInputClasses = []  # list of classes that can be processed by this processor, define in actual processor
    
    @inputProcessors = {}
    @outputProcessors = {}
    
    @inputs = []
    @outputs = []
    
    @processingDone = false
  end
  
  def _InputKnown(input)
    @knownInputClasses.each do |knownInputType|
      if(input.is_a?(knownInputType))
        return true
      end
    end
    
    return false
  end
  
  def _ExecuteInputProcessorsAndFetchInputs
    @inputProcessors.each() do |name, inputProcessor|
      inputProcessor.Process()
      inputProcessor.Outputs().each() do |output|
        AddInput(output)
      end
    end
  end
  
  # Execute all input processors, fetch their outputs and process them to create own output.
  # Returns true if processing took place and false else.
  def Process
    if(@processingDone)
      return false
    end
    
    _ExecuteInputProcessorsAndFetchInputs()
    
    _ProcessInputs()
    
    @processingDone = true
    return true
  end
  
  # This function needs to be overloaded by derived classes.
  # It should process the inputs that are already filled in the @inputs member
  # and fill the corresponding @outputs list with the processed output information.
  def _ProcessInputs
    raise "_ProcessInputs not defined in #{self.class.name}"
  end
  
  # Add a processor that delivers input to this processor.
  def AddInputProcessor(processor)
    if(@inputProcessors[processor.Name] == nil)
      @inputProcessors[processor.Name] = processor
    end
  end
  
  # Add a processor to which output is delivered by this processor.
  def AddOutputProcessors(processor)
    if(@outputProcessors[processor.Name] == nil)
      @outputProcessors[processor.Name] = processor
    end
  end
  
  # Add one or several inputs to the input queue of this class.
  # If at least one of the inputs was not successfully added returns false, else true.
  def AddInput(input)
    if(input.length != nil)
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
end

end