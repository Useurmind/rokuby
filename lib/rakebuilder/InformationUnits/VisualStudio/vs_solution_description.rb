module RakeBuilder
  # Contains information that is needed to create a visual studio solution.
  # [Name] The name of the solution
  # [SolutionFilePath] The path of the solution file (normally derived automatically).
  class VsSolutionDescription < InformationUnit
    attr_accessor :Name
    attr_accessor :SolutionBasePath
    attr_accessor :SolutionFilePath
    
    def initialize(valueMap=nil)      
      #This is set by the solution preprocessor if not set
      @SolutionBasePath = ProjectPath.new(PROJECT_SUBDIR)
      @SolutionFilePath = nil
      @Name = "MySolution"
      
      super(valueMap)
      Extend(valueMap, false)
    end
    
    def initialize_copy(original)
      super(original)
      
      @SolutionBasePath = Clone(original.SolutionBasePath)
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
      
      solutionBasePath = valueMap[:SolutionBasePath] || valueMap[:slnBasePath]
      if(solutionBasePath)
        @SolutionBasePath = solutionBasePath
      end
      
      solutionFilePath = valueMap[:SolutionFilePath] || valueMap[:slnFilePath]
      if(solutionFilePath)
        @SolutionFilePath = solutionFilePath
      end
    end
  end
end
