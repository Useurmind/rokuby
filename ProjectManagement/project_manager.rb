
require "ProjectManagement/source_module"
require "ProjectManagement/cpp_project_configuration"
require "doxygen_builder"
require "Linux/ubuntu_packet_installer"

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
      @WindowsSolutionCreators = {}

      @DoxygenBuilder = DoxygenBuilder.new()
      @DoxygenBuilder.ProjectConfiguration = baseProjectConfiguration

      @UbuntuPacketInstaller = UbuntuPacketInstaller.new()
    end

    def AddUbuntuPacketInstallations(packetNames)
      @UbuntuPacketInstaller.PacketNames.concat(packetNames)
    end

    def AddSourceModule(name, sourceModule)
      if(@SourceModules[name] != nil)
        abort "The module #{name} is already present in the ProjectManager"
      end
      @SourceModules[name] = sourceModule
    end

    def AddLinuxCompileOrder(name, compileOrder, description)
      _CheckCompileOrderNotExists(name)

      compileOrder.ProjectConfiguration = @BaseProjectConfiguration
      @LinuxCompileOrders[name] = compileOrder
      @CompileOrderDescriptions[name] = description
    end

    def AddWindowsSolutionCreator(name, solutionCreator)
      if(@WindowsSolutionCreators[name] != nil)
        abort "The solution creator #{name} is already present in the ProjectManager"
      end
      @WindowsSolutionCreators[name] = solutionCreator
    end

    def CopyLinuxCompileOrder(name, copyName, description)
      _CheckCompileOrderExists(name)
      _CheckCompileOrderNotExists(copyName)

      copyCompileOrder = @LinuxCompileOrders[name].clone()
      @LinuxCompileOrders[copyName] = copyCompileOrder
      @CompileOrderDescriptions[copyName] = description
      copyCompileOrder.ProjectConfiguration.Name = copyName
      copyCompileOrder.ProjectConfiguration.BinaryName = copyName

      return copyCompileOrder
    end

    def CreateTasks()
      _ModifyForSourceModuleUsage()

      @DoxygenBuilder.CreateDoxyfile()
      desc "Build the doxygen documentation of the project"
      task :docu do
        @DoxygenBuilder.CreateDoxyfile()
      end

      @UbuntuPacketInstaller.CreatePacketInstallationTask()
      desc "Install required ubuntu packets"
      task :packets => [@UbuntuPacketInstaller.TaskName]

      @LinuxCompileOrders.each do |compileOrder|
        compileOrder.CreateProjectTasks()
        task compileOrder.ProjectConfiguration.Name => [compileOrder.EndTask]
      end

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

    def _ModifyForSourceModuleUsage
      @SourceModules.each do |name,sourceModule|
        usage = @SourceModuleUsage[sourceModule]
        if(usage == nil)
          #default is not using the module at all
          _ExcludeSourceModuleFromCompileOrders(sourceModule, @LinuxCompileOrders.values())
        else
          _SetUsageOfModule(usage, sourceModule)
        end
      end
    end

    def _ExcludeSourceModuleFromCompileOrders(sourceModule, compileOrders)
      compileOrders.each do |compileOrder|
        compileOrder.ProjectConfiguration.SourceExcludePatterns.concat(sourceModule.SourcePatterns)
        compileOrder.ProjectConfiguration.HeaderExcludePatterns.concat(sourceModule.HeadersPatterns)
      end
    end

    def _SetUsageOfModule(usage, sourceModule)
      compileOrdersToExcludeModuleFrom = []
      @LinuxCompileOrders.each do |name, compileOrder|
        if(usage[name] == nil)
          compileOrdersToExcludeModuleFrom.push(compileOrder)
        end
      end
      _ExcludeSourceModuleFromCompileOrders(sourceModule, compileOrdersToExcludeModuleFrom)
    end
  end
end
