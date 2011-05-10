require "VisualStudio/vs_project_configuration"
require "directory_utility"
require "general_utility"
require "VisualStudio/vs_xml_file_utility"

module RakeBuilder
  class VsProjectConfigurationFactory < VsXmlFileUtility
    include GeneralUtility

    def initialize()
    end

    def SetDebugValues(vsProjectConfiguration)
      vsProjectConfiguration.UseDebugLibraries = true
      vsProjectConfiguration.WholeProgramOptimization = false

      vsProjectConfiguration.WarningLevel = "Level3"
      vsProjectConfiguration.Optimization = "Disabled"
      vsProjectConfiguration.AssemblerOutput = "AssemblyAndSourceCode"
      vsProjectConfiguration.FunctionLevelLinking = false
      vsProjectConfiguration.IntrinsicFunctions = false

      vsProjectConfiguration.GenerateDebugInformation = true
      vsProjectConfiguration.EnableCOMDATFolding = false
      vsProjectConfiguration.OptimizeReferences = false
    end

    def ConvertFromProjectConfiguration(vsProjectConfiguration, projectConfiguration)
      vsProjectConfiguration.Name = projectConfiguration.Name
      vsProjectConfiguration.TargetName = projectConfiguration.BinaryName

      #set binary type
      if(projectConfiguration.BinaryType == :application)
        vsProjectConfiguration.ConfigurationType = VS_CONFIGURATION_TYPE_APPLICATION
        vsProjectConfiguration.TargetExt = VS_CONFIGURATION_EXTENSION_APPLICATION
      elsif(projectConfiguration.BinaryType == :shared)
        vsProjectConfiguration.ConfigurationType = VS_CONFIGURATION_TYPE_SHARED
        vsProjectConfiguration.TargetExt = VS_CONFIGURATION_EXTENSION_SHARED
      else
        abort "Binary type #{projectConfiguration.BinaryType} not supported"
      end

      vsProjectConfiguration.PreprocessorDefinitions = Clone(projectConfiguration.Defines)

      vsProjectConfiguration.AdditionalIncludeDirectories = _GetVsIncludeDirectories(projectConfiguration)
      _SetVsLibraryAttributes(vsProjectConfiguration, projectConfiguration)

      vsProjectConfiguration.OutputDirectory = JoinXmlPaths( [VS_CONFIGURATION_SOLUTION_DIR, "..", projectConfiguration.BuildDirectory, "vs-#{VS_CONFIGURATION_CONFIGURATION_NAME}"] )
    end

    def _GetVsIncludeDirectories(projectConfiguration)
      includeTree = projectConfiguration.GetIncludeDirectoryTree()
      vsIncludeTree = []
      includeTree.each do |directory|
        vsIncludeDirectory = GetVsProjectRelativePath(projectConfiguration.GetProjectRelativePath(directory))

        vsIncludeTree.push(vsIncludeDirectory)
      end
      return vsIncludeTree
    end

    def _SetVsLibraryAttributes(vsProjectConfiguration, projectConfiguration)
      libraryDirectories = []
      libraryNames = []
      libraryIncludePaths = []

      projectConfiguration.Libraries.each do |libContainer|
        if(!libContainer.UsedInWindows())
          next
        end

        libraryNames.push(libContainer.GetFileName(:Windows))

        libraryPath = GetVsProjectRelativePath(libContainer.GetLibraryPath(:Windows))

        libContainer.GetHeaderPaths(:Windows).each do |headerPath|
          libraryIncludePaths.push( GetVsProjectRelativePath(headerPath) )
        end
        libraryDirectories.push(libraryPath)
      end

      vsProjectConfiguration.AdditionalIncludeDirectories.concat(libraryIncludePaths)
      vsProjectConfiguration.AdditionalDependencies.concat(libraryNames)
      vsProjectConfiguration.AdditionalLibraryDirectories.concat(libraryDirectories)
    end
  end
end
