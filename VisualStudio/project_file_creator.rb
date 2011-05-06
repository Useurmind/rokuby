require "VisualStudio/vs_xml_file_utility.rb"

module RakeBuilder

  class CppProjectFileCreator < VsXmlFileUtility
    attr_accessor :Configurations
    attr_accessor :ProjectGuid
    attr_accessor :RootNamespace
    attr_accessor :ConfigurationType

    def initialize()
      super

      @Configurations = ["Release", "Debug"]
      @ConfigurationType = "Application"
    end

    def buildProjectFile()
      ExtendPaths()

      doc = {
        "DefaultTargets"=>"Build", "ToolsVersion"=>"4.0", "xmlns"=>"http://schemas.microsoft.com/developer/msbuild/2003",
        'ItemGroup' => [],
        'PropertyGroup' => [],
        'Import' => [],
        'ImportGroup' => [],
        'ItemDefinitionGroup' => []
      }

      @itemGroups = doc['ItemGroup'];
      @propertyGroups = doc["PropertyGroup"]
      @imports = doc["Import"]
      @importGroups = doc["ImportGroup"]
      @itemDefinitionGroups = doc["ItemDefinitionGroup"]

      CreateProjectConfigurations()
      CreateConfigurations()
      CreateHeaderElement()
      CreateSourceElement()

      CreateGlobals()
      CreateImports()
      CreateImportGroups()
      CreateItemDefinitionGroups()

      SaveXmlDocument(doc, "test.vcxproj")
    end


    def CreateGlobals()
      @propertyGroups.push(GetElementForList(
          { "Label" => "Globals"},
          { "ProjectGuid" => "{#{@ProjectGuid}}",
            "RootNamespace" => "#{@RootNamespace}"})
      )
    end

    def CreateItemDefinitionGroups
      @itemDefinitionGroups.push GetElementForList({"Condition" => GetConfigurationCondition("Debug", "Win32")}, {})
      @itemDefinitionGroups.push GetElementForList({"Condition" => GetConfigurationCondition("Release", "Win32")}, {})
    end

    def CreateImports()
      @imports.push GetElementForList({ "Project" => "$(VCTargetsPath)\\Microsoft.Cpp.Default.props"},{})
      @imports.push GetElementForList({ "Project" => "$(VCTargetsPath)\\Microsoft.Cpp.targets"},{})
      @imports.push GetElementForList({ "Project" => "$(VCTargetsPath)\\Microsoft.Cpp.props"},{})
    end

    def CreateImportGroups()
      @importGroups.push GetElementForList({ "Label" => "ExtensionTargets"},{})
      @importGroups.push GetElementForList({ "Label" => "ExtensionSettings"},{})
      @importGroups.push GetElementForList(
        { "Label" => "PropertySheets",
          "Condition" => GetConfigurationCondition("Debug", "Win32")},
        {}) #TODO
      @importGroups.push GetElementForList(
        { "Label" => "PropertySheets",
          "Condition" => GetConfigurationCondition("Release", "Win32")},
        {}) #TODO
    end

    def CreateProjectConfigurations()
      projectConfigurations = []
      @Configurations.each { |configuration|
        projectConfigurations.push GetElementForList(
          { "Include" => "#{configuration}|Win32"},
          { "Configuration" => configuration ,
            "Platform" => "Win32"}
        )
      }

      @itemGroups.push GetMultiElementListForList(
        {"Label" =>  "ProjectConfigurations"},
        "ProjectConfiguration", projectConfigurations
      )
    end

    def CreateConfigurations
      @propertyGroups.push GetElementForList(
        { "Condition" => GetConfigurationCondition("Debug", "Win32"), "Label"=>"Configuration"},
        { "ConfigurationType" => @ConfigurationType ,
          "UseDebugLibraries" => "true",
          "CharacterSet" => "MultiByte"
        }
      )
      @propertyGroups.push GetElementForList(
        { "Condition" => GetConfigurationCondition("Release", "Win32"), "Label"=>"Configuration"},
        { "ConfigurationType" => @ConfigurationType ,
          "UseDebugLibraries" => "false",
          "WholeProgramOptimization" => "true",
          "CharacterSet" => "MultiByte"
        }
      )
    end

    def CreateHeaderElement()
      itemList = []
      @HeaderFiles.each {|headerFile|
        pathToFile = FindFileInDirectories(headerFile, Dir.pwd, @IncludeDirectories)
        itemList.push GetElementForList({"Include" => pathToFile}, {})
      }

      @itemGroups.push GetMultiElementListForList({}, "ClInclude", itemList)
    end

    def CreateSourceElement()
      itemList = []
      @SourceFiles.each {|sourceFile|
        pathToFile = FindFileInDirectories(sourceFile, Dir.pwd, @SourceDirectories)
        itemList.push GetElementForList({"Include" => pathToFile}, {})
      }

      pathToPrecompiledHeader = FindFileInDirectories(@PrecompiledHeader, Dir.pwd, @SourceDirectories)
      itemList.push GetPrecompiledHeader(pathToPrecompiledHeader)
      @itemGroups.push GetMultiElementListForList({}, "ClCompile", itemList)
    end

    def GetPrecompiledHeader(preHeader)
      children = [
        GetElementForList({"Condition"=>GetConfigurationCondition("Debug", "Win32")}, {}),
        GetElementForList({"Condition"=>GetConfigurationCondition("Release", "Win32")}, {})
      ]
      preHeaderElement = GetMultiElementListForList({"Include" => preHeader}, "PrecompiledHeader", children)
      return preHeaderElement
    end

    def GetConfigurationCondition(configuration, platform)
      if(!@Configurations.include? configuration)
        raise "Configuration #{configuration} not available in this project"
      end

      return "'$(Configuration)|$(Platform)'=='#{configuration}|#{platform}'"
    end

  end

end