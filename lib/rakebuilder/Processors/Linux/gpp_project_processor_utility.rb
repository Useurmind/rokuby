module RakeBuilder
  module GppProjectProcessorUtility
    def initialize(*args)
      super(*args)
      @projectInstance = nil
      @projectDescription = nil
      @projectConfigurations = []
      @gppProjectDescription = VsProjectDescription.new()
      @gppProjectConfigurations = []
      @gppProjects = []
      @passthroughDefines = []

      @BackTask = Rake::Task.define_task "#{@Name}_BackTask", :descr, :inst, :gppDescr, :gppConf   # used to create a new task chain
    end

    # Register the known input types for such a processor.
    def _RegisterInputTypes
      @knownInputClasses.push(RakeBuilder::ProjectDescription)
      @knownInputClasses.push(RakeBuilder::ProjectConfiguration)
      @knownInputClasses.push(RakeBuilder::ProjectInstance)
      @knownInputClasses.push(RakeBuilder::GppProjectDescription)
      @knownInputClasses.push(RakeBuilder::GppProjectConfiguration)
      @knownInputClasses.push(RakeBuilder::GppProject)
      @knownInputClasses.push(RakeBuilder::PassthroughDefines)
    end

    # Sort the processor inputs by their class type.
    def _SortInputs
      @inputs.each() do |input|
        if(input.is_a?(RakeBuilder::ProjectInstance))
          @projectInstance = input
        elsif(input.is_a?(RakeBuilder::ProjectDescription))
          @projectDescription = input
        elsif(input.is_a?(RakeBuilder::ProjectConfiguration))
          @projectConfigurations.push(input)
        elsif(input.is_a?(RakeBuilder::GppProjectDescription))
          @gppProjectDescription = input
        elsif(input.is_a?(RakeBuilder::GppProjectConfiguration))
          @gppProjectConfigurations.push(input)
        elsif(input.is_a?(RakeBuilder::GppProject))
          @gppProjects.push(input)
        elsif(input.is_a?(RakeBuilder::PassthroughDefines))
          @passthroughDefines.push(input)
        end
      end
    end

    def _ExecuteBackTask()
      @BackTask.invoke()
    end

    def _ForwardOutputs
      @outputs.push(@projectInstance)
      @outputs.push(@projectDescription)
      @outputs.concat(@projectConfigurations)
      @outputs.push(@gppProjectDescription)
      @outputs.concat(@gppProjectConfigurations)
      @outputs.concat(@gppProjects)
      @outputs.concat(@passthroughDefines)
    end
  end
end