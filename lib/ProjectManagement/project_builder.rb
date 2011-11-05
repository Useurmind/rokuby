module RakeBuilder
    # Base functionality to implement recursive subprojects.
    # This interface should be implemented by classes that create the necessary tasks to build a project.
    # The next higher project can use this interface to reuse the project configuration of subprojects.
    class ProjectBuilder
        attr_accessor :ProjectManager
        
        # This functions creates the necessary objects to create the tasks for the project.
        def CreateProjectDefinition
        end
    end
end
