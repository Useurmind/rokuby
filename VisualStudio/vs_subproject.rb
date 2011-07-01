module RakeBuilder
    # Class that gathers Subproject and VsProject attributes.
    # Set all properties of VsProject to use it.
    class VsSubproject < VsProject
        attr_accessor :Subproject
        attr_accessor :BuildFolder
        attr_accessor :CleanVisualStudioCommand
        attr_accessor :CleanVisualStudioTask
        
        def Folder
            return @Subproject.Folder
        end
        
        def BuildCommand
            return @Subproject.BuildCommand
        end
        
        def CleanCommand
            return @Subproject.CleanCommand
        end
        
        def ResultFiles
            return @Subproject.ResultFiles
        end
        
        def AfterBuildTask
            return @Subproject.AfterBuildTask
        end
        
        def GetResultFilePaths
            return @Subproject.GetResultFilePaths()
        end
        
        # [name] Name of the subproject.
        # [cleanVisualStudioCommand] Command to execute to remove Visual Studio project.
        #
        # VsProject properties needed:
        # [projectFilePath] Path to the project file relative to the subproject folder.
        # [filterFilePath] Path to the filter file relative to the subproject folder.
        # [buildDirectory] The subdirectory where the builds of the project are placed.
        # [guid] The UUID of the project in the form '{45CD..}'.
        # [configurations] The VsProjectConfigurations for the project (only the Name, Platform must be set).
        #
        # Subproject properties needed:
        # [folder] see Folder in Subproject.
        # [buildCommand] see BuildCommand in Subproject.
        # [cleanCommand] see CleanCommand in Subproject.
        def initialize(paramBag = {})
            super()
            
            
            @Name = paramBag[:name]
            @ProjectName = paramBag[:name]
            projectFile = (paramBag[:projectFilePath] or "VsSolution/#{@ProjectName}/#{@Name}.vcxproj")
            filterFile = (paramBag[:filterFilePath] or "VsSolution/#{@ProjectName}/#{@Name}.vcxproj.filters")
            @BuildDirectory = paramBag[:buildDirectory]
            @ProjectFilePath = JoinPaths( [ paramBag[:folder], projectFile ] )
            @FilterFilePath = JoinPaths( [ paramBag[:folder], filterFile ] )
            @Guid = paramBag[:guid]
            @VsProjectConfigurations = (paramBag[:configurations] or [])
            @CleanVisualStudioCommand = (paramBag[:cleanVisualStudioCommand] or "rake CleanVisualStudio")
            
            paramBag[:resultFiles] = [projectFile, filterFile]
            
            @Subproject = Subproject.new(paramBag)
            
            @CleanVisualStudioTask = GenerateTaskName({
                projectName: @ProjectName,
                type: "SubprojectCleanVsTask"
            })
            
            originalDir = Dir.pwd
            subdir = JoinPaths([ originalDir, Folder() ])
            
            task @CleanVisualStudioTask do                
                Dir.chdir(subdir)
                SystemWithFail(@CleanVisualStudioCommand, "Could not clean subproject #{@ProjectName}")
                Dir.chdir(originalDir)
            end
        end
        
        # Copies all files in the build folder of the given configuration to the specified path.
        def CopyBuildResultsToPath(configurationName, path)
            configs = @VsProjectConfigurations.select do |config|
                return (configurationName.eql? config.Name)
            end
            
            if(configs.length == 0)
                puts "WARNING: No configuration with the name #{configurationName} was found in subproject #{@Name}. Doing nothing."
                return
            end
            
            buildFolder = JoinPaths( [ @Subproject.Folder, configs[0].GetFinalBuildDirectory() ])
            
            cp_r(buildFolder, path)
        end
    end
end
