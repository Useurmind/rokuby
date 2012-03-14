module RakeBuilder
  # This processor is responsible for building a visual studio solution out of different
  # visual studio projects.
  # The processor needs one VSSolutionDescription and one to several VSProject(s).
  # The processor does not produce any output.
  class VSSolutionBuilder < Processor
    def initialize(name, app, project_file)
      super(name, app, project_file)
      
      @knownInputClasses.push(RakeBuilder::VSSolutionDescription)
      @knownInputClasses.push(RakeBuilder::VSProject)
    end
  end
end
