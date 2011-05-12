require "VisualStudio/vs_file_creator.rb"

module RakeBuilder

  class FilterFileCreator < VsFileCreator
    def initialize
      super
      @headerBasefilter = "Headerfiles"
      @sourceBasefilter = "Sourcefiles"
    end

    def GetFileName()
      return "#{@ProjectConfiguration.ProjectName}.vcxproj.filters"
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

      CreateSourceFilter()
      CreateHeaderFilter()

      CreateIncludes()
      CreateCompiles()

      @itemGroups.push GetMultiElementListForList({}, "Filter", @filters)
      @itemGroups.push GetMultiElementListForList({}, "CLInclude", @includes)
      @itemGroups.push GetMultiElementListForList({}, "CLCompile", @compiles)

      SaveXmlDocument(doc, GetFilePath(), @options)
    end

    def CreateSourceFilter

      sourceDirectories = @ProjectConfiguration.GetSourceDirectoryTree()

      @filters.push GetElementForList(
        { "Include" => @sourceBasefilter},
        { "UniqueIdentifier" => GetUUID(),
          "Extensions" => "cpp;c;cc"})

      sourceDirectories.each { |directory|
        relativeDir = @ProjectConfiguration.GetProjectRelativePath(directory)

        filter = JoinXmlPaths([@sourceBasefilter, relativeDir])

        @filters.push GetElementForList(
          { "Include" => filter},
          { "UniqueIdentifier" => GetUUID()})
      }
    end

    def CreateHeaderFilter

      includeDirectories = @ProjectConfiguration.GetIncludeDirectoryTree()

      @filters.push GetElementForList(
        { "Include" => @headerBasefilter},
        { "UniqueIdentifier" => GetUUID(),
          "Extensions" => "cpp;c;cc"})

      includeDirectories.each { |directory|
        relativeDir = @ProjectConfiguration.GetProjectRelativePath(directory)

        filter = JoinXmlPaths([@headerBasefilter, relativeDir])

        @filters.push GetElementForList(
          { "Include" => filter},
          { "UniqueIdentifier" => GetUUID()})
      }
    end

    def CreateIncludes
      extendedHeaderPaths = @ProjectConfiguration.GetExtendedIncludes()

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
      extendedSourcePaths = @ProjectConfiguration.GetExtendedSources()

      extendedSourcePaths.each { |sourcefile|
        filter = JoinXmlPaths([@sourceBasefilter, _GetProjectDirectoryRelativeBaseDirectory(sourcefile)])
        relativeSource = _GetVsProjectRelativePath(sourcefile)

        @compiles.push GetElementForList(
          {"Include" => relativeSource},
          {"Filter" => filter}
        )
      }
    end
  end

end