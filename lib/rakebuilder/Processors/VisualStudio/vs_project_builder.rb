module RakeBuilder
  # This class creates project and filter file for a given project and produces a
  # VSProject instance that can be used in other projects.
  # This builder works like a normal builder but additionally accepts a visual studio
  # project description, one visual studio instance and several configurations.
  # The configurations are associated with the project configurations by means of the
  # platform they are defined for. Make sure that there is at most one visual studio and normal
  # project configuration for each platform.
  # Output of this processor is a VSProject instance that represents the created project.
  class VsProjectBuilder < ProcessChain
    def initialize(name=nil, app=nil, project_file=nil)
      super(name, app, project_file)
      
      @projectPreprocessor = DefineProc VsProjectPreprocessor, "#{@Name}_Pre"
      @projectCreator = DefineProc VsProjectCreator, "#{@Name}_Proj"
      @fileWriter = DefineProc VsProjectFilesWriter, "#{@Name}_Files"
      @vsProjectFinder = DefineProc VsProjectFinder, "#{@Name}_ProjFinder"
      @vsPostBuildTaskCreator = DefineProc VsPostBuildCommandTaskCreator, "#{@Name}_PostBuild"
      
      Connect(:in, @vsProjectFinder.to_s, @fileWriter.to_s)
      Connect(:in, @projectPreprocessor.to_s, @vsPostBuildTaskCreator.to_s)      
      Connect(@projectCreator.to_s, :out)
      Connect(@fileWriter.to_s, @projectCreator.to_s)
      Connect(@vsPostBuildTaskCreator.to_s, @projectCreator.to_s)
      Connect(@vsPostBuildTaskCreator.to_s, @fileWriter.to_s)
    end
  end
end
