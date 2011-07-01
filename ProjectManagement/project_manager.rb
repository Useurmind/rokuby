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
  # [DoxygenBuilder] The class object that is responsible for creating the doxygen documentation.
  #
  # Tasks provided by the project manager:
  # [DocuTask] The task to build the docu of the project.
  # [PacketInstallTask] The task that will install the packets for ubuntu OS needed for the project.
  # [CreateVSSolutionTask] The task that will create the VisualStudio solution for this project.
  # [CleanVSSolutionTask] The task that will delete the VisualStudio solution for this project.
  # [GccBuildTask] The task that will build this project with the gcc compiler
  class ProjectManager
    include GeneralUtility

    attr_accessor :BaseProjectConfiguration
    attr_accessor :SourceModules
    attr_accessor :SourceModuleUsage 
    attr_accessor :LinuxCompileOrders
    attr_accessor :CompileOrderDescriptions
    attr_accessor :VsSolutionCreator
    attr_accessor :DefaultTargetName
    attr_accessor :DoxygenBuilder
    attr_accessor :SubprojectManagers
    
    attr_accessor :DocuTask
    attr_accessor :PacketInstallTask
    attr_accessor :CreateVSSolutionTask
    attr_accessor :CleanVSSolutionTask
    attr_accessor :GccBuildTask
    
    def ProjectName
      @BaseProjectConfiguration.ProjectName
    end

    def GetVsProject(name)
      searchedProject = nil
      @VsSolutionCreator.VsSolution.Projects.each do |project|
	if(project.ProjectName == name)
	  searchedProject = project
	  break
	end
      end
      return searchedProject
    end

    def initialize(baseProjectConfiguration, vsSolution)
      @BaseProjectConfiguration = baseProjectConfiguration
      @SourceModules = {}
      @SourceModuleUsage = {}
      @LinuxCompileOrders = {}
      @CompileOrderDescriptions = {}
      @VsSolutionCreator = VsSolutionCreator.new(vsSolution)

      @DoxygenBuilder = DoxygenBuilder.new()
      @DoxygenBuilder.ProjectConfiguration = baseProjectConfiguration
      
      @SubprojectManagers = []

      @UbuntuPacketInstaller = UbuntuPacketInstaller.new()
      
      @DocuTask = GenerateTaskName({
	projectName: ProjectName(),
	type: "DocuTask"
      })
      @PacketInstallTask = GenerateTaskName({
	projectName: ProjectName(),
	type: "PacketInstallTask"
      })
      @CreateVSSolutionTask = GenerateTaskName({
	projectName: ProjectName(),
	type: "CreateVSSolutionTask"
      })
      @CleanVSSolutionTask = GenerateTaskName({
	projectName: ProjectName(),
	type: "CleanVSSolutionTask"
      })
      @GccBuildTask = GenerateTaskName({
	projectName: ProjectName(),
	type: "GccBuildTask"
      })
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
      @SubprojectManagers.each do |subprojectManager|
	subprojectManager.CreateTasks()
	
	task @DocuTask => [subprojectManager.DocuTask]
	task @PacketInstallTask => [subprojectManager.PacketInstallTask]
	task @CreateVSSolutionTask => [subprojectManager.CreateVSSolutionTask]
	task @CleanVSSolutionTask => [subprojectManager.CleanVSSolutionTask]
	task @GccBuildTask => [subprojectManager.GccBuildTask]
      end
      
      _ApplySourceModuleUsageToCompileOrders()
      _ApplySourceModuleUsageToVsProjectConfigurations()

      task @DocuTask do
        @DoxygenBuilder.CreateDoxyfile()
      end

      @UbuntuPacketInstaller.CreatePacketInstallationTask()
      task @PacketInstallTask => [@UbuntuPacketInstaller.TaskName]

      @LinuxCompileOrders.each do |name, compileOrder|
        compileOrder.CreateProjectTasks()
        compilerOrderTaskName = GenerateTaskName({
	  projectName: ProjectName(),
	  configuration: compileOrder.ProjectConfiguration.Name,
	  type: "CompileOrderTask"
	})
        task compilerOrderTaskName => [compileOrder.EndTask]
      end
      
      @VsSolutionCreator.CreateTasks()
      task @CreateVSSolutionTask => @VsSolutionCreator.EndTask

      task @CleanVSSolutionTask => @VsSolutionCreator.CleanTask

      _CheckCompileOrderExists(@DefaultTargetName)
      task @GccBuildTask => [@LinuxCompileOrders[@DefaultTargetName].ProjectConfiguration.Name]
    end
      
    def AssignDefaultTasks
      task :docu => [@DocuTask]
      task :vssolution => [@CreateVSSolutionTask]
      task :cleanvssolution => [@CleanVSSolutionTask]
      task :gccbuild => [@GccBuildTask]
      task :installpackets => [@PacketInstallTask]
      
      DescribeTasks({
	docuTask: :docu,
	packetInstallTask: :installpackets,
	createVSSolutionTask: :vssolution,
	cleanVSSolutionTask: :cleanvssolution,
	gccBuildTask: :gccbuild
      })
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
		
	  _ApplySourceModuleUsageToProjectConfiguration(compileOrder.ProjectConfiguration, modulesToUse, :Linux)
      end
    end
    
    def _ApplySourceModuleUsageToVsProjectConfigurations
      @VsSolutionCreator.VsSolution.Projects.each do |project|
	project.VsProjectConfigurations.each do |configuration|
	  modulesToUse = _GetSourceModulesToUse(configuration)
		
	  _ApplySourceModuleUsageToProjectConfiguration(configuration, modulesToUse, :Windows)
	end
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
    
    def _ApplySourceModuleUsageToProjectConfiguration(projectConfiguration, modulesToUse, os)
	modulesToUse.each do |sourceModule|
	    projectConfiguration.AddLibraries(sourceModule.AssociatedLibraries, os)
	    if(sourceModule.Define)
		projectConfiguration.Defines.push(sourceModule.Define)
	    end
	end  	  
	modulesNotToUse = @SourceModules.values() - modulesToUse
	_ExcludeSourceModulesFromProjectConfiguration(modulesNotToUse, projectConfiguration)
    end

    def _ExcludeSourceModulesFromProjectConfiguration(sourceModules, projectConfiguration)
      sourceModules.each do |sourceModule|
	  projectConfiguration.SourceExcludePatterns.concat(sourceModule.SourcePatterns)
	  projectConfiguration.HeaderExcludePatterns.concat(sourceModule.HeaderPatterns)
      end
    end
  end
end
