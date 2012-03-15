module RakeBuilder
  # This class represents a visual studio project.
  # [ProjectFileSet] A file set representing the project file of the project.
  # [FilterFileSet] A file set representing the filter file of the project.
  class VsProject < Project
    attr_accessor :ProjectFileSet
    attr_accessor :FilterFileSet
    
    def initialize(valueMap=nil)
      
      @ProjectFileSet = FileSet.new()
      @FilterFileSet = FileSet.new()
      
      super(valueMap)
      Extend(valueMap, false)
    end
    
    def initialize_copy(original)
      super(original)
      
      @ProjectFileSet = Clone(original.ProjectFileSet)
      @FilterFileSet = Clone(original.FilterFileSet)
    end
    
    def Extend(valueMap, callParent=true)
      if(valueMap == nil)
        return
      end
      
      if(callParent)
        super(valueMap)
      end
      
      projectFileSet = valueMap[:ProjectFileSet] || valueMap[:projFileSet]
      if(projFileSet)
        @ProjectFileSet = projectFileSet
      end
      
      filterFileSet = valueMap[:FilterFileSet] || valueMap[:filterFileSet]
      if(filterFileSet)
        @FilterFileSet = filterFileSet
      end
    end
  end
end
