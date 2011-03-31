require 'xmlsimple'
require 'rexml/document'
require 'rexml/text'
require 'UUID/uuidtools.rb'

include REXML

module RakeBuilder

  class VsXmlFileUtility

    def initialize
      @options = {
        "NoEscape" => true,
        "XmlDeclaration" => "<?xml version=\"1.0\" encoding=\"utf-8\"?>",
        "RootName" => "Project"
      }
    end

    def ExtendPaths()
      @ExtendedHeaderPaths = ExtendFilePaths(@HeaderFiles, @IncludeDirectories)
      @ExtendedSourcePaths = ExtendFilePaths(@SourceFiles, @SourceDirectories)
      @ExtendedPrecompileHeaderPath = FindFileInDirectories(@PrecompiledHeader, Dir.pwd, @SourceDirectories)
    end

    def SaveXmlDocument(doc, path)
      file = File.open(path, 'w')
      docString = XmlSimple.xml_out(doc, @options)
      file.write docString
    end

    def ExtendFilePaths(files, directories)
      extendedPaths = []
      files.each {|file|
        pathToFile = FindFileInDirectories(file, Dir.pwd, directories)
        extendedPaths .push pathToFile
      }
      return extendedPaths
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

  end

end