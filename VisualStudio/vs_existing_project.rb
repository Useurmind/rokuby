module RakeBuilder
    # This class represents an existing VSProject in a subfolder(subproject) of the current project.
    # With this class it is possible to include subprojects that also use the RakeBuilder into a higher
    # level project that needs to compile these subprojects.
    # What it does is essentially to prepend the subfolder where the project is located in front of pathes
    # where this is necessary.
    # It offers a similar interface as VSProject.
    class VsExistingProject
        include GeneralUtility
        include VsXmlFileUtility
        
        attr_accessor :Project
        attr_accessor :Folder        
        def VsProjectConfigurations
            if(!@VsProjectConfigurations)
                SyncConfigurationsWithProject()
            end
            @VsProjectConfigurations
        end
            
        def Libraries
            if(!@Libraries)
                SyncLibrariesWithProject()
            end
            @Libraries
        end
        
        def Name
            @Project.Name
        end
        def ProjectFilePath
            JoinXmlPaths([@Folder, @Project.ProjectFilePath])
        end
        def FilterFilePath
            JoinXmlPaths([@Folder, @Project.FilterFilePath])
        end
        def Guid
            @Project.Guid
        end
        def Dependencies
            [] # TODO: this is not implemented yet
        end
        def RootNamespace
            @Project.RootNamespace
        end

        # TODO: This should be refactored
        def BuildDirectoryExtra(configurationName)
          ConvertPath(@Project.GetVsConfiguration(configurationName).GetFinalBuildDirectory())
        end

        # TODO: This should be refactored
        def IncludePathsExtra
          includeTree = nil
          ExecuteInFolder(@Folder) do
            includeTree = @Project.GetIncludeDirectoryTree()
          end
          
          convertedTree = []
          includeTree.each do |path|
            convertedTree.push(ConvertPath(path))
          end
          return convertedTree
        end
        
        # [project] The existing VsProject instance for this project.
        # [folder] The folder where the project is located (for subprojects e.g. the subfolder).
        def initialize(paramBag)
            @Project = paramBag[:project]
            @Folder = paramBag[:folder]
            
        end
        
        def SyncLibrariesWithProject
            @Libraries = []
            @Project.Libraries.each do |libContainer|
	      if(!libContainer.UsedInWindows())
		return libContainer
	      end
                @Libraries.push(ConvertLibContainerPaths(libContainer))
            end
        end
        
        def SyncConfigurationsWithProject            
            @VsProjectConfigurations = []
            @Project.VsProjectConfigurations.each do |configuration|
                @VsProjectConfigurations.push(ConvertConfigurationPaths(configuration))
            end
        end
        
        def ConvertLibContainerPaths(libContainer)	  
            libFactory = LibraryContainerFactory.new()
            newHeaderPaths = []
            libContainer.GetHeaderPaths(:Windows).each do |headerPath|
                newHeaderPaths.push(ConvertPath(headerPath))
            end
            if(libContainer.GetLibraryPath(:Windows) != nil)
                newLibraryPath = ConvertPath(libContainer.GetLibraryPath(:Windows))
            end
            
            
            newLibContainer = libFactory.CreateLibraryContainerFromLibraryObjects([
                WindowsLib.new({
                    name: libContainer.GetName(:Windows),
                    libraryPath: newLibraryPath,
                    headerPaths: newHeaderPaths,
                    copyFileName: libContainer.GetCopyFileName(:Windows)
                })
            ])
            
            return newLibContainer
        end
        
        def ConvertConfigurationPaths(configuration)
            newConfiguration = Clone(configuration)
            newConfiguration.AdditionalIncludeDirectories = []
            configuration.AdditionalIncludeDirectories.each do |includeDirectory|
                newConfiguration.AdditionalIncludeDirectories.push(ConvertProjectRelativePath(includeDirectory))
            end
            return newConfiguration
        end
        
        def ConvertPath(path)
            return JoinPaths([ @Folder, path ])
        end
        
        def ConvertProjectRelativePath(path)
            # search the first non .. in path and insert Folder after it
            pathParts = path.split(/\\/)
            index = 0
            for index in 0..pathParts.length-1
                if(pathParts[index] != "..")
                    break
                end
            end
            pathParts.insert(index, @Folder)
            return JoinXmlPaths(pathParts)
        end
    end
end
