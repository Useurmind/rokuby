module RakeBuilder
  # This class takes the necessary steps to combine project description/configuration
  # and visual studio project description/configuration.
  # The input of this processor are the (vs) project descriptions and configurations
  # and the output are the copies of these objects that were modified.
  # The basic steps that are taken is to initialize the visual studio objects with values
  # that represent a proper combination of the values in general project description/
  # configuration and visual studio description/configuration.
  # This normally means that values in the visual studio configuration that are not set
  # can be overwritten/modified by values in the project configuration. Values that are
  # set by the user in the visual studio project objects should never be modified.
  class VSProjectPreprocessor < Processor
    def initialize(name, app, project_file)
      super(name, app, project_file)
      
      @projectDescription = nil
      @projectConfigurations = []
      @vsProjectDescription = nil
      @vsProjectConfigurations = []
      
      @knownInputClasses.push(RakeBuilder::ProjectDescription)
      @knownInputClasses.push(RakeBuilder::ProjectConfiguration)
      @knownInputClasses.push(RakeBuilder::VSProjectDescription)
      @knownInputClasses.push(RakeBuilder::VSProjectConfiguration)
    end
    
    def _ProcessInputs
      _SortInputs()
      
      _ExtendVsProjectDescription()
      
      _FilterProjectConfigurations()
      _ExtendVsProjectConfigurations()
      
      @outputs.push(@projectDescription)
      @outputs.concat(@projectConfigurations)
      @outputs.push(@vsProjectDescription)
      @outputs.concat(@vsProjectConfigurations)
    end
    
    def _SortInputs
      @inputs.each() do |input|
        if(input.is_a?(RakeBuilder::ProjectDescription))
          @projectDescription = input
        elsif(input.is_a?(RakeBuilder::ProjectConfiguration))
          @projectConfigurations.push(input)
        elsif(input.is_a?(RakeBuilder::VSProjectDescription))
          @vsProjectDescription = input
        elsif(input.is_a?(RakeBuilder::VSProjectConfiguration))
          @vsProjectConfigurations.push(input)
        end
      end
    end
    
    def _ExtendVsProjectDescription
      projectFilesBasePath = @projectDescription.ProjectPath + ProjectPath.new(PROJECT_SUBDIR)
      projectFileBaseName = @projectDescription.Name
      
      @vsProjectDescription.ProjectFilePath = projectFilesBasePath + ProjectPath.new("#{projectFileBaseName}.vcxproj")
      @vsProjectDescription.FilterFilePath = projectFilesBasePath + ProjectPath.new("#{projectFileBaseName}.vcxproj.filters")
    end
    
    def _ExtendVsProjectConfigurations
      @vsProjectConfigurations.each() do |vsConf|
        
        # Set binary name and extension and configuration type
        vsConf.TargetName = @projectDescription.BinaryName + "_" + vsConf.Platform.BinaryExtension()
        if(@projectDescription.BinaryType == :Application)
          if(vsConf.TargetExt == nil)
            vsConf.TargetExt = VS::Configuration::TargetExt::APPLICATION
          end
          if(vsConf.ConfigurationType == nil)
            vsConf.ConfigurationType = VS::Configuration::ConfigurationType::APPLICATION
          end
        elsif(@projectDescription.BinaryType == :Shared)
          if(vsConf.TargetExt == nil)
            vsConf.TargetExt = VS::Configuration::TargetExt::SHARED
          end
          if(vsConf.ConfigurationType == nil)
            vsConf.ConfigurationType = VS::Configuration::ConfigurationType::SHARED
          end
        elsif(@projectDescription.BinaryType == :Static)
          if(vsConf.TargetExt == nil)
            vsConf.TargetExt = VS::Configuration::TargetExt::STATIC
          end
          if(vsConf.ConfigurationType == nil)
            vsConf.ConfigurationType = VS::Configuration::ConfigurationType::STATIC
          end
        end
        
        # Set the intermediate and output directories
        if(vsConf.OutputDirectory == nil)
          vsConf.OutputDirectory = @projectDescription.BuildPath + ProjectPath.new(vsConf.Platform.Name)
        end
        if(vsConf.IntermediateDirectory == nil)
          vsConf.IntermediateDirectory = @projectDescription.CompilesPath + ProjectPath.new(vsConf.Platform.Name)
        end       
        
      end
    end
    
    # Filter out unused configurations
    # Only vs configurations that have a matching project configuration (the same platform)
    # are allowed for further use.
    def _FilterProjectConfigurations
      remainingConfigurations = []
      @vsProjectConfigurations.each() do |vsConf|
        if(_HaveProjectConfiguration(vsConf.Platform))
          remainingConfigurations.push(vsConf)
        end
      end
      
      vsProjectConfigurations = remainingConfigurations
    end
    
    def _HaveProjectConfiguration(platform)
      @projectConfigurations.each() do |conf|
        if(conf.Platform == platform)
          return true
        end
      end
      return false
    end
  end
end
