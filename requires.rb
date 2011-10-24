module RakeBuilder
  $SimulateTasks = false
end

require "rake"
require "rake/clean"
require "pathname"

puts File.dirname(__FILE__)
puts File.join(File.dirname(__FILE__), "XML/XmlHelper")

# Xml
require File.join(File.dirname(__FILE__), "XML/XmlHelper")
require File.join(File.dirname(__FILE__), "XML/XmlTag")
require File.join(File.dirname(__FILE__), "XML/XmlDocument")
require File.join(File.dirname(__FILE__), "XML/xmlsimple")

# UUID
require File.join(File.dirname(__FILE__), "UUID/uuidtools")

require File.join(File.dirname(__FILE__), "path_utility")
require File.join(File.dirname(__FILE__), "extended_path")
require File.join(File.dirname(__FILE__), "directory_utility")
require File.join(File.dirname(__FILE__), "general_utility")
require File.join(File.dirname(__FILE__), "doxygen_builder")

# Library management functionality
require File.join(File.dirname(__FILE__), "LibraryManagement/library_base")
require File.join(File.dirname(__FILE__), "LibraryManagement/dynamic_library")
require File.join(File.dirname(__FILE__), "LibraryManagement/static_library")
require File.join(File.dirname(__FILE__), "LibraryManagement/windows_dll")
require File.join(File.dirname(__FILE__), "LibraryManagement/windows_lib")
require File.join(File.dirname(__FILE__), "LibraryManagement/library_container")
require File.join(File.dirname(__FILE__), "LibraryManagement/library_container_factory")

# General functionality
require File.join(File.dirname(__FILE__), "ProjectManagement/cpp_project_configuration")
require File.join(File.dirname(__FILE__), "ProjectManagement/cpp_existing_project_configuration")
require File.join(File.dirname(__FILE__), "ProjectManagement/source_module")
require File.join(File.dirname(__FILE__), "ProjectManagement/project_manager")
require File.join(File.dirname(__FILE__), "ProjectManagement/subproject_manager")
require File.join(File.dirname(__FILE__), "ProjectManagement/project_builder")
require File.join(File.dirname(__FILE__), "Subprojects/subproject")
require File.join(File.dirname(__FILE__), "Subprojects/subproject_builder")

# Windows only functionality
require File.join(File.dirname(__FILE__), "VisualStudio/vs_xml_file_utility")
require File.join(File.dirname(__FILE__), "VisualStudio/vs_file_creator")
require File.join(File.dirname(__FILE__), "VisualStudio/project_file_creator")
require File.join(File.dirname(__FILE__), "VisualStudio/filter_file_creator")
require File.join(File.dirname(__FILE__), "VisualStudio/solution_file_creator")
require File.join(File.dirname(__FILE__), "VisualStudio/vs_project_configuration")
require File.join(File.dirname(__FILE__), "VisualStudio/vs_project")
require File.join(File.dirname(__FILE__), "VisualStudio/vs_existing_project")
require File.join(File.dirname(__FILE__), "VisualStudio/vs_subproject")
require File.join(File.dirname(__FILE__), "VisualStudio/vs_solution")
require File.join(File.dirname(__FILE__), "VisualStudio/vs_project_configuration_factory")
require File.join(File.dirname(__FILE__), "VisualStudio/vs_project_creator")
require File.join(File.dirname(__FILE__), "VisualStudio/vs_solution_creator")

# Linux only functionality
require File.join(File.dirname(__FILE__), "Linux/gpp_compile_order")
require File.join(File.dirname(__FILE__), "Linux/gpp_existing_compile_order")
require File.join(File.dirname(__FILE__), "Linux/ubuntu_packet_installer")
