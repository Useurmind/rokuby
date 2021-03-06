module Rokuby


  class ProjectFileCreator < VsFileCreator
    def initialize()
      super
    end

    def GetFilePath()
      return @VsProjectDescription.ProjectFilePath
    end

    def BuildFile()
      #startTime = Time.now
      
      _JoinSourceUnits()
      
      #t1 = Time.now
      #puts "Joining the source units took #{t1 - startTime}"
      
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

      #t2 = Time.now
      CreateGlobalPropertyGroup()
      #t3 = Time.now
      #puts "CreateGlobalPropertyGroup took #{t3 - t2}"
      CreateConfigurationTags()
      #t4 = Time.now
      #puts "CreateConfigurationTags took #{t4 - t3}"
      CreateImports()
      #t5 = Time.now
      #puts "CreateImports took #{t5 - t4}"
      CreateImportGroups()
      #t6 = Time.now
      #puts "CreateImportGroups took #{t6 - t5}"
      CreateHeaderItemGroup()
      #t7 = Time.now
      #puts "CreateHeaderItemGroup took #{t7 - t6}"
      CreateSourceItemGroup()
      #t8 = Time.now
      #puts "CreateSourceItemGroup took #{t8 - t7}"
      CreateResourceItemGroup()
      #t9 = Time.now
      #puts "CreateResourceItemGroup took #{t9 - t8}"
      CreateIdlItemGroup()
      #t10 = Time.now
      #puts "CreateIdlItemGroup took #{t10 - t9}"
      CreateProjectReferenceItemGroup()
      #t11 = Time.now
      #puts "CreateProjectReferenceItemGroup took #{t11 - t10}"
      
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
      @projectTag.Children.push(@idlItemGroup)
      @projectTag.Children.push(@projReferenceItemGroup)
      @projectTag.Children.push(@cppTargetsImport)
      @projectTag.Children.push(@extensionTargetsImportGroup)
      
      CreateFileDirectory()
      doc.SaveToFile(GetFilePath().AbsolutePath())
      
      #puts "Building the project file took #{Time.now - startTime} seconds."
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
      
      #puts "#{@VsProjectConfigurations.count()} configurations to build configuration tags for."
      @VsProjectConfigurations.each do |configuration|
        #puts "Creating configuration tags for configuration #{configuration.Name}"
        #t1 = Time.now
        @projectConfigurations.push(CreateProjectConfiguration(configuration))
        #t2 = Time.now
        #puts "CreateProjectConfiguration took #{t2 - t1}"
        @propertyGroups.push(CreatePropertyGroup(configuration))
        #t3 = Time.now
        #puts "CreatePropertyGroup took #{t3 - t2}"
        @propertySheetsImportGroups.push(CreatePropertySheetsImportGroup(configuration))
        #t4 = Time.now
        #puts "CreatePropertySheetsImportGroup took #{t4 - t3}"
        @configurationPropertyGroups.push(CreateConfigurationPropertyGroup(configuration))
        #t5 = Time.now
        #puts "CreateConfigurationPropertyGroup took #{t5 - t4}"
        @itemDefinitionGroups.push(CreateItemDefinitionGroup(configuration))
        #t6 = Time.now
        #puts "CreateItemDefinitionGroup took #{t6 - t5}"
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
          XmlTag.new({name: "CharacterSet", value: configuration.CharacterSet.to_s}),
          XmlTag.new({name: "CLRSupport", value: configuration.ClrSupport.to_s})
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
      #puts "Creating property group for configuration #{[configuration]}"
      xmlTag = XmlTag.new({
        name: "PropertyGroup",
        attributes: {
          "Condition" => configuration.ConfigurationCondition()
        },
        children: [
          XmlTag.new( { name: "OutDir", value: FormatXmlDirectory(_GetVsProjectRelativePath(configuration.OutputDirectory).RelativePath) } ),
          XmlTag.new( { name: "IntDir", value: FormatXmlDirectory(_GetVsProjectRelativePath(configuration.IntermediateDirectory).RelativePath) } )
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
        pathToAdd = nil
        if(dirPath.absolute?)
          pathToAdd = dirPath.AbsolutePath()
        else
          pathToAdd = _GetVsProjectRelativePath(dirPath).RelativePath
        end
        
        if(pathToAdd == "" or pathToAdd == nil)
          pathToAdd = "."
        end
        
        vsRelativeAdditionalIncludeDirectories.push(pathToAdd)
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
          XmlTag.new( { name: "AdditionalIncludeDirectories", value: vsRelativeAdditionalIncludeDirectories.uniq().join(';') }),
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
        if(libPath.absolute?)
          vsRelativeLibraryDirectories.push(libPath.AbsolutePath())
        else
          vsRelativeLibraryDirectories.push(_GetVsProjectRelativePath(libPath).RelativePath)
        end
        
      end

      linkElement = XmlTag.new({
        name: "Link",
        children: [
          XmlTag.new( { name: "GenerateDebugInformation", value: configuration.GenerateDebugInformation.to_s() }),
          XmlTag.new( { name: "AdditionalLibraryDirectories", value: vsRelativeLibraryDirectories.uniq().join(';') }),
          XmlTag.new( { name: "AdditionalDependencies", value: configuration.AdditionalDependencies.uniq().join(';') }),
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
      
      relativePaths = []
      @SourceUnit.IncludeFileSet.FilePaths.each() do |filePath|
        headerPath = _GetVsProjectRelativePath(filePath)
        relativePaths.push(headerPath.RelativePath)
      end
      
      relativePaths.uniq().each() do |relativePath|        
        @headerItemGroup.Children.push( XmlTag.new({
          name: "ClInclude",
          attributes: {"Include" => relativePath}
        }))
      end 
    end

    def CreateSourceItemGroup()
      @sourceItemGroup = XmlTag.new({
        name: "ItemGroup"
      })
      
      relativePaths = []
      @SourceUnit.SourceFileSet.FilePaths.each() do |filePath|
        sourcePath = _GetVsProjectRelativePath(filePath)
        relativePaths.push(sourcePath.RelativePath)
      end
      
      relativePaths.uniq().each() do |relativePath|        
        @sourceItemGroup.Children.push( XmlTag.new({
          name: "ClCompile",
         attributes: {"Include" => relativePath}
        }))
      end 
    end
    
    def CreateResourceItemGroup()
      @resourceItemGroup = XmlTag.new({
        name: "ItemGroup"
      })
      
      relativePaths = []
      @ResourceFileSet.FilePaths.each() do |filePath|
        resourcePath = _GetVsProjectRelativePath(filePath)
        relativePaths.push(resourcePath.RelativePath)
      end
      
      relativePaths.uniq().each() do |relativePath|
        @resourceItemGroup.Children.push( XmlTag.new({
          name: "ResourceCompile",
          attributes: {"Include" => relativePath}
        }))
      end
    end
    
    def CreateIdlItemGroup()
      @idlItemGroup = XmlTag.new({
        name: "ItemGroup"
      })
      
      relativePaths = []
      @IdlFileSet.FilePaths.each() do |filePath|
        idlPath = _GetVsProjectRelativePath(filePath)
        relativePaths.push(idlPath.RelativePath)
      end
      
      relativePaths.uniq().each() do |relativePath|
        @resourceItemGroup.Children.push( XmlTag.new({
          name: "Midl",
          attributes: {"Include" => relativePath}
        }))
      end
    end
    
    def CreateProjectReferenceItemGroup()
      @projReferenceItemGroup = XmlTag.new({
        name: "ItemGroup"
      })
      
      #puts "resource file set: #{[@ResourceFileSet]}"
      @VsProjects.each() do |vsProject|
        projectFilePath = _GetVsProjectRelativePath(vsProject.ProjectFilePath)

        projectReferenceTag = XmlTag.new({
          name: "ProjectReference",
          attributes: {"Include" => projectFilePath.RelativePath}
        })
        
        usage = vsProject.Usage
        projectReferenceTag.Children.push(XmlTag.new({ name: "Project", value: vsProject.Guid }))
        if(usage.Private != nil)
          projectReferenceTag.Children.push(XmlTag.new({ name: "Private", value: usage.Private }))
        end
        
        if(usage.ReferenceOutputAssembly != nil)
          projectReferenceTag.Children.push(XmlTag.new({ name: "ReferenceOutputAssembly", value: usage.ReferenceOutputAssembly }))
        end
        
        if(usage.CopyLocalSatelliteAssemblies != nil)          
          projectReferenceTag.Children.push(XmlTag.new({ name: "CopyLocalSatelliteAssemblies", value: usage.CopyLocalSatelliteAssemblies }))
        end
        
        if(usage.LinkLibraryDependencies != nil)
          projectReferenceTag.Children.push(XmlTag.new({ name: "LinkLibraryDependencies", value: usage.LinkLibraryDependencies }))
        end
        
        if(usage.UseLibraryDependencyInputs != nil)
          projectReferenceTag.Children.push(XmlTag.new({ name: "UseLibraryDependencyInputs", value: usage.UseLibraryDependencyInputs }))
        end

        @projReferenceItemGroup.Children.push(projectReferenceTag)
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
