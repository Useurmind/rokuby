module Rokuby
  # This class is a processor meant to write out the files that represent a
  # visual studio project.
  # It takes the necessary (vs) project description, instances and configurations
  # to create the files. There is no output from this processor and it only reads
  # the values that are given in the objects to create the files (there are no changes
  # made to them).
  class VsProjectFilesWriter < Processor
    include VsProjectProcessorUtility
    
    def _ProcessInputs(taskArgs=nil)
      # nothing to be done
    end
    
    def _ExecutePostProcessing(taskArgs=nil)
      _SortInputs()
      
      if(@projectDescription == nil)
        raise "No ProjectDescription in #{self.class}:#{@Name}"
      end
      
      if(@projectInstance == nil)
        raise "No ProjectInstance in #{self.class}:#{@Name}"
      end
      
      if(@vsProjectDescription == nil)
        raise "No VsProjectDescription in #{self.class}:#{@Name}"
      end
      
      if(@vsProjectInstance == nil)
        raise "No VsProjectInstance in #{self.class}:#{@Name}"
      end
      
      #puts "in VsProjectFilesWriter: #{[@projectInstance]}"
      
      if($EXECUTION_MODE != :Full)
        return
      end
      
      #puts "VsProjectFileWrite uses vs project instance #{[@vsProjectInstance]}"
      
      _CreateFilterFile()
      _CreateProjectFile()
    end
    
    def _CreateFilterFile
      filterFileCreator = FilterFileCreator.new()
      _InitVsFileCreator(filterFileCreator)
      filterFileCreator.BuildFile()
    end
    
    def _CreateProjectFile
      projectFileCreator = ProjectFileCreator.new()
      _InitVsFileCreator(projectFileCreator)
      projectFileCreator.BuildFile()
    end
    
    def _InitVsFileCreator(fileCreator)
      fileCreator.VsProjects = @vsProjects
      fileCreator.ProjectDescription = @projectDescription
      fileCreator.ProjectInstance = @projectInstance
      fileCreator.ProjectConfigurations = @projectConfigurations
      fileCreator.VsProjectInstance = @vsProjectInstance
      fileCreator.VsProjectDescription = @vsProjectDescription
      fileCreator.VsProjectConfigurations = @vsProjectConfigurations
    end
  end
end
