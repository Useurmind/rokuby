module RakeBuilder
    # A container for a Visual Studio solution.
    # [SolutionDirectory] The directory under base directory where to put the solution.
    # [SolutionName] The name of the solution.
    # [Projects] The projects contained in the solution. Can be VsProject or VsSubproject.
    class VsSolution
        attr_accessor :SolutionDirectory
        attr_accessor :SolutionName
        attr_accessor :Projects
        
        def initialize
            @SolutionDirectory = "VsSolution"
            @SolutionName = "MySolution"
            @Projects = []
        end
    end
end
