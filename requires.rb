module RakeBuilder
  $SimulateTasks = false
end

require "rake/clean"

# Library management functionality
require "LibraryManagement/library_base"
require "LibraryManagement/dynamic_library"
require "LibraryManagement/static_library"
require "LibraryManagement/windows_dll"
require "LibraryManagement/library_container"
require "LibraryManagement/library_container_factory"

# General functionality
require "ProjectManagement/cpp_project_configuration"
require "ProjectManagement/source_module"
require "ProjectManagement/project_manager"
require "subproject"
require "subproject_builder"
require "doxygen_builder"

# Windows only functionality
require "VisualStudio/vs_xml_file_utility"
require "VisualStudio/project_file_creator"
require "VisualStudio/filter_file_creator"
require "VisualStudio/solution_file_creator"
require "VisualStudio/vs_project_creator"

# Linux only functionality
require "Linux/gpp_compile_order"
require "Linux/ubuntu_packet_installer"
