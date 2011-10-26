module RakeBuilder
  class ProjectNamespace
    attr_accessor :Parts
    
    def initialize()
      @Parts = []
    end
    
    def SetProjectPath(path)
      pathParts = path.RelativePath.split("/")
      @Parts = pathParts[0..-2]
    end
    
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
