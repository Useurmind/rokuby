module Rokuby
  # This is an IU that contains the necessary information to configure the creation
  # of a Doxygen documentation.
  class DoxygenConfiguration < InformationUnit
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
    attr_accessor :ImagePath
    
    def initialize(valueMap)
      super()
      
      @DoxyfileTemplate = "Doxyfile.template"
      @Doxyfile = "Doxyfile"
      @OutputDirectory = ProjectPath.new(DOXYGEN_SUBDIR)
      @AdditionalDocumentationFileDirectory = ProjectPath.new(ADDITIONAL_DOXY_FILES_SUBDIR)
      
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
      @ImagePath = ""
      
      Extend(valueMap, false)
    end
    
    def initialize_copy(original)
      super(original)
      
      @DoxyfileTemplate = Clone(original.DoxyfileTemplate)
      @Doxyfile = Clone(original.Doxyfile)
      @OutputDirectory = Clone(original.OutputDirectory)
      @AdditionalDocumentationFileDirectory = Clone(original.AdditionalDocumentationFileDirectory)
      
      @JavadocAutobrief = Clone(original.JavadocAutobrief)
      @QtAutobrief = Clone(original.QtAutobrief)
      @MultilineCppIsBrief = Clone(original.MultilineCppIsBrief)
      @BuiltinStlSupport = Clone(original.BuiltinStlSupport)
      @ExtractAll = Clone(original.ExtractAll)
      @ExtractStatic = Clone(original.ExtractStatic)
      @ExtractPrivate = Clone(original.ExtractPrivate)
      @SourceBrowser = Clone(original.SourceBrowser)
      @EnablePreprocessing = Clone(original.EnablePreprocessing)
      @MacroExpansion = Clone(original.MacroExpansion)
      @ExpandOnlyPredef = Clone(original.ExpandOnlyPredef)
      @Predefined = Clone(original.Predefined)
      @ImagePath = Clone(original.ImagePath)
    end
    
    def Extend(valueMap, callParent=true)
      if(valueMap == nil)
        return
      end
      
      if(callParent)
        super(valueMap)
      end
    end
  end
end
