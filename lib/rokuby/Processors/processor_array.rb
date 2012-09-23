module Rokuby
  # This class is a special type of processor supported by the multi process chain.
  # It consists of several sub processors.
  # Executing it will execute all sub processors.
  # NOTE: inputs to this class will be added to all sub processors when they are executed.
  # Currently, its usecase is to connect the internal processors to previous processor arrays.
  # On adding a dependency it will try to retrieve a ProcessorArray with that path
  # and connect its underlying processors with the matching processors from the previous array.
  # [ArrayProcessors] A hash containing all the subprocessors in this array.
  class ProcessorArray < ProcessChain
        
    attr_reader :ArrayProcessors
        
    def _InitProc
      # knows everything per implementation of _InputKnown
      
      @ArrayProcessors = {}
    end
    
    def _InputKnown(input)
      return true
    end
    
    # Add a processor to the array.
    # The processor should already be defined when calling this function.
    # [key] The key that identifies the processor in the array.
    # [processor] The processor that should be inserted.
    def AddSubProcessor(key, procPath)
      Connect(:in, procPath, :out)
      @ArrayProcessors[key] = proc procPath
    end
    
    # Get a processor at a certain with a certain key.
    def GetSubProcessor(key)
      return @ArrayProcessors[key]
    end
    
    # Extend/set the attributes of the ProcessorArray.
    def Extend(valueMap, executeParent=true)
      #puts "in extend of process chain #{name}: #{valueMap}"
      if(valueMap == nil)
        return
      end
      
      if(executeParent)
        super(valueMap)
      end
      
      processors = valueMap[:ArrayProcessors] || valueMap[:arrProcs]
      if(processors)
        processors.each() do |key, procPath|
          AddSubProcessor(key, procPath)
        end 
      end
    end
    
    alias AddDependencies_ProcessChain AddDependencies
    def AddDependencies(deps)
      AddDependencies_Processor(deps)
    end
    
    def _AddDependencies(taskPaths)
      taskPaths.each() do |taskPathAndName|
        depProc = proc taskPathAndName
        taskPath = SplitTaskPath(taskPathAndName)[0]
        
        #puts "taskPath(#{taskPath}), taskName(#{taskName}), taskPathAndName(#{taskPathAndName})\n"
        
        @ArrayProcessors.each() do |key, ownProc|
          
          if(depProc.is_a?(Rokuby::ProcessorArray))          
            prevProc = depProc.GetSubProcessor(key)
            
            if(prevProc)              
              finalTaskPath = prevProc.Name()
              if(taskPath)
                finalTaskPath = JoinTaskPathName(taskPath, finalTaskPath)
              end
              
              #puts "Connecting processors #{finalTaskPath}\t->\t#{ownProc.Name()} in processor arrays"
              
              ownProc.AddDependencies(finalTaskPath) 
            end
          else
            ownProc.AddDependencies(taskPathAndName)
          end
        end
      end
    end
    
    def _RemoveDependencies(taskPaths)
      taskPaths.each() do |taskPathAndName|
        depProc = proc taskPathAndName
        taskPath = SplitTaskPath(taskPathAndName)[0]
        
        @ArrayProcessors.each() do |key, ownProc|
          
          if(depProc.is_a?(Rokuby::ProcessorArray))          
            prevProc = depProc.GetSubProcessor(key)
            
            if(prevProc)              
              finalTaskPath = prevProc.Name()
              if(taskPath)
                finalTaskPath = JoinTaskPathName(taskPath, finalTaskPath)
              end
            
              ownProc.RemoveDependencies(finalTaskPath)
            end
          else
            ownProc.RemoveDependencies(taskPathAndName)
          end
        end
      end 
    end
  end
end
