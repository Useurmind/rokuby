
require "ProjectManagement/source_module"
require "ProjectManagement/cpp_project_configuration"
require "doxygen_builder"
require "Linux/ubuntu_packet_installer"
require "rake"

module RakeBuilder

  # A project manager should ease the creation of big projects with different
  # configurations and OS specific functionality.
  # The project manager allows to define a base project configuration which is
  # used for every newly added compile order/solution creator.
  # Additionally, it offers the possibility to copy compile orders and solution
  # creators and automatically adjust their names.
  # It also manages the inclusion of source module usage in the compile orders
  # and solution creators.
  # By default it creates a doxygen builder and an ubuntu packet installer for
  # which packets can be defined.
  # [BaseProjectConfiguration] The initial project configuration on which each project configuration is based.
  # [SourceModules] A hash containing the source modules with their name as key.
  # [SourceModuleUsage] A hash which can contain a list of modules for each compile order.
  # [LinuxCompileOrders] A hash with GppCompilerOrders with their name as key.
  # [CompileOrderDescriptions] A hash containing the description for the final task of each compile order with the name of it as key.
  # [WindowsSolutionCreators] todo
  # [DefaultTargetName] The name of the compile order that is used as the default target.
  class ProjectManager

    attr_accessor :BaseProjectConfiguration
    attr_accessor :SourceModules
    attr_accessor :SourceModuleUsage 
    attr_accessor :LinuxCompileOrders
    attr_accessor :CompileOrderDescriptions
    attr_accessor :WindowsSolutionCreators
    attr_accessor :DefaultTargetName

    def initialize(baseProjectConfiguration)
      @BaseProjectConfiguration = baseProjectConfiguration
      @SourceModules = {}
      @SourceModuleUsage = {}
      @LinuxCompileOrders = {}
      @CompileOrderDescriptions = {}
      @VsSolutionCreator = VsSolutionCreator.new(baseProjectConfiguration)

      @DoxygenBuilder = DoxygenBuilder.new()
      @DoxygenBuilder.ProjectConfiguration = baseProjectConfiguration

      @UbuntuPacketInstaller = UbuntuPacketInstaller.new()
    end
	
	# Add some packets that should be installed with a list of package names.
    def AddUbuntuPacketInstallations(packetNames)
      @UbuntuPacketInstaller.PacketNames.concat(packetNames)
    end

	# Add a source module that is contained in the source.
    def AddSourceModule(sourceModule)
      if(@SourceModules[sourceModule.Name] != nil)
        abort "The module #{sourceModule.Name} is already present in the ProjectManager"
      end
      @SourceModules[sourceModule.Name] = sourceModule
    end

	# Add a compile order.
    def AddLinuxCompileOrder(compileOrder, description)
      _CheckCompileOrderNotExists(compileOrder.Name)

      compileOrder.ProjectConfiguration = @BaseProjectConfiguration.clone()
	  
      compileOrder.ProjectConfiguration.Name = compileOrder.Name
	  
      @LinuxCompileOrders[compileOrder.Name] = compileOrder
      @CompileOrderDescriptions[compileOrder.Name] = description
	  
      return compileOrder
    end

    def AddVsProjectConfiguration(name)
      return @VsSolutionCreator.CreateNewVsProjectConfiguration(name)
    end

	# Copy a compile order that is already present giving it a new name and description.
    def CopyLinuxCompileOrder(compileOrder, copyName, description)
      _CheckCompileOrderExists(compileOrder.Name)
      _CheckCompileOrderNotExists(copyName)

      copyCompileOrder = @LinuxCompileOrders[compileOrder.Name].clone()
      @LinuxCompileOrders[copyName] = copyCompileOrder
      @CompileOrderDescriptions[copyName] = description
	  copyCompileOrder.Name = copyName
      copyCompileOrder.ProjectConfiguration.Name = copyName

      return copyCompileOrder
    end

    def CreateTasks()
      _ApplySourceModuleUsageToCompileOrders()
      _ApplySourceModuleUsageToVsProjectConfigurations()

      desc "Build the doxygen documentation of the project"
      task :docu do
        @DoxygenBuilder.CreateDoxyfile()
      end

      @UbuntuPacketInstaller.CreatePacketInstallationTask()
      desc "Install required ubuntu packets"
      task :packets => [@UbuntuPacketInstaller.TaskName]

      @LinuxCompileOrders.each do |name, compileOrder|
        compileOrder.CreateProjectTasks()
	desc @CompileOrderDescriptions[name]
        task compileOrder.ProjectConfiguration.Name => [compileOrder.EndTask]
      end
      
      @VsSolutionCreator.CreateTasks()
      desc "Create the Visual Studio solution for the project"
      task "VsSolution" => @VsSolutionCreator.EndTask

      _CheckCompileOrderExists(@DefaultTargetName)
      task :default => [@LinuxCompileOrders[@DefaultTargetName].ProjectConfiguration.Name]
    end

    def _CheckCompileOrderNotExists(name)
      if(@LinuxCompileOrders[name] != nil)
        abort "The compile order #{name} is already present in the ProjectManager"
      end
    end

    def _CheckCompileOrderExists(name)
      if(@LinuxCompileOrders[name] == nil)
        abort "The compile order #{name} does not exist in the ProjectManager"
      end
    end

    def _ApplySourceModuleUsageToCompileOrders
      @LinuxCompileOrders.each do |name,compileOrder|
	  modulesToUse = _GetSourceModulesToUse(compileOrder)
		
	  _ApplySourceModuleUsageToProjectConfiguration(compileOrder.ProjectConfiguration, modulesToUse)
      end
    end
    
    def _ApplySourceModuleUsageToVsProjectConfigurations
      @VsSolutionCreator.VsProjectConfigurations.each do |configuration|
	  modulesToUse = _GetSourceModulesToUse(configuration)
		
	  _ApplySourceModuleUsageToProjectConfiguration(configuration, modulesToUse)
      end
    end
    
    def _GetSourceModulesToUse(component)
	if(!@SourceModuleUsage[component])
	    modulesToUse = []
	else
	    modulesToUse = @SourceModuleUsage[component]	
	end
	return modulesToUse
    end
    
    def _ApplySourceModuleUsageToProjectConfiguration(projectConfiguration, modulesToUse)
	modulesToUse.each do |sourceModule|
	    projectConfiguration.AddLibraries(sourceModule.AssociatedLibraries, :Linux)
	    if(sourceModule.Define)
		projectConfiguration.Defines.push(sourceModule.Define)
	    end
	end  	  
	modulesNotToUse = @SourceModules.values() - modulesToUse
	_ExcludeSourceModulesFromProjectConfiguration(modulesNotToUse, projectConfiguration)
	puts "Source Exclude patterns in configuration #{projectConfiguration.Name}: #{projectConfiguration.SourceExcludePatterns}"
    end

    def _ExcludeSourceModulesFromProjectConfiguration(sourceModules, projectConfiguration)
      sourceModules.each do |sourceModule|
	  projectConfiguration.SourceExcludePatterns.concat(sourceModule.SourcePatterns)
	  projectConfiguration.HeaderExcludePatterns.concat(sourceModule.HeaderPatterns)
      end
    end
  end
end
