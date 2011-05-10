require 'XML/xmlsimple'
require 'rexml/document'
require 'rexml/text'
require 'UUID/uuidtools.rb'
require "directory_utility"

include REXML

module RakeBuilder

  class VsXmlFileUtility
    include DirectoryUtility

    def initialize
      @options = {
        "NoEscape" => true,
        "XmlDeclaration" => "<?xml version=\"1.0\" encoding=\"utf-8\"?>",
        "RootName" => "Project"
      }
    end

    def SaveXmlDocument(doc, path)
      file = File.open(path, 'w')
      docString = XmlSimple.xml_out(doc, @options)
      file.write docString
    end

    def GetMultiElementListForList(attributes, childElementName, childElements)
      elementList = {}

      attributes.each { |attrName, attrValue|
        elementList[attrName] = attrValue
      }

      elementList[childElementName] = childElements;

      return elementList
    end

    def GetSelfContainedElement(name, attributes, children)
      element = {
        name => GetElementForList(attributes, children)
      }

      return element
    end

    def GetElementForList(attributes, children)
      element = {}

      attributes.each { |attrName, attrValue|
        element[attrName] = attrValue
      }

      children.each { |childName, childValue|
        element[childName] = [childValue]
      }

      return element
    end

    # Return the directory of the given file path relative to the base directory of
    # the project.
    # [projectRelativePath] Path of the file relative to the project directory.
    # The path will be formatted in visual studio xml path format.
    # Example: 'C:/../projectBase/include/header1.h' -> 'include\header1.h'
    def GetProjectDirectoryRelativeBaseDirectory(projectRelativePath)
      return FormatXmlPath(StripFilenameFromPath(projectRelativePath))
    end

    # Get the path of the file relative to the visual studio project directory.
    # [projectRelativePath] Path of the file relative to the project directory.
    def GetVsProjectRelativePath(projectRelativePath)
      return JoinXmlPaths([ "..", projectRelativePath])
    end

    def FormatXmlPath(path)
      return path.gsub("\/", "\\")
    end

    def JoinXmlPaths(paths)
      return FormatXmlPath(JoinPaths(paths))
    end

  end

end