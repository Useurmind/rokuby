require "subproject"

module RakeBuilder
    # Class that gathers Subproject and VsProject attributes.
    class VsSubproject < VsProject
        attr_accessor :Task
        attr_accessor :Subproject
        
        def Name
            return @Name
        end
        
        def Name=(value)
            @Name = value
            @subproject.Name = value
        end
        
        def Folder
            return @subproject.Folder
        end
        
        def Folder=(value)
            @subproject.Folder = value
        end
        
        def BuildCommand
            return @subproject.BuildCommand
        end
        
        def BuildCommand=(value)
            @subproject.BuildCommand = value
        end
        
        def CleanCommand
            return @subproject.CleanCommand
        end
        
        def CleanCommand=(value)
            @subproject.Name = CleanCommand
        end
        
        def initialize
            @Subproject = Subproject.new()
        end
    end
end
