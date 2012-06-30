require 'rexml/document'
require 'rexml/text'

include REXML

module Rokuby

  module VsXmlFileUtility
    include PathUtility

    def SaveXmlDocument(doc, path, options)
      file = File.open(path, 'w')
      docString = XmlSimple.xml_out(doc, options)
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
    # Actually it only converts something like './include/header1.h' correctly.
    def GetProjectDirectoryRelativeBaseDirectory(projectRelativePath)
      return FormatXmlPath(StripFilenameFromPath(projectRelativePath))
    end
    
    # Get the path of the file relative to the visual studio solution directory.
    # [projectRelativePath] Path of the file relative to the base project directory.
    def GetVsSolutionRelativePath(projectRelativePath)
      if(VsPathIsAbsolute(projectRelativePath))
        return projectRelativePath
      end
      
      return JoinXmlPaths([ "..", projectRelativePath])
    end

    # Get the path of the file relative to the visual studio project directory.
    # [projectRelativePath] Path of the file relative to the base project directory.
    def GetVsProjectRelativePath(projectRelativePath)
      if(VsPathIsAbsolute(projectRelativePath))
        return projectRelativePath
      end
      
      return JoinXmlPaths([ "..", "..", projectRelativePath])
    end
    
    def VsPathIsAbsolute(path)
      if(path.start_with?("$(") or path.match(/^[A-Z]:/))
        return true
      end
      
      return false
    end

    def FormatXmlPath(path)
      return path.gsub("\/", "\\")
    end
    
    def FormatXmlDirectory(dir)
      formattedDir = FormatXmlPath(dir)
      if(!formattedDir.end_with?("\\"))
        formattedDir = formattedDir + "\\"
      end
      return formattedDir
    end

    def JoinXmlPaths(paths)
      return FormatXmlPath(JoinPaths(paths))
    end

  end

end
