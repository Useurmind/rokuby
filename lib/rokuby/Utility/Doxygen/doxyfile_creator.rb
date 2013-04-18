module Rokuby
  # This class can be used to create a doxygen class.
  # It offers the possibility to set values for important doxygen options.
  # The class takes a doxyfile template, fills in the values for the given options, 
  # the project name, the source files that are to be documented and creates the doxygen
  # documentation.  
  class DoxyfileCreator
    include DirectoryUtility
    
    attr_accessor :SourceUnitInstances
    attr_accessor :DoxygenConfiguration
    
    def initialize
      @SourceUnitInstances = []
      @DoxygenConfiguration = nil
    end
    
    # Create the doxyfile and the documentation resulting from it.
    def CreateDoxyfile
      CreateDoxyfileTemplateIfMissing()
      
      CreateAdditionalDocumentationFilesString()
      usedSources = ""
      usedIncludes = ""
      
      puts "Building doxyfile"
      
      @SourceUnitInstances.each() do |sui|
        sui.SourceFileSet.FilePaths.each() do |srcPath|
          usedSources = usedSources + " #{GetDoxygenFilePath(srcPath)}"
        end
        sui.IncludeFileSet.FilePaths.each() do |inclPath|
          usedIncludes = usedIncludes + " #{GetDoxygenFilePath(inclPath)}"
        end
      end
      
      usedIncludes = usedIncludes + " #{@additionalDocumentationFilesString}"
      
      predefinedMacros = []
      @DoxygenConfiguration.Predefined.each do |macro, value|
	predefinedMacros.push("#{macro}=#{value}")
      end
      predefinedString = predefinedMacros.join(" ")
      
      templateLines = IO.readlines(@DoxygenConfiguration.DoxyfileTemplate.AbsolutePath())
      File.open(@DoxygenConfiguration.Doxyfile.AbsolutePath(), 'w') do |doxyfile|
	
	for i in 0..templateLines.length-1 do
	  line = templateLines[i]
	  
	  line = SetAttributeIfMatch("PROJECT_NAME", @DoxygenConfiguration.ProjectName, line)
	  line = SetAttributeIfMatch("OUTPUT_DIRECTORY", GetDoxygenFilePath(@DoxygenConfiguration.OutputDirectory), line)
	  line = SetAttributeIfMatch("INPUT", "#{usedSources} #{usedIncludes}", line)
	  line = SetBoolAttributeIfMatch("JAVADOC_AUTOBRIEF", @DoxygenConfiguration.JavadocAutobrief, line)
	  line = SetBoolAttributeIfMatch("QT_AUTOBRIEF", @DoxygenConfiguration.QtAutobrief, line)
	  line = SetBoolAttributeIfMatch("MULTILINE_CPP_IS_BRIEF", @DoxygenConfiguration.MultilineCppIsBrief, line)
	  line = SetBoolAttributeIfMatch("BUILTIN_STL_SUPPORT", @DoxygenConfiguration.BuiltinStlSupport, line)
	  line = SetBoolAttributeIfMatch("EXTRACT_ALL", @DoxygenConfiguration.ExtractAll, line) 
	  line = SetBoolAttributeIfMatch("EXTRACT_STATIC", @DoxygenConfiguration.ExtractStatic, line) 
	  line = SetBoolAttributeIfMatch("EXTRACT_PRIVATE", @DoxygenConfiguration.ExtractPrivate, line)  
	  line = SetBoolAttributeIfMatch("SOURCE_BROWSER", @DoxygenConfiguration.SourceBrowser, line)
	  line = SetAttributeIfMatch("IMAGE_PATH", GetDoxygenFilePath(@DoxygenConfiguration.ImagePath), line)
	  
	  line = SetBoolAttributeIfMatch("ENABLE_PREPROCESSING", @DoxygenConfiguration.EnablePreprocessing, line)
	  line = SetBoolAttributeIfMatch("MACRO_EXPANSION", @DoxygenConfiguration.MacroExpansion, line)
	  line = SetBoolAttributeIfMatch("EXPAND_ONLY_PREDEF", @DoxygenConfiguration.ExpandOnlyPredef, line)
	  line = SetAttributeIfMatch("PREDEFINED", predefinedString, line)
	  
	  doxyfile.write("#{line}\n")
	end
      end      
    end
    
    def CreateDoxygenDocu
      SystemWithFail("doxygen #{@DoxygenConfiguration.Doxyfile.RelativePath}", "Could not build doxygen docu, doxygen returned an error.")
    end
    
    def CreateAdditionalDocumentationFilesString()
      additionalDocFiles = FindFilesInDirectory([".*\.h$", ".*\.hpp$", ".*\.hxx$", ".*\.md$", ".*\.markdown$"], [], @DoxygenConfiguration.AdditionalDocumentationFileDirectory)
      @additionalDocumentationFilesString = ""
      additionalDocFiles.each() do |docFilePath|
        @additionalDocumentationFilesString = @additionalDocumentationFilesString + " #{GetDoxygenFilePath(docFilePath)}"
      end
    end
    
    def GetDoxygenFilePath(projectPath)
      if(!projectPath)
        return ""
      end
      
      workingDir = ProjectPath.new()
      doxyPath = projectPath.MakeRelativeTo(workingDir)
      return doxyPath.RelativePath
    end
    
    # If the line contains the named boolean attribute set its value to "YES" or "NO" and return the new line.
    def SetBoolAttributeIfMatch(name, value, line)      
      if(value)
	s = "YES"
      else
	s = "NO"
      end
      
      return SetAttributeIfMatch(name, s, line)
    end      
    
    # If the line contains the named attribute set its value and return the new line.
    def SetAttributeIfMatch(name, value, line)
      if(line.match("^\s*#{name}\s*="))
	    line = "#{name}    = #{value}"
      end
      return line
    end
    
    # Creates a doxyfile template if it is missing.
    def CreateDoxyfileTemplateIfMissing()
      if(!@DoxygenConfiguration.DoxyfileTemplate.exist?())
	SystemWithFail("doxygen -g #{@DoxygenConfiguration.DoxyfileTemplate.AbsolutePath()}", "Could not create doxygen template file, doxygen returned an error.")
      end
    end
  end
end
