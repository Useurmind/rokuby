module Rake
  
  # Just extend the basic rake dsl.
  module DSL
  
    # Incude a project file from a subfolder.
    # The path is given in the form "subfolder/projectfile_name".
    # Project file are separated in their namespace.
    alias import_old import
    def import(path)
      Rake.application.AddProjectImport(path)
    end
    
    # For debugging purposes.
    # Prints useful information concerning the task.
    def taskDescriptor(task)
      RakeBuilder::TaskDescriptor.new(task)
    end
  
    # Add files to the clean target of this project file.
    def clean(*includes)
      Rake.application.IncludeCleanTargets(includes)
    end
  
    # Add files to the clobber target of this project file.
    def clobber(*includes)
      Rake.application.IncludeClobberTargets(includes)
    end
  
  end  
end

module RakeBuilder
  # This is additional dsl needed for the RakeBuilder projects
  module DSL
    
    ####################################################
    # General Generator functions
    
    def ProjPath(paramBag)
      return ProjectPath.new(paramBag)
    end
    
    ####################################################
    # Information Units    
    
    #   General
    
    def Lib(*args, &block)
      return Rake.application.DefineInformationUnit(Library, *args, &block)
    end
    
    def Proj(*args, &block)
      return Rake.application.DefineInformationUnit(Project, *args, &block)
    end
    
    def ProjConf(*args, &block)
      return Rake.application.DefineInformationUnit(ProjectConfiguration, *args, &block)
    end
    
    def ProjDescr(*args, &block)
      return Rake.application.DefineInformationUnit(ProjectDescription, *args, &block)
    end
    
    def Plat(*args, &block)
      return Rake.application.DefineInformationUnit(PlatformConfiguration, *args, &block)
    end
    
    #   Instances
    
    def FileSet(*args, &block)
      return Rake.application.DefineInformationUnit(FileSet, *args, &block)
    end
    
    def LibFileSet(*args, &block)
      return Rake.application.DefineInformationUnit(LibraryFileSet, *args, &block)
    end
    
    def LibInst(*args, &block)
      return Rake.application.DefineInformationUnit(LibraryInstance, *args, &block)
    end
    
    def ProjInst(*args, &block)
      return Rake.application.DefineInformationUnit(ProjectInstance, *args, &block)
    end
    
    def SrcInst(*args, &block)
      return Rake.application.DefineInformationUnit(SourceUnitInstance, *args, &block)
    end
    
    #   Specifications    
    
    def FileSpec(*args, &block)
      return Rake.application.DefineInformationUnit(FileSpecification, *args, &block)
    end
    
    def SrcSpec(*args, &block)
      return Rake.application.DefineInformationUnit(SourceUnitSpecification, *args, &block)
    end
    
    def LibSpec(*args, &block)
      return Rake.application.DefineInformationUnit(LibrarySpecification, *args, &block)
    end
    
    def ProjSpec(*args, &block)
      return Rake.application.DefineInformationUnit(ProjectSpecification, *args, &block)
    end
    
    def LibLoc(*args, &block)
      return Rake.application.DefineInformationUnit(LibraryLocationSpec, *args, &block)
    end
    
    #    Visual Studio
    
    def VsProj(*args, &block)
      return Rake.application.DefineInformationUnit(VSProject, *args, &block)
    end
    
    def VsProjConf(*args, &block)
      return Rake.application.DefineInformationUnit(VSProjectConfiguration, *args, &block)
    end
    
    def VsProjDescr(*args, &block)
      return Rake.application.DefineInformationUnit(VSProjectDescription, *args, &block)
    end
    
    def VsProjInst(*args, &block)
      return Rake.application.DefineInformationUnit(VSProjectInstance, *args, &block)
    end
    
    def VsProjSpec(*args, &block)
      return Rake.application.DefineInformationUnit(VSProjectSpecification, *args, &block)
    end
    
    def VsSlnDescr(*args, &block)
      return Rake.application.DefineInformationUnit(VSSolutionDescription, *args, &block)
    end
    
    ####################################################
    # Processors
    
    def Proc(procClass, *args, &block)
      return Rake.application.DefineProcessor(procClass, *args, &block)
    end
    
  end
end

self.extend RakeBuilder::DSL