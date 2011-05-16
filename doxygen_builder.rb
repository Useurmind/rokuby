require "directory_utility"

module RakeBuilder
  
  # This class can be used to create a doxygen class.
  # It offers the possibility to set values for important doxygen options.
  # The class takes a doxyfile template, fills in the values for the given options, 
  # the project name, the source files that are to be documented and creates the doxygen
  # documentation.
  # [DoxyfileTemplate] Relative path of the template file for the doxyfile that should be used.
  # [DoxyfileName] Relative path of the doxyfile that should be created and used.
  # [ProjectConfiguration] The configuration of the project to document.
  # [OutputDirectory] The directory where the doxygen docu should be put.
  # [EnablePreprocessing] Should the doxygen preprocessor be enabled.
  # [MacroExpansion] Should preprocessor macros be expanded to their defined values.
  # [ExpandOnlyPredef] Should only predefined macros be expanded to their defined values.
  # [Predefined] The macros that should be expanded and their values in form of a hash.
  class DoxygenBuilder
    include DirectoryUtility
    
    attr_accessor :DoxyfileTemplate
    attr_accessor :DoxyfileName
    attr_accessor :ProjectConfiguration
    attr_accessor :AdditionalDocumentationFileDirectory
    attr_accessor :OutputDirectory
    
    # doxygen properties
    attr_accessor :JavadocAutobrief
    attr_accessor :QtAutobrief
    attr_accessor :MultilineCppIsBrief
    attr_accessor :BuiltinStlSupport
    attr_accessor :ExtractAll
    attr_accessor :ExtractStatic
    attr_accessor :ExtractPrivate
    attr_accessor :SourceBrowser
    
    attr_accessor :EnablePreprocessing
    attr_accessor :MacroExpansion
    attr_accessor :ExpandOnlyPredef
    attr_accessor :Predefined
    
    def initialize
      @DoxyfileTemplate = "Doxyfile.template"
      @Doxyfile = "Doxyfile"
      @OutputDirectory = "documentation"
      @AdditionalDocumentationFileDirectory = "src_doc"
      
      @JavadocAutobrief = true
      @QtAutobrief = true
      @MultilineCppIsBrief = false
      @BuiltinStlSupport = true
      @ExtractAll = true
      @ExtractStatic = true
      @ExtractPrivate = true
      @SourceBrowser = true
      @EnablePreprocessing = true
      @MacroExpansion = true
      @ExpandOnlyPredef = false
      @Predefined = {}
    end
    
    # Create the doxyfile and the documentation resulting from it.
    def CreateDoxyfile
      CreateDoxyfileTemplateIfMissing()
      
      CreateAdditionalDocumentationFilesString()
      usedSources = """#{@ProjectConfiguration.GetSourceDirectoryTree().join(""" """)}"""
      usedIncludes = """#{@ProjectConfiguration.GetIncludeDirectoryTree().join(""" """)}"" #{@additionalDocumentationFilesString}"
      
      predefinedMacros = []
      @Predefined.each do |macro, value|
	predefinedMacros.push("#{macro}=#{value}")
      end
      predefinedString = predefinedMacros.join(" ")
      
      templateLines = IO.readlines(@DoxyfileTemplate)
      File.open(@Doxyfile, 'w') do |doxyfile|
	
	for i in 0..templateLines.length-1 do
	  line = templateLines[i]
	  
	  line = SetAttributeIfMatch("PROJECT_NAME", @ProjectConfiguration.ProjectName, line)
	  line = SetAttributeIfMatch("OUTPUT_DIRECTORY", @OutputDirectory, line)
	  line = SetAttributeIfMatch("INPUT", "#{usedSources} #{usedIncludes}", line)
	  line = SetBoolAttributeIfMatch("JAVADOC_AUTOBRIEF", @JavadocAutobrief, line)
	  line = SetBoolAttributeIfMatch("QT_AUTOBRIEF", @QtAutobrief, line)
	  line = SetBoolAttributeIfMatch("MULTILINE_CPP_IS_BRIEF", @MultilineCppIsBrief, line)
	  line = SetBoolAttributeIfMatch("BUILTIN_STL_SUPPORT", @BuiltinStlSupport, line)
	  line = SetBoolAttributeIfMatch("EXTRACT_ALL", @ExtractAll, line) 
	  line = SetBoolAttributeIfMatch("EXTRACT_STATIC", @ExtractStatic, line) 
	  line = SetBoolAttributeIfMatch("EXTRACT_PRIVATE", @ExtractPrivate, line)  
	  line = SetBoolAttributeIfMatch("SOURCE_BROWSER", @SourceBrowser, line)
	  
	  line = SetBoolAttributeIfMatch("ENABLE_PREPROCESSING", @EnablePreprocessing, line)
	  line = SetBoolAttributeIfMatch("MACRO_EXPANSION", @MacroExpansion, line)
	  line = SetBoolAttributeIfMatch("EXPAND_ONLY_PREDEF", @ExpandOnlyPredef, line)
	  line = SetAttributeIfMatch("PREDEFINED", predefinedString, line)
	  
	  doxyfile.write("#{line}\n")
	end
      end
      
      system("doxygen #{@DoxyfileName}")
      
    end
    
    def CreateAdditionalDocumentationFilesString()
      additionalDocFiles = FindFilesInDirectory([".*\.h$"], [], @AdditionalDocumentationFileDirectory)
      @additionalDocumentationFilesString = additionalDocFiles.join(" ")
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
      if(!File.exists?(@DoxyfileTemplate))
	system("doxygen -g #{@DoxyfileTemplate}")
      end
    end
    
  end
  
end