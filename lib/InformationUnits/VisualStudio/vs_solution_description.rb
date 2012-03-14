module RakeBuilder
  # Contains information that is needed to create a visual studio solution.
  # [Name] The name of the solution
  # [SolutionFilePath] The path of the solution file (normally derived automatically).
  class VSSolutionDescription < InformationUnit
    attr_accessor :Name
    attr_accessor :SolutionFilePath
    
    def initialize(valueMap=nil)      
      # This is set by the solution preprocessor if not set
      @SolutionFilePath = nil
      @Name = "MySolution"
      
      super(valueMap)
      Extend(valueMap, false)
    end
    
    def initialize_copy(original)
      super(original)
      
      @SolutionFilePath = Clone(original.SolutionFilePath)
      @Name = Clone(original.Name)
    end
    
    def Extend(valueMap, callParent=true)
      if(valueMap == nil)
        return
      end
      
      if(callParent)
        super(valueMap)
      end
      
      name = valueMap[:Name] || valueMap[:name]
      if(name)
        @Name = name
      end
      
      solutionFilePath = valueMap[:SolutionFilePath] || valueMap[slnFilePath]
      if(solutionFilePath)
        @SolutionFilePath = solutionFilePath
      end
    end
  end
end
