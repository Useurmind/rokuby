require "Subprojects/subproject"
require "directory_utility"
require "general_utility"

module RakeBuilder
    # Class that gathers Subproject and VsProject attributes.
    # Set all properties of VsProject to use it.
    class VsSubproject < VsProject
        attr_accessor :Subproject
        attr_accessor :BuildFolder
        
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
            @BuildDirectory = paramBag[:buildDirectory]
            @ProjectFilePath = JoinPaths( [ paramBag[:folder], (paramBag[:projectFilePath] or "VsSolution/#{@ProjectName}/#{@Name}.vcxproj") ] )
            @FilterFilePath = JoinPaths( [ paramBag[:folder], (paramBag[:filterFilePath] or "VsSolution/#{@ProjectName}/#{@Name}.vcxproj.filters") ] )
            @Guid = paramBag[:guid]
            @VsProjectConfigurations = (paramBag[:configurations] or [])
            
            paramBag[:resultFiles] = [@ProjectFilePath, @FilterFilePath]
            
            @Subproject = Subproject.new(paramBag)
        end
        
        # Copies all files in the build folder of the given configuration to the specified path.
        def CopyBuildResultsToPath(configurationName, path)
            configs = project.VsProjectConfigurations.select do |config|
                return (configuration.Name.eql? config.Name)
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
