module Rokuby
  # This is an IU that contains the necessary information to configure the creation
  # of a Doxygen documentation.
  # General options:
  # [ProjectName] The name of the project that is documented.
  # [DoxyfileTemplate] Project path of the template file from which the doxyfile should be created.
  # [Doxyfile] Project path that tells where the doxyfile should be created.
  # [OutputDirectory] A project path to the directory where the doxygen docu should be put.
  # [AdditionalDocumentationFileDirectory] A project path to a directory that contains additional files with documentation.
  #
  # Doxygen Options:
  # [EnablePreprocessing] Should the doxygen preprocessor be enabled.
  # [MacroExpansion] Should preprocessor macros be expanded to their defined values.
  # [ExpandOnlyPredef] Should only predefined macros be expanded to their defined values.
  # [Predefined] The macros that should be expanded and their values in form of a hash.
  # [ImagePath] The project path to the folder that contains the images used in the docu.
  # [JavadocAutobrief]
  # [QtAutobrief]
  # [MultilineCppIsBrief]
  # [BuiltinStlSupport]
  # [ExtractAll]
  # [ExtractStatic]
  # [ExtractPrivate] 
  # [SourceBrowser]
  class DoxygenConfiguration < InformationUnit
    attr_accessor :ProjectName
    attr_accessor :DoxyfileTemplate
    attr_accessor :Doxyfile
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
    
    def initialize(valueMap=nil)
      super(valueMap)
      
      @ProjectName = "" 
      @DoxyfileTemplate = ProjectPath.new("Doxyfile.template")
      @Doxyfile = ProjectPath.new("Doxyfile")
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
      @ImagePath = nil
      
      Extend(valueMap, false)
    end
    
    def initialize_copy(original)
      super(original)
      
      @ProjectName = Clone(original.ProjectName)
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
      
      projectName = valueMap[:ProjectName] || valueMap[:name]
      if(projectName)
        @ProjectName = projectName
      end
      
      doxyfileTemplate = valueMap[:DoxyfileTemplate] || valueMap[:doxyTemplate]
      if(doxyfileTemplate)
        @DoxyfileTemplate = doxyfileTemplate
      end
      
      doxyfile = valueMap[:Doxyfile] || valueMap[:doxyfile]
      if(doxyfile )
        @Doxyfile = doxyfile
      end
      
      outputDirectory = valueMap[:OutputDirectory] || valueMap[:outDir]
      if(outputDirectory)
        @OutputDirectory = outputDirectory
      end
      
      additionalDocumentationFileDirectory = valueMap[:AdditionalDocumentationFileDirectory] || valueMap[:addDocFileDir]
      if(additionalDocumentationFileDirectory)
        @AdditionalDocumentationFileDirectory = additionalDocumentationFileDirectory
      end
      
      javadocAutobrief = valueMap[:JavadocAutobrief]
      if(javadocAutobrief)
        @JavadocAutobrief = javadocAutobrief
      end
      
      qtAutobrief = valueMap[:QtAutobrief]
      if(qtAutobrief)
        @QtAutobrief = qtAutobrief
      end
      
      multilineCppIsBrief = valueMap[:MultilineCppIsBrief] 
      if(multilineCppIsBrief)
        @MultilineCppIsBrief = multilineCppIsBrief
      end
      
      builtinStlSupport = valueMap[:BuiltinStlSupport]
      if(builtinStlSupport)
        @BuiltinStlSupport = builtinStlSupport
      end
      
      extractAll = valueMap[:ExtractAll]
      if(extractAll)
        @ExtractAll = extractAll
      end
      
      extractStatic = valueMap[:ExtractStatic]
      if(extractStatic)
        @ExtractStatic = extractStatic
      end
      
      extractPrivate = valueMap[:ExtractPrivate]
      if(extractPrivate)
        @ExtractPrivate = extractPrivate
      end
      
      sourceBrowser = valueMap[:SourceBrowser]
      if(sourceBrowser)
        @SourceBrowser = sourceBrowser
      end
      
      enablePreprocessing = valueMap[:EnablePreprocessing]
      if(enablePreprocessing)
        @EnablePreprocessing = enablePreprocessing
      end
      
      macroExpansion = valueMap[:MacroExpansion]
      if(macroExpansion)
        @MacroExpansion = macroExpansion
      end
      
      expandOnlyPredef = valueMap[:ExpandOnlyPredef]
      if(expandOnlyPredef)
        @ExpandOnlyPredef = expandOnlyPredef
      end
      
      predefined = valueMap[:Predefined]
      if(predefined)
        @Predefined = predefined
      end
      
      imagePath = valueMap[:ImagePath]
      if(imagePath)
        @ImagePath = imagePath
      end
    end
  end
end
