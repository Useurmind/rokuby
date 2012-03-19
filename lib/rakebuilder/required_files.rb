module RakeBuilder
  module RequiredFiles
    FILES = [
# Utility libs
"Utility/general_utility",
"Utility/superclass_proxy",
"Utility/path_utility",
"Utility/project_path",
"Utility/directory_utility",

# Utility for Xml
"Utility/XML/XmlHelper",
"Utility/XML/XmlTag",
"Utility/XML/XmlDocument",
"Utility/XML/xmlsimple",

# Utility for UUIDs
"Utility/UUID/compat/securerandom",
"Utility/UUID/uuidtools/version",
"Utility/UUID/uuidtools",

# Utility for Visual Studio tasks
"Utility/VisualStudio/vs_xml_file_utility",
"Utility/VisualStudio/vs_file_creator",
"Utility/VisualStudio/filter_file_creator",
"Utility/VisualStudio/project_file_creator",
"Utility/VisualStudio/solution_file_creator",

# Information Units (classes needed in the dsl language,
"InformationUnits/Constants/project_constants",

"InformationUnits/information_unit",
"InformationUnits/information_specification",
"InformationUnits/information_instance",
"InformationUnits/information_configuration",
# general IUs
"InformationUnits/General/library",
"InformationUnits/General/platform_configuration",
"InformationUnits/General/project",
"InformationUnits/General/project_configuration",
"InformationUnits/General/project_description",
# specification IUs
"InformationUnits/Specifications/file_specification",
"InformationUnits/Specifications/library_location_spec",
"InformationUnits/Specifications/library_specification",
"InformationUnits/Specifications/project_specification",
"InformationUnits/Specifications/source_unit_specification",
# instance IUs
"InformationUnits/Instances/file_set",
"InformationUnits/Instances/library_file_set",
"InformationUnits/Instances/library_instance",
"InformationUnits/Instances/project_instance",
"InformationUnits/Instances/source_unit_instance",
# visual studio information instances
"InformationUnits/VisualStudio/vs_constants",
"InformationUnits/VisualStudio/vs_project_specification",
"InformationUnits/VisualStudio/vs_project_instance",
"InformationUnits/VisualStudio/vs_project_description",
"InformationUnits/VisualStudio/vs_project_configuration",
"InformationUnits/VisualStudio/vs_project",
"InformationUnits/VisualStudio/vs_solution_description",

# default values for different settings
"InformationUnits/General/defaults",
"InformationUnits/VisualStudio/vs_defaults",

"InformationUnits/Constants/configuration_constants",

# The rake wrapper that will be executed to gather the project definition files
"RakeWrapper/dsl_language",
"RakeWrapper/task",
"RakeWrapper/file_task",
"RakeWrapper/file_creation_task",
"RakeWrapper/processor_task",
"RakeWrapper/project_namespace",
"RakeWrapper/process_manager",
"RakeWrapper/information_unit_manager",
"RakeWrapper/project_file",
"RakeWrapper/project_file_loader",
"RakeWrapper/application",
"RakeWrapper/rake_module_redefine",

# Processing chain
"Processors/processor",
"Processors/passthrough_processor",
"Processors/process_chain",
# general processors
"Processors/General/find_file",
"Processors/General/file_finder",
"Processors/General/library_finder",
"Processors/General/source_unit_finder",
"Processors/General/project_finder",
# VisualStudio processors
"Processors/VisualStudio/vs_project_processor_utility",
"Processors/VisualStudio/vs_project_finder",
"Processors/VisualStudio/vs_project_preprocessor",
"Processors/VisualStudio/vs_project_post_build_command_task_creator",
"Processors/VisualStudio/vs_project_files_writer",
"Processors/VisualStudio/vs_project_creator",
"Processors/VisualStudio/vs_project_builder",
"Processors/VisualStudio/vs_solution_processor_utility",
"Processors/VisualStudio/vs_solution_preprocessor",
"Processors/VisualStudio/vs_solution_file_writer",
"Processors/VisualStudio/vs_solution_builder",

"doxygen_builder",
]

  end
end