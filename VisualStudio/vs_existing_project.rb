module RakeBuilder
    class VsExistingProject
        include VsXmlFileUtility
        
        attr_accessor :Project
        attr_accessor :Folder
        
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
        def VsProjectConfigurations
            @Project.VsProjectConfigurations
        end
        def Dependencies
            [] # TODO: this is not implemented yet
        end
        def RootNamespace
            @Project.RootNamespace
        end
        
        # [project] The existing VsProject instance for this project.
        # [folder] The folder where the project is located (for subprojects e.g. the subfolder).
        def initialize(paramBag)
            @Project = paramBag[:project]
            @Folder = paramBag[:folder]
        end
    end
end
