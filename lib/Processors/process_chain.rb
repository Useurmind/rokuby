module RakeBuilder
  # A class to manage the processor structure.
  class ProcessChain
    def initialize
      @processors = {}
    end
    
    def GetProcessor(name)
      return @processors[name]
    end
    
    def AddProcessor(processor)
      if(@processors[processor.Name] == nil)
        if(processor.ProcessChain)
          processor.ProcessChain.RemoveProcessor(processor)
        end
        
        @processors[processor.Name} = processor
        processor.ProcessChain = self
      end
    end
    
    def RemoveProcessor(processor)
      if(@processors[processor.Name])
        @processors[processor.Name] = nil
        processor.ProcessChain = nil
      end
    end
    
    def AddInput(processor, input)
      processor.AddInput(input)
    end
    
    def Connect(processor1, processor2)
      processor1.AddOutputProcessor(processor2)
      processor2.AddInputProcessor(processor1)
      AddProcessor(processor1)
      AddProcessor(processor2)
    end
  end
end
