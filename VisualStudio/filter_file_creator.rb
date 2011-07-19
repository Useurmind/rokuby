module RakeBuilder

  class FilterFileCreator < VsFileCreator
    def initialize
      super
      @headerBasefilter = "Headerfiles"
      @sourceBasefilter = "Sourcefiles"
      @resourceBasefilter = "Resourcefiles"
    end

    def GetFileName()
      return "#{@VsProject.ProjectName}.vcxproj.filters"
    end

    def BuildFile
      doc = {
        "ToolsVersion"=>"4.0", "xmlns"=>"http://schemas.microsoft.com/developer/msbuild/2003",
        "ItemGroup" => []
      }

      @itemGroups = doc['ItemGroup']

      @filters = []
      @includes = []
      @compiles = []
      @resources = []

      CreateSourceFilter()
      CreateHeaderFilter()
      CreateResourceFilter()

      CreateIncludes()
      CreateCompiles()
      CreateResources()

      @itemGroups.push GetMultiElementListForList({}, "Filter", @filters)
      @itemGroups.push GetMultiElementListForList({}, "CLInclude", @includes)
      @itemGroups.push GetMultiElementListForList({}, "CLCompile", @compiles)
      @itemGroups.push GetMultiElementListForList({}, "ResourceCompile", @resources)

      SaveXmlDocument(doc, @VsProject.FilterFilePath, @options)
    end

    def CreateSourceFilter

      sourceDirectories = @VsProject.GetSourceDirectoryTree()

      @filters.push GetElementForList(
        { "Include" => @sourceBasefilter},
        { "UniqueIdentifier" => GetUUID(),
          "Extensions" => "cpp;c;cc"})

      sourceDirectories.each { |directory|
        relativeDir = @VsProject.GetProjectRelativePath(directory)

        filter = JoinXmlPaths([@sourceBasefilter, relativeDir])

        @filters.push GetElementForList(
          { "Include" => filter},
          { "UniqueIdentifier" => GetUUID()})
      }
    end

    def CreateHeaderFilter

      includeDirectories = @VsProject.GetIncludeDirectoryTree()

      @filters.push GetElementForList(
        { "Include" => @headerBasefilter},
        { "UniqueIdentifier" => GetUUID(),
          "Extensions" => "h"})

      includeDirectories.each { |directory|
        relativeDir = @VsProject.GetProjectRelativePath(directory)

        filter = JoinXmlPaths([@headerBasefilter, relativeDir])

        @filters.push GetElementForList(
          { "Include" => filter},
          { "UniqueIdentifier" => GetUUID()})
      }
    end
    
    def CreateResourceFilter
      resourceDirectories = @VsProject.GetResourceDirectoryTree()

      @filters.push GetElementForList(
        { "Include" => @resourceBasefilter},
        { "UniqueIdentifier" => GetUUID(),
          "Extensions" => "rc"})

      resourceDirectories.each { |directory|
        relativeDir = @VsProject.GetProjectRelativePath(directory)

        filter = JoinXmlPaths([@resourceBasefilter, relativeDir])

        @filters.push GetElementForList(
          { "Include" => filter},
          { "UniqueIdentifier" => GetUUID()})
      }
    end

    def CreateIncludes
      extendedHeaderPaths = @VsProject.GetExtendedIncludes()

      extendedHeaderPaths.each { |headerfile|
        filter = JoinXmlPaths([@headerBasefilter, _GetProjectDirectoryRelativeBaseDirectory(headerfile)])
        relativeHeader = _GetVsProjectRelativePath(headerfile)
        
        @includes.push GetElementForList(
          {"Include" => relativeHeader},
          {"Filter" => filter}
        )
      }
    end

    def CreateCompiles
      extendedSourcePaths = @VsProject.GetExtendedSources()

      extendedSourcePaths.each { |sourcefile|
        filter = JoinXmlPaths([@sourceBasefilter, _GetProjectDirectoryRelativeBaseDirectory(sourcefile)])
        relativeSource = _GetVsProjectRelativePath(sourcefile)
        
        @compiles.push GetElementForList(
          {"Include" => relativeSource},
          {"Filter" => filter}
        )
      }
    end
    
    def CreateResources
      extendedResourcePaths = @VsProject.GetExtendedResources()

      extendedResourcePaths.each { |resourcefile|
        filter = JoinXmlPaths([@resourceBasefilter, _GetProjectDirectoryRelativeBaseDirectory(resourcefile)])
        relativeResource = _GetVsProjectRelativePath(resourcefile)

        @resources.push GetElementForList(
          {"Include" => relativeResource},
          {"Filter" => filter}
        )
      }
    end
  end

end