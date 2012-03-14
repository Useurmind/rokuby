module RakeBuilder
  # This class is responsible for gathering 
  class VSProjectLibraryGatherer < Processor
    include VSProjectProcessorUtility
    
    def initialize(name, app, project_file)
      super(name, app, project_file)
      
      _RegisterInputTypes()
    end
    
    def _ProcessInputs()
      _SortInputs()
      
      @projectInstance.Libraries.each() do |lib|
        if(lib.)
        end
      end
    end
  end
end
