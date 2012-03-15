module RakeBuilder
  # This class is a processor meant to write out the files that represent a
  # visual studio project.
  # It takes the necessary (vs) project description, instances and configurations
  # to create the files. There is no output from this processor and it only reads
  # the values that are given in the objects to create the files (there are no changes
  # made to them).
  class VsProjectFilesWriter < Processor
    include VsProjectProcessorUtility
    
    def initialize(name, app, project_file)
      super(name, app, project_file)
      
      _RegisterInputTypes()
    end
    
    def _ProcessInputs
      _SortInputs()
      
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
      fileCreator.ProjectDescription = @projectDescription
      fileCreator.ProjectInstance = @projectInstance
      fileCreator.ProjectConfigurations = @projectConfigurations
      fileCreator.VsProjectInstance = @vsProjectInstance
      fileCreator.VsProjectDescription = @vsProjectDescription
      fileCreator.VsProjectConfigurations = @vsProjectConfigurations
    end
  end
end
