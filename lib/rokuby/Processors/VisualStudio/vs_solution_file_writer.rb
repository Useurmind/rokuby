module Rokuby
  # This class is a processor meant to write out the file that represent a
  # visual studio solution.
  # It takes the necessary vs solution descriptions and projects
  # to create the file. There is no output from this processor and it only reads
  # the values that are given in the objects to create the files (there are no changes
  # made to them).
  # [RecurseProjects] Should the solution be made up of all projects on which the input projects depend (default: true)
  class VsSolutionFileWriter < Processor
    include VsSolutionProcessorUtility
    
    attr_accessor :RecurseProjects
    
    def initialize(name=nil, app=nil, project_file=nil)
      super(name, app, project_file)
      
      @RecurseProjects = true
    end
    
    def _ProcessInputs(taskArgs=nil)
      # nothing to be done
    end
    
    def _ExecutePostProcessing(taskArgs=nil)
      _SortInputs()
       
      if(@vsSolutionDescription == nil)
        raise "No VsSolutionDescription in #{self.class}:#{@Name}"
      end
      
      if($EXECUTION_MODE != :Full)
        return
      end
      
      _CreateSolutionFile()
    end
    
    def _CreateSolutionFile
      solutionFileCreator = SolutionFileCreator.new()
      solutionFileCreator.VsSolutionDescription = @vsSolutionDescription
      if(!@RecurseProjects)
        solutionFileCreator.VsProjects = @vsProjects
      else        
        @addedProjects = []
        @addedProjectGuids = Set.new()
        
        @vsProjects.each() do |proj|
          _AddProjectRecursively(proj)
        end
        solutionFileCreator.VsProjects = @addedProjects
      end      
      solutionFileCreator.BuildFile()
    end
    
    def _AddProjectRecursively(proj)
      if(!@addedProjectGuids.include?(proj.Guid))
        @addedProjects.push(proj)
        @addedProjectGuids.add(proj.Guid)
        
        proj.Dependencies.each() do |subProj|
          _AddProjectRecursively(subProj)
        end
      end
    end
    
    # Extend the attributes of the processor.
    def Extend(valueMap, executeParent=true)
      if(valueMap == nil)
        return
      end
      
      if(executeParent)
        super(valueMap)
      end
      
      recurseProjects = valueMap[:RecurseProjects] || valueMap[:recProj]
      if(recurseProjects != nil)
        @RecurseProjects = recurseProjects
      end
    end
  end
end
