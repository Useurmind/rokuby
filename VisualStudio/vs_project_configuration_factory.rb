require "VisualStudio/vs_project_configuration"
require "directory_utility"
require "general_utility"

module RakeBuilder
  class VsProjectConfigurationFactory
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
  end
end
