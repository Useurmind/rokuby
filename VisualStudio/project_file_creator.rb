require "VisualStudio/vs_file_creator.rb"
require "VisualStudio/vs_project_configuration.rb"

module RakeBuilder

  class ProjectFileCreator < VsFileCreator
    attr_accessor :ProjectConfigurations
    attr_accessor :ProjectGuid
    attr_accessor :RootNamespace

    def initialize()
      super

      @ProjectConfigurations = []
      @RootNamespace = "root"
      @ProjectGuid = GetUUID()
    end

    def GetFileName()
      return "#{@ProjectConfiguration.ProjectName}.vcxproj"
    end

    def BuildFile()
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

      CreateConfigurationTags()

      CreateGlobals()

      CreateHeaderElement()
      CreateSourceElement()

      SaveXmlDocument(doc, GetFilePath())
    end

    def CreateConfigurationTags
      projectConfigurationGroupElements = []
      configurationPropertyGroups = []
      propertySheetsPropertyGroups = []
      itemDefinitionGroups = []
      othersPropertyGroups = []
      @ProjectConfigurations.each do |configuration|
        projectConfigurationGroupElements.push(CreateProjectConfigurationGroupElement(configuration))
        configurationPropertyGroups.push(CreateConfigurationPropertyGroup(configuration))
        propertySheetsPropertyGroups.push(CreatePropertySheetsPropertyGroup(configuration))
        itemDefinitionGroups.push(CreateItemDefinitionGroup(configuration))
      end

      @itemGroups.push GetMultiElementListForList(
        {"Label" =>  "ProjectConfigurations"},
        "ProjectConfiguration", projectConfigurationGroupElements
      )

      @propertyGroups.concat(configurationPropertyGroups)
      @propertyGroups.concat(propertySheetsPropertyGroups)

      @itemDefinitionGroups.concat(itemDefinitionGroups)
    end

    def CreateGlobals()
      @propertyGroups.push(GetElementForList(
          { "Label" => "Globals"},
          { "ProjectGuid" => "#{@ProjectGuid}",
            "RootNamespace" => "#{@RootNamespace}"})
      )
    end

    def CreateItemDefinitionGroup(configuration)
      clCompileElement = GetSelfContainedElement("ClCompile", {}, {
          "WarningLevel" => configuration.WarningLevel,
          "Optimization" => configuration.Optimization,
          "AdditionalIncludeDirectories" => configuration.AdditionalIncludeDirectories.join(';'),
          "PreprocessorDefinitions" => configuration.PreprocessorDefinitions.join(';'),
          "AssemblerOutput" => configuration.AssemblerOutput,
          "FunctionLevelLinking" => configuration.FunctionLevelLinking.to_s(),
          "IntrinsicFunctions" => configuration.IntrinsicFunctions.to_s()
        })

      linkElement = GetSelfContainedElement("Link", {}, {
          "GenerateDebugInformation" => configuration.GenerateDebugInformation.to_s(),
          "AdditionalLibraryDirectories" => configuration.AdditionalLibraryDirectories.join(';'),
          "AdditionalDependencies" => configuration.AdditionalDependencies.join(';'),
          "EnableCOMDATFolding" => configuration.EnableCOMDATFolding.to_s(),
          "OptimizeReferences" => configuration.OptimizeReferences.to_s()
        })

      return GetElementForList({"Condition" => configuration.GetConfigurationCondition()}, clCompileElement.merge(linkElement))
    end

    def CreateImports()
      @imports.push GetElementForList({ "Project" => "$(VCTargetsPath)\\Microsoft.Cpp.Default.props"},{})
      @imports.push GetElementForList({ "Project" => "$(VCTargetsPath)\\Microsoft.Cpp.targets"},{})
      @imports.push GetElementForList({ "Project" => "$(VCTargetsPath)\\Microsoft.Cpp.props"},{})
    end

    def CreatePropertySheetsPropertyGroup(configuration)
      return GetElementForList(
        { "Label" => "PropertySheets",
          "Condition" => configuration.GetConfigurationCondition()},
        {}) #TODO
    end

    def CreateProjectConfigurationGroupElement(configuration)
      return GetElementForList(
        { "Include" => configuration.GetNamePlatformCombi()},
        { "Configuration" => configuration.Name ,
          "Platform" => configuration.Platform}
      )
    end

    def CreateConfigurationPropertyGroup(configuration)
      return GetElementForList(
        { "Condition" => configuration.GetConfigurationCondition(), "Label"=>"Configuration"},
        { "ConfigurationType" => configuration.ConfigurationType ,
          "UseDebugLibraries" => configuration.UseDebugLibraries.to_s,
          "CharacterSet" => configuration.CharacterSet.to_s
        }
      )
    end

    def CreateHeaderElement()
      itemList = []
      extendedIncludePaths = @ProjectConfiguration.GetExtendedIncludes()

      extendedIncludePaths.each { |headerfile|
        relativeHeader = _GetVsProjectRelativePath(headerfile)
        
        itemList.push GetElementForList({"Include" => relativeHeader}, {})
      }

      @itemGroups.push GetMultiElementListForList({}, "ClInclude", itemList)
    end

    def CreateSourceElement()
      itemList = []
      extendedSourcePaths = @ProjectConfiguration.GetExtendedSources()

      extendedSourcePaths.each { |sourcefile|
        relativeSource = _GetVsProjectRelativePath(sourcefile)
     
        itemList.push GetElementForList({"Include" => relativeSource}, {})
      }

      #pathToPrecompiledHeader = FindFileInDirectories(@PrecompiledHeader, Dir.pwd, @SourceDirectories)
      #itemList.push GetPrecompiledHeader(pathToPrecompiledHeader)
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

  end

end