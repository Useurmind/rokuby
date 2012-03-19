module RakeBuilder


  class ProjectFileCreator < VsFileCreator
    def initialize()
      super
    end

    def GetFilePath()
      return @VsProjectDescription.ProjectFilePath
    end

    def BuildFile()
      _JoinSourceUnits()
      
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
      CreateResourceItemGroup()
      
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
      @projectTag.Children.concat(@propertyGroups)
      @projectTag.Children.concat(@itemDefinitionGroups)
      @projectTag.Children.push(@headerItemGroup)
      @projectTag.Children.push(@sourceItemGroup)
      @projectTag.Children.push(@resourceItemGroup)
      @projectTag.Children.push(@cppTargetsImport)
      @projectTag.Children.push(@extensionTargetsImportGroup)
      
      CreateFileDirectory()
      doc.SaveToFile(GetFilePath().AbsolutePath())
    end

    def CreateGlobalPropertyGroup()
      @globalPropertyGroup = XmlTag.new({
        name: "PropertyGroup",
        attributes: { "Label" => "Globals" },
        children: [
          XmlTag.new({name: "ProjectGuid", value: @VsProjectDescription.Guid}),
          XmlTag.new({name: "RootNamespace", value: @VsProjectDescription.RootNamespace})
        ]
      })
    end

    def CreateConfigurationTags
      @projectConfigurations = []
      @propertyGroups = []
      @propertySheetsImportGroups = []
      @configurationPropertyGroups = []
      @itemDefinitionGroups = []
      
      @VsProjectConfigurations.each do |configuration|
        @projectConfigurations.push(CreateProjectConfiguration(configuration))
        @propertyGroups.push(CreatePropertyGroup(configuration))
        @propertySheetsImportGroups.push(CreatePropertySheetsImportGroup(configuration))
        @configurationPropertyGroups.push(CreateConfigurationPropertyGroup(configuration))
        @itemDefinitionGroups.push(CreateItemDefinitionGroup(configuration))
      end
    end

    def CreateProjectConfiguration(configuration)
      return XmlTag.new({
        name: "ProjectConfiguration",
        attributes: { "Include" => configuration.NamePlatformCombi()},
        children: [
          XmlTag.new({name: "Configuration", value: configuration.Name()}),
          XmlTag.new({name: "Platform", value: configuration.PlatformName})
        ]
      })
    end

    def CreateConfigurationPropertyGroup(configuration)
      return XmlTag.new({
        name: "PropertyGroup",
        attributes: {
          "Condition" => configuration.ConfigurationCondition(),
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
          "Condition" => configuration.ConfigurationCondition()
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

    def CreatePropertyGroup(configuration)
      puts "Creating property group for configuration #{[configuration]}"
      xmlTag = XmlTag.new({
        name: "PropertyGroup",
        attributes: {
          "Condition" => configuration.ConfigurationCondition()
        },
        children: [
          XmlTag.new( { name: "OutDir", value: _GetVsProjectRelativePath(configuration.OutputDirectory).RelativePath } ),
          XmlTag.new( { name: "IntDir", value: _GetVsProjectRelativePath(configuration.IntermediateDirectory).RelativePath } )
        ]
      })
      
      if(configuration.TargetName)        
          xmlTag.Children.push(XmlTag.new( { name: "TargetName", value: configuration.TargetName } ))
      end
      
      if(configuration.TargetExt)        
          xmlTag.Children.push(XmlTag.new( { name: "TargetExt", value: configuration.TargetExt } ))
      end
      
      return xmlTag
    end

    def CreateItemDefinitionGroup(configuration)
      vsRelativeAdditionalIncludeDirectories = []
      
      configuration.AdditionalIncludeDirectories.each() do |dirPath|
        vsRelativeAdditionalIncludeDirectories.push(_GetVsProjectRelativePath(dirPath).RelativePath)
      end
      
      
      #@VsProject.Dependencies.each do |dependency|
      #  dependency.VsProjectConfigurations.each do |projectConfiguration|
      #    if(projectConfiguration.Name == configuration.Name)
      #      puts "Found dependency configuration"
      #      additionalIncludeDirectories.concat(projectConfiguration.AdditionalIncludeDirectories)
      #    end
      #  end
      #end
      
      clCompileElement = XmlTag.new({
        name: "ClCompile",
        children: [
          XmlTag.new( { name: "WarningLevel", value: configuration.WarningLevel }),
          XmlTag.new( { name: "Optimization", value: configuration.Optimization }),
          XmlTag.new( { name: "AdditionalIncludeDirectories", value: vsRelativeAdditionalIncludeDirectories.join(';') }),
          XmlTag.new( { name: "PreprocessorDefinitions", value: configuration.PreprocessorDefinitions.join(';') }),
          XmlTag.new( { name: "AssemblerOutput", value: configuration.AssemblerOutput }),
          XmlTag.new( { name: "FunctionLevelLinking", value: configuration.FunctionLevelLinking.to_s() }),
          XmlTag.new( { name: "IntrinsicFunctions", value: configuration.IntrinsicFunctions.to_s() }),
          XmlTag.new( { name: "ProgramDataBaseFileName", value: configuration.ProgramDataBaseFileName }),
          XmlTag.new( { name: "RuntimeLibrary", value: configuration.RuntimeLibrary }),
          XmlTag.new( { name: "ExceptionHandling", value: configuration.ExceptionHandling }),
          XmlTag.new( { name: "BufferSecurityCheck", value: configuration.BufferSecurityCheck }),
          XmlTag.new( { name: "DebugInformationFormat", value: configuration.DebugInformationFormat }),
          XmlTag.new( { name: "InlineFunctionExpansion", value: configuration.InlineFunctionExpansion })
        ]
      })

      vsRelativeLibraryDirectories = []
      configuration.AdditionalLibraryDirectories.each() do |libPath|
        vsRelativeLibraryDirectories.push(_GetVsProjectRelativePath(libPath).RelativePath)
      end

      linkElement = XmlTag.new({
        name: "Link",
        children: [
          XmlTag.new( { name: "GenerateDebugInformation", value: configuration.GenerateDebugInformation.to_s() }),
          XmlTag.new( { name: "AdditionalLibraryDirectories", value: vsRelativeLibraryDirectories.join(';') }),
          XmlTag.new( { name: "AdditionalDependencies", value: configuration.AdditionalDependencies.join(';') }),
          XmlTag.new( { name: "EnableCOMDATFolding", value: configuration.EnableCOMDATFolding.to_s() }),
          XmlTag.new( { name: "OptimizeReferences", value: configuration.OptimizeReferences.to_s() })
        ]
      })
      if(configuration.ModuleDefinitionFile != nil)
        linkElement.Children.push( XmlTag.new( { name: "ModuleDefinitionFile", value: _GetVsProjectRelativePath(configuration.ModuleDefinitionFile).RelativePath } ) )
      end
      
      postBuildEventElementCommand = XmlTag.new({
        name: "PostBuildEvent",
        children: [
          XmlTag.new( { name: "Command", value: configuration.PostBuildCommand } )
        ]
      })

      return XmlTag.new({
        name: "ItemDefinitionGroup",
        attributes: {
          "Condition" => configuration.ConfigurationCondition()
        },
        children: [ clCompileElement, linkElement, postBuildEventElementCommand ]
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
      
      @SourceUnit.IncludeFileSet.FilePaths.each() do |filePath|
        headerPath = _GetVsProjectRelativePath(filePath)
        
        @headerItemGroup.Children.push( XmlTag.new({
          name: "ClInclude",
          attributes: {"Include" => headerPath.RelativePath}
        }))
      end 
    end

    def CreateSourceItemGroup()
      @sourceItemGroup = XmlTag.new({
        name: "ItemGroup"
      })
      
      @SourceUnit.SourceFileSet.FilePaths.each() do |filePath|
        sourcePath = _GetVsProjectRelativePath(filePath)
        
        @sourceItemGroup.Children.push( XmlTag.new({
          name: "ClCompile",
         attributes: {"Include" => sourcePath.RelativePath}
        }))
      end 
    end
    
    def CreateResourceItemGroup()
      @resourceItemGroup = XmlTag.new({
        name: "ItemGroup"
      })
      
      puts "resource file set: #{[@ResourceFileSet]}"
      @ResourceFileSet.FilePaths.each() do |filePath|
        resourcePath = _GetVsProjectRelativePath(filePath)

        @resourceItemGroup.Children.push( XmlTag.new({
          name: "ResourceCompile",
          attributes: {"Include" => resourcePath.RelativePath}
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