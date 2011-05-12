require "VisualStudio/vs_file_creator.rb"
require "VisualStudio/vs_project_configuration.rb"
require "XML/XmlDocument"
require "XML/XmlTag"

module RakeBuilder


  class ProjectFileCreator < VsFileCreator
    attr_accessor :VsProjectConfigurations
    attr_accessor :ProjectGuid
    attr_accessor :RootNamespace

    def initialize()
      super

      @VsProjectConfigurations = []
      @RootNamespace = "root"
      @ProjectGuid = GetUUID()
    end

    def GetFileName()
      return "#{@ProjectConfiguration.ProjectName}.vcxproj"
    end

    def BuildFile()
      doc = XmlDocument.new()
      
      doc.Attributes = {
        "version" => "1.0",
        "encoding" => "utf-8"
      }
      
      @projectTag = XmlTag.new({
        name: "Project",
        attributes: {
        "DefaultTargets"=>"Build",
        "ToolsVersion"=>"4.0",
        "xmlns"=>"http://schemas.microsoft.com/developer/msbuild/2003"
        }
      })
      
      doc.RootChild = @projectTag

      CreateGlobalPropertyGroup()
      CreateConfigurationTags()
      CreateImports()
      CreateImportGroups()
      CreateHeaderItemGroup()
      CreateSourceItemGroup()
      
      @projectTag.Children.push(XmlTag.new({
        name: "ItemGroup",
        attributes: { "Label" => "ProjectConfigurations" },
        children: @projectConfigurations
      }))
      
      @projectTag.Children.push(@globalPropertyGroup)
      @projectTag.Children.push(@cppDefaultPropsImport)
      @projectTag.Children.concat(@configurationPropertyGroups)
      @projectTag.Children.push(@cppPropsImport)
      @projectTag.Children.push(@extensionSettingsImportGroup)
      @projectTag.Children.concat(@propertySheetsImportGroups)
      @projectTag.Children.push(@userMacrosPropertyGroup)
      @projectTag.Children.concat(@itemDefinitionGroups)
      @projectTag.Children.push(@headerItemGroup)
      @projectTag.Children.push(@sourceItemGroup)
      @projectTag.Children.push(@cppTargetsImport)
      @projectTag.Children.push(@extensionTargetsImportGroup)
      
      doc.SaveToFile(GetFilePath())
    end

    def CreateGlobalPropertyGroup()
      @globalPropertyGroup = XmlTag.new({
        name: "PropertyGroup",
        attributes: { "Label" => "Globals" },
        children: [
          XmlTag.new({name: "ProjectGuid", value: @ProjectGuid}),
          XmlTag.new({name: "RootNamespace", value: @RootNamespace})
        ]
      })
    end

    def CreateConfigurationTags
      @projectConfigurations = []
      @configurationPropertyGroups = []
      @propertySheetsImportGroups = []
      @itemDefinitionGroups = []
      
      @VsProjectConfigurations.each do |configuration|
        @projectConfigurations.push(CreateProjectConfiguration(configuration))
        @configurationPropertyGroups.push(CreateConfigurationPropertyGroup(configuration))
        @propertySheetsImportGroups.push(CreatePropertySheetsImportGroup(configuration))
        @itemDefinitionGroups.push(CreateItemDefinitionGroup(configuration))
      end
    end

    def CreateProjectConfiguration(configuration)
      return XmlTag.new({
        name: "ProjectConfiguration",
        attributes: { "Include" => configuration.GetNamePlatformCombi()},
        children: [
          XmlTag.new({name: "Configuration", value: configuration.Name}),
          XmlTag.new({name: "Platform", value: configuration.Platform})
        ]
      })
    end

    def CreateConfigurationPropertyGroup(configuration)
      return XmlTag.new({
        name: "PropertyGroup",
        attributes: {
          "Condition" => configuration.GetConfigurationCondition(),
          "Label"=>"Configuration"
        },
        children: [
          XmlTag.new({name: "ConfigurationType", value: configuration.ConfigurationType}),
          XmlTag.new({name: "UseDebugLibraries", value: configuration.UseDebugLibraries.to_s}),
          XmlTag.new({name: "WholeProgramOptimization", value: configuration.WholeProgramOptimization.to_s}),
          XmlTag.new({name: "CharacterSet", value: configuration.CharacterSet.to_s})
        ]
      })
    end

    def CreatePropertySheetsImportGroup(configuration)
      return XmlTag.new({
        name: "ImportGroup",
        attributes: {
          "Label" => "PropertySheets",
          "Condition" => configuration.GetConfigurationCondition()
        },
        children: [
          XmlTag.new({
            name: "Import",
            attributes: {
              "Project" => "$(UserRootDir)\\Microsoft.Cpp.$(Platform).user.props",
              "Condition" => "exists('$(UserRootDir)\\Microsoft.Cpp.$(Platform).user.props')",
              "Label" => "LocalAppDataPlatform"
            }
          })
        ]
      })
    end

    def CreateItemDefinitionGroup(configuration)
      clCompileElement = XmlTag.new({
        name: "ClCompile",
        children: [
          XmlTag.new( { name: "WarningLevel", value: configuration.WarningLevel }),
          XmlTag.new( { name: "Optimization", value: configuration.Optimization }),
          XmlTag.new( { name: "AdditionalIncludeDirectories", value: configuration.AdditionalIncludeDirectories.join(';') }),
          XmlTag.new( { name: "PreprocessorDefinitions", value: configuration.PreprocessorDefinitions.join(';') }),
          XmlTag.new( { name: "AssemblerOutput", value: configuration.AssemblerOutput }),
          XmlTag.new( { name: "FunctionLevelLinking", value: configuration.FunctionLevelLinking.to_s() }),
          XmlTag.new( { name: "IntrinsicFunctions", value: configuration.IntrinsicFunctions.to_s() })
        ]
      })

      linkElement = XmlTag.new({
        name: "Link",
        children: [
          XmlTag.new( { name: "GenerateDebugInformation", value: configuration.GenerateDebugInformation.to_s() }),
          XmlTag.new( { name: "AdditionalLibraryDirectories", value: configuration.AdditionalLibraryDirectories.join(';') }),
          XmlTag.new( { name: "AdditionalDependencies", value: configuration.AdditionalDependencies.join(';') }),
          XmlTag.new( { name: "EnableCOMDATFolding", value: configuration.EnableCOMDATFolding.to_s() }),
          XmlTag.new( { name: "OptimizeReferences", value: configuration.OptimizeReferences.to_s() })
        ]
      })

      return XmlTag.new({
        name: "ItemDefinitionGroup",
        attributes: {
          "Condition" => configuration.GetConfigurationCondition()
        },
        children: [ clCompileElement, linkElement ]
      })
    end

    def CreateImports()
      @cppPropsImport = XmlTag.new({
        name: "Import", attributes: { "Project" => "$(VCTargetsPath)\\Microsoft.Cpp.props" } 
      })
      @cppDefaultPropsImport = XmlTag.new({
        name: "Import", attributes: { "Project" => "$(VCTargetsPath)\\Microsoft.Cpp.Default.props" } 
      })
      @cppTargetsImport = XmlTag.new({
        name: "Import", attributes: { "Project" => "$(VCTargetsPath)\\Microsoft.Cpp.targets" } 
      })
    end
    
    def CreateImportGroups
      @extensionTargetsImportGroup = XmlTag.new({
        name: "ImportGroup", attributes: { "Label" => "ExtensionTargets" }, value: "" 
      })
      @extensionSettingsImportGroup = XmlTag.new({
        name: "ImportGroup", attributes: { "Label" => "ExtensionSettings" }, value: ""
      })
      @userMacrosPropertyGroup = XmlTag.new({
        name: "PropertyGroup", attributes: { "Label" => "UserMacros" }
      })
    end

    def CreateHeaderItemGroup()
      @headerItemGroup = XmlTag.new({
        name: "ItemGroup"
      })
      
      extendedIncludePaths = @ProjectConfiguration.GetExtendedIncludes(@VsProjectConfigurations[0].HeaderExcludePatterns)

      extendedIncludePaths.each do |headerfile|
        relativeHeader = _GetVsProjectRelativePath(headerfile)
        
        @headerItemGroup.Children.push( XmlTag.new({
          name: "ClInclude",
          attributes: {"Include" => relativeHeader}
        }))
      end
    end

    def CreateSourceItemGroup()
      @sourceItemGroup = XmlTag.new({
        name: "ItemGroup"
      })
      
      extendedSourcePaths = @ProjectConfiguration.GetExtendedSources(@VsProjectConfigurations[0].SourceExcludePatterns)

      extendedSourcePaths.each do |sourcefile|
        relativeSource = _GetVsProjectRelativePath(sourcefile)
     
        @sourceItemGroup.Children.push( XmlTag.new({
          name: "ClCompile",
         attributes: {"Include" => relativeSource}
        }))
      end
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