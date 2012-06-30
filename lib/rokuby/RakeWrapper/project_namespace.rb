module Rokuby
  # Each project file creates an own namespace in which tasks are saved and can
  # be addressed with.
  class ProjectNamespace
    attr_accessor :Parts
    
    def initialize()
      @Parts = []
    end
    
    # Set the project path that refers to the project file this namespace describes.
    def SetProjectPath(path)
      #puts "Setting proect path " + path.to_s
      pathParts = path.RelativePath().split("/")
      @Parts = pathParts[0..-2]
    end
    
    # Does this namespace include another namespace.
    def Includes?(namespace)
      if(@Parts.length > namespace.length)
        return false
      end
      
      for i in 0..@Parts.length-2 do
        if(@Parts[i] != namespace.Parts[i])
          return false
        end
      end
      
      return true
    end
  end
end
