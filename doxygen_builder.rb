module RakeBuilder
  
  class DoxygenBuilder
    
    attr_accessor :DoxyfileTemplate
    attr_accessor :DoxyfileName
    attr_accessor :ProjectConfiguration
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
    
    def initialize
      @DoxyfileTemplate = "Doxyfile.template"
      @Doxyfile = "Doxyfile"
      @OutputDirectory = "documentation"
      
      @JavadocAutobrief = true
      @QtAutobrief = true
      @MultilineCppIsBrief = false
      @BuiltinStlSupport = true
      @ExtractAll = true
      @ExtractStatic = true
      @ExtractPrivate = true
      @SourceBrowser = true
    end
    
    def CreateDoxyfile
      CreateDoxyfileTemplateIfMissing()
      
      usedSources = """#{@ProjectConfiguration.GetSourceDirectoryTree().join(""" """)}"""
      usedIncludes = """#{@ProjectConfiguration.GetIncludeDirectoryTree().join(""" """)}"""
      
      puts "Creating doxygen documentation with the following sources:"
      puts usedSources
      templateLines = IO.readlines(@DoxyfileTemplate)
      File.open(@Doxyfile, 'w') do |doxyfile|
	
	for i in 0..templateLines.length-1 do
	  line = templateLines[i]
	  
	  line = SetAttributeIfMatch("PROJECT_NAME", @ProjectConfiguration.Name, line)
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
	  
	  doxyfile.write("#{line}\n")
	end
      end
      
      system("doxygen #{@DoxyfileName}")
      
    end
    
    def SetBoolAttributeIfMatch(name, value, line) 
      if(value)
	s = "YES"
      else
	s = "NO"
      end
      
      return SetAttributeIfMatch(name, s, line)
    end      
    
    def SetAttributeIfMatch(name, value, line)
      if(line.match("^\s*#{name}\s*="))
	    line = "#{name}    = #{value}"
      end
      return line
    end
    
    def CreateDoxyfileTemplateIfMissing()
      if(!File.exists?(@DoxyfileTemplate))
	system("doxygen -g #{@DoxyfileTemplate}")
      end
    end
    
  end
  
end