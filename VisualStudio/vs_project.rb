require "ProjectManagement/cpp_project_configuration"

module RakeBuilder
    # This class represents the data needed to identify a project.
    # It is used to define projects for a SolutionFileCreator.
    # [Name] The name for the project.
    # [ProjectFilePath] The path to the project file relative to the base directory.
    # [FilterFilePath] The path to the filter file relative to the base directory.
    # [Guid] The UUID of the project in the form '{45CD..}'.
    # [Configurations] The VsProjectConfigurations for the project (only the Name, Platform must be set).
    # [Dependencies] The VsProjects that this project depends on ( ).
    class VsProject < CppProjectConfiguration
        
        attr_accessor :ProjectFilePath
        attr_accessor :FilterFilePath
        attr_accessor :Guid
        attr_accessor :VsProjectConfigurations
        attr_accessor :Dependencies
        attr_accessor :RootNamespace
        
        def initialize
            super
            
            @ProjectFilePath = ""
            @FilterFilePath = ""
            @Guid = GetUUID()
            @RootNamespace = ""
            @VsProjectConfigurations = []
            @Dependencies = []
        end
        
        def initialize_copy(original)
            super(original)
            
            @ProjectFilePath = Clone(original.ProjectDirectoryName)
            @FilterFilePath = Clone(original.FilterFilePath)
            @Guid = GetUUID()
            @RootNamespace = Clone(original.RootNamespace)
            @VsProjectConfigurations = Clone(original.VsProjectConfigurations)
            @Dependencies = Clone(original.Dependencies)
        end
        
        def InitializeFromParent(parent)            
            initialize()
            InitCopy(parent)
        end
        
        def CreateNewVsProjectConfiguration(name)
            if(VsConfigurationExists(name))
              abort "The project has already a configuration named #{name}"
            end
          
            newVsProjectConfiguration = VsProjectConfiguration.new()
            newVsProjectConfiguration.InitializeFromParent(self)
            newVsProjectConfiguration.Name = name
            
            @VsProjectConfigurations.push(newVsProjectConfiguration)
            
            return newVsProjectConfiguration
        end
        
        def VsConfigurationExists(name)
            return GetVsConfiguration(name) != nil
        end
          
        def GetVsConfiguration(name)
            @VsProjectConfigurations.each do |configuration|
              if(configuration.Name.eql? name)
                return configuration
              end
            end
            
            return nil
        end
    end
end
