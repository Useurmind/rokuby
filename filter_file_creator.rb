require "vs_xml_file_utility.rb"

module RakeBuilder

  class CppFilterFileCreator < VsXmlFileUtility
    attr_accessor :includes
    attr_accessor :compiles

    def initialize
      super
    end

    def buildFilterFile
      ExtendPaths()

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

      SaveXmlDocument(doc, "test.vcxproj.filters")
    end

    def CreateSourceFilter
      baseFilter = "Sourcefiles"

      @filters.push GetElementForList(
        { "Include" => baseFilter},
        { "UniqueIdentifier" => GetUUID(),
          "Extensions" => "cpp;c;cc"})

      @SourceDirectories.each { |directory|
        @filters.push GetElementForList(
          { "Include" => "#{baseFilter}\\#{directory}"},
          { "UniqueIdentifier" => GetUUID()})
      }
    end

    def CreateHeaderFilter
      baseFilter = "Headerfiles"

      @filters.push GetElementForList(
        { "Include" => baseFilter},
        { "UniqueIdentifier" => GetUUID(),
          "Extensions" => "cpp;c;cc"})

      @IncludeDirectories.each { |directory|
        @filters.push GetElementForList(
          { "Include" => "#{baseFilter}\\#{directory}"},
          { "UniqueIdentifier" => GetUUID()})
      }
    end

    def CreateIncludes
      @ExtendedHeaderPaths.each { |headerfile|
        @includes.push GetElementForList(
          {"Include" => headerfile},
          {"Filter" => "Headerfiles"}
        )
      }
    end

    def CreateCompiles
      @ExtendedSourcePaths.each { |sourcefile|
        @compiles.push GetElementForList(
          {"Include" => sourcefile},
          {"Filter" => "Headerfiles"}
        )
      }
    end

    def GetUUID
      return "\{#{UUIDTools::UUID.random_create().to_s}\}"
    end
  end

end