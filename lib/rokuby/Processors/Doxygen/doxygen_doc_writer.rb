module Rokuby
  class DoxygenDocWriter < Processor
    def _InitProc
      @knownInputClasses.push(Rokuby::DoxygenConfiguration)
      @knownInputClasses.push(Rokuby::SourceUnitInstance)
      @knownInputClasses.push(Rokuby::ProjectInstance)
    end
    
    def _ProcessInputs(taskArgs=nil)
      @sourceUnits = []
      
      _SortInputs()
     
      ExecuteInPath(@ProjectFile.Path.DirectoryPath()) do
        if(!@doxyConfig)
          @doxyConfig = DoxygenConfiguration.new()
        end
        
        doxyCreator = DoxyfileCreator.new()
        doxyCreator.SourceUnitInstances = @sourceUnits
        doxyCreator.DoxygenConfiguration = @doxyConfig
       
        doxyCreator.CreateDoxyfile()
        doxyCreator.CreateDoxygenDocu()
      end
    end
    
    def _SortInputs
      @inputs.each() do |input|
        if(input.is_a?(Rokuby::DoxygenConfiguration))
          @doxyConfig = input
        elsif(input.is_a?(Rokuby::SourceUnitInstance))
          @sourceUnits.push(input)
        elsif(input.is_a?(Rokuby::ProjectInstance))
          @sourceUnits = @sourceUnits + input.SourceUnits
        end
      end
    end
  end
end
