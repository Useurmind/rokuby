module RakeBuilder
    
    # Class that wraps a project manager of a subproject.
    # The tasks that this class returns wraps all the tasks of the subproject manager so that they can be executed from the current projects directory.
    class SubprojectManager
        include DirectoryUtility
        include GeneralUtility
        
        attr_accessor :ProjectManager
        attr_accessor :Folder
    
        def ProjectName
          @BaseProjectConfiguration.ProjectName
        end
        
        def BaseProjectConfiguration
            ProjectManager.BaseProjectConfiguration
        end
        def SourceModules
            ProjectManager.SourceModules
        end
        def SourceModuleUsage 
            ProjectManager.SourceModuleUsage
        end
        def LinuxCompileOrders
            ProjectManager.LinuxCompileOrders
        end
        def CompileOrderDescriptions
            ProjectManager.CompileOrderDescriptions
        end
        def VsSolutionCreator
            ProjectManager.VsSolutionCreator
        end
        def DefaultTargetName
            ProjectManager.DefaultTargetName
        end
        def DoxygenBuilder
            ProjectManager.DoxygenBuilder
        end
        def SubprojectManager
            ProjectManager.SubprojectManager
        end
        
        attr_accessor :DocuTask
        attr_accessor :PacketInstallTask
        attr_accessor :CreateVSSolutionTask
        attr_accessor :CleanVSSolutionTask
        attr_accessor :GccBuildTask
        
        # [projectManager] The project manager of the subproject.
        # [folder] The folder in which the subproject is located.
        def initialize(paramBag)
            @ProjectManager = paramBag[:projectManager]
            @Folder = paramBag[:folder]
            
            @DocuTask = GenerateTaskName({
                projectName: ProjectName(),
                type: "WrappedDocuTask"
            })
            @PacketInstallTask = GenerateTaskName({
                projectName: ProjectName(),
                type: "WrappedPacketInstallTask"
            })
            @CreateVSSolutionTask = GenerateTaskName({
                projectName: ProjectName(),
                type: "WrappedCreateVSSolutionTask"
            })
            @CleanVSSolutionTask = GenerateTaskName({
                projectName: ProjectName(),
                type: "WrappedCleanVSSolutionTask"
            })
            @GccBuildTask = GenerateTaskName({
                projectName: ProjectName(),
                type: "WrappedGccBuildTask"
            })
        end
        
        def CreateTasks()
            ExecuteInFolder(@Folder) do
                @ProjectManager.CreateTasks()
            end
            
            task @DocuTask do
                ExecuteInFolder(@Folder) do
                    Rake::Tasks[ProjectManager.DocuTask].invoke()
                end
            end
            
            task @PacketInstallTask do
                ExecuteInFolder(@Folder) do
                    Rake::Tasks[ProjectManager.PacketInstallTask].invoke()
                end
            end
            
            task @CreateVSSolutionTask do
                ExecuteInFolder(@Folder) do
                    Rake::Tasks[ProjectManager.CreateVSSolutionTask].invoke()
                end
            end
            
            task @CleanVSSolutionTask do
                ExecuteInFolder(@Folder) do
                    Rake::Tasks[ProjectManager.CleanVSSolutionTask].invoke()
                end
            end
            
            task @GccBuildTask do
                ExecuteInFolder(@Folder) do
                    Rake::Tasks[ProjectManager.GccBuildTask].invoke()
                end
            end
        end
    end
end
