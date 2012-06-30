module Rokuby

  class FilterFileCreator < VsFileCreator
    def initialize
      super
      @headerBasefilter = "Headerfiles"
      @sourceBasefilter = "Sourcefiles"
      @resourceBasefilter = "Resourcefiles"
      @idlBasefilter = "Idl"
    end

    def GetFilePath()
      return @VsProjectDescription.FilterFilePath
    end

    def BuildFile
      _JoinSourceUnits()
      
      doc = {
        "ToolsVersion"=>"4.0", "xmlns"=>"http://schemas.microsoft.com/developer/msbuild/2003",
        "ItemGroup" => []
      }

      @itemGroups = doc['ItemGroup']

      @filters = []
      @includes = []
      @compiles = []
      @resources = []
      @idls = []

      CreateSourceFilter()
      CreateHeaderFilter()
      CreateResourceFilter()
      CreateIdlFilter()

      CreateIncludes()
      CreateCompiles()
      CreateResources()
      CreateIdls()

      @itemGroups.push GetMultiElementListForList({}, "Filter", @filters)
      @itemGroups.push GetMultiElementListForList({}, "CLInclude", @includes)
      @itemGroups.push GetMultiElementListForList({}, "CLCompile", @compiles)
      @itemGroups.push GetMultiElementListForList({}, "ResourceCompile", @resources)
      @itemGroups.push GetMultiElementListForList({}, "Midl", @idls)

      CreateFileDirectory()
      SaveXmlDocument(doc, GetFilePath().AbsolutePath(), @options)
    end

    def CreateSourceFilter
      
      @filters.push GetElementForList(
        { "Include" => @sourceBasefilter},
        { "UniqueIdentifier" => GetUUID(),
          "Extensions" => "cpp;c;cc;cxx"})

      #This tree should be relative to the normal project directory, e.g. begin with 'src'
      sourceDirectoryTree = []
      @SourceUnit.SourceFileSet.RootDirectories.each() do |rootPath|
        pathTree = GetDirectoryTreeFromRelativeBase(rootPath, [], true)
        
        pathTree.each() do |path|
          sourceDirectoryTree.push(path.RelativePath)
        end
      end
      
      sourceDirectoryTree.uniq().each() do |directory|
        filter = JoinXmlPaths([@sourceBasefilter, directory])

        @filters.push GetElementForList(
          { "Include" => filter},
          { "UniqueIdentifier" => GetUUID()})
      end
    end

    def CreateHeaderFilter
      @filters.push GetElementForList(
        { "Include" => @headerBasefilter},
        { "UniqueIdentifier" => GetUUID(),
          "Extensions" => "h;hpp;hxx"})
      
      #This tree should be relative to the normal project directory, e.g. begin with 'src'
      includeDirectoryTree = []
      @SourceUnit.IncludeFileSet.RootDirectories.each() do |rootPath|
        pathTree = GetDirectoryTreeFromRelativeBase(rootPath, [], true)
        
        pathTree.each() do |path|
          includeDirectoryTree.push(path.RelativePath)
        end
      end
      
      includeDirectoryTree.uniq().each() do |directory|
        filter = JoinXmlPaths([@headerBasefilter, directory])

        @filters.push GetElementForList(
          { "Include" => filter},
          { "UniqueIdentifier" => GetUUID()})
      end
    end
    
    def CreateResourceFilter
      @filters.push GetElementForList(
        { "Include" => @resourceBasefilter},
        { "UniqueIdentifier" => GetUUID(),
          "Extensions" => "rc"})

      #This tree should be relative to the normal project directory, e.g. begin with 'src'
      resourceDirectoryTree = []
      @ResourceFileSet.RootDirectories.each() do |rootPath|
        pathTree = GetDirectoryTreeFromRelativeBase(rootPath, [], true)
        
        pathTree.each() do |path|
          resourceDirectoryTree.push(path.RelativePath)
        end
      end
      
      resourceDirectoryTree.uniq().each() do |directory|
        filter = JoinXmlPaths([@resourceBasefilter, directory])

        @filters.push GetElementForList(
          { "Include" => filter},
          { "UniqueIdentifier" => GetUUID()})
      end
    end
    
    def CreateIdlFilter
      @filters.push GetElementForList(
        { "Include" => @idlBasefilter},
        { "UniqueIdentifier" => GetUUID(),
          "Extensions" => "idl;h;hpp;hxx;c;cpp;cxx;cc"})

      idlDirectoryTree = []
      @IdlFileSet.RootDirectories.each() do |rootPath|
        pathTree = GetDirectoryTreeFromRelativeBase(rootPath, [], true)
        
        pathTree.each() do |path|
          idlDirectoryTree.push(path.RelativePath)
        end
      end
      
      idlDirectoryTree.uniq().each() do |directory|
        filter = JoinXmlPaths([@idlBasefilter, directory])

        @filters.push GetElementForList(
          { "Include" => filter},
          { "UniqueIdentifier" => GetUUID()})
      end
    end

    def CreateIncludes
      headerPaths = @SourceUnit.IncludeFileSet.FilePaths

      headerPaths.uniq().each do |headerPath|
        filter = JoinXmlPaths([@headerBasefilter, headerPath.RelativeDirectory])
        relativeHeader = _GetVsProjectRelativePath(headerPath).RelativePath
        
        @includes.push GetElementForList(
          {"Include" => relativeHeader},
          {"Filter" => filter}
        )
      end
    end

    def CreateCompiles
      sourcePaths = @SourceUnit.SourceFileSet.FilePaths

      sourcePaths.uniq().each do |sourcePath|
        filter = JoinXmlPaths([@sourceBasefilter, sourcePath.RelativeDirectory])
        relativeSource = _GetVsProjectRelativePath(sourcePath).RelativePath
        
        @compiles.push GetElementForList(
          {"Include" => relativeSource},
          {"Filter" => filter}
        )
      end
    end
    
    def CreateResources
      resourcePaths = @ResourceFileSet.FilePaths

      resourcePaths.uniq().each do |resourcePath|
        filter = JoinXmlPaths([@resourceBasefilter, resourcePath.RelativeDirectory])
        relativeResource = _GetVsProjectRelativePath(resourcePath).RelativePath
        
        @resources.push GetElementForList(
          {"Include" => relativeResource},
          {"Filter" => filter}
        )
      end
    end
    
    def CreateIdls
      idlPaths = @IdlFileSet.FilePaths

      idlPaths.uniq().each do |idlPath|
        filter = JoinXmlPaths([@idlBasefilter, idlPath.RelativeDirectory])
        relativeIdl = _GetVsProjectRelativePath(idlPath).RelativePath
        idlFilename = idlPath.FileName(false)
        
        @idls.push GetElementForList(
          {"Include" => relativeIdl},
          {"Filter" => filter}
        )
      end
    end
  end

end
