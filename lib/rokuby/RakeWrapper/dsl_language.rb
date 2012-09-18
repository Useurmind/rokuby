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
      Rokuby::TaskDescriptor.new(task)
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

module Rokuby
  # This is additional dsl needed for the Rokuby projects
  module DSL
    include GeneralUtility
    
    ####################################################
    # General Generator functions
    
    def projPath(paramBag)
      return ProjectPath.new(paramBag)
    end
    
    ####################################################
    # Information Units    
    
    def infoUnit(cls, *args, &block)
      return Rake.application.DefineInformationUnit(cls, *args, &block)
    end
    
    #   General
    
    def lib(*args, &block)
      return Rake.application.DefineInformationUnit(Library, *args, &block)
    end
    
    def proj(*args, &block)
      return Rake.application.DefineInformationUnit(Project, *args, &block)
    end
    
    def projConf(*args, &block)
      return Rake.application.DefineInformationUnit(ProjectConfiguration, *args, &block)
    end
    
    def projDescr(*args, &block)
      return Rake.application.DefineInformationUnit(ProjectDescription, *args, &block)
    end
    
    def plat(*args, &block)
      return Rake.application.DefineInformationUnit(PlatformConfiguration, *args, &block)
    end
    
    def passDefs(*args, &block)
      return Rake.application.DefineInformationUnit(PassthroughDefines, *args, &block)
    end
    
    #   Instances
    
    def fileSet(*args, &block)
      return Rake.application.DefineInformationUnit(FileSet, *args, &block)
    end
    
    def libFileSet(*args, &block)
      return Rake.application.DefineInformationUnit(LibraryFileSet, *args, &block)
    end
    
    def libInst(*args, &block)
      return Rake.application.DefineInformationUnit(LibraryInstance, *args, &block)
    end
    
    def projInst(*args, &block)
      return Rake.application.DefineInformationUnit(ProjectInstance, *args, &block)
    end
    
    def srcInst(*args, &block)
      return Rake.application.DefineInformationUnit(SourceUnitInstance, *args, &block)
    end
    
    #   Specifications    
    
    def fileSpec(*args, &block)
      return Rake.application.DefineInformationUnit(FileSpecification, *args, &block)
    end
    
    def srcSpec(*args, &block)
      return Rake.application.DefineInformationUnit(SourceUnitSpecification, *args, &block)
    end
    
    def libSpec(*args, &block)
      return Rake.application.DefineInformationUnit(LibrarySpecification, *args, &block)
    end
    
    def libSpecSet(*args, &block)
      return Rake.application.DefineInformationUnit(LibrarySpecificationSet, *args, &block)
    end
    
    def projSpec(*args, &block)
      return Rake.application.DefineInformationUnit(ProjectSpecification, *args, &block)
    end
    
    def libLoc(*args, &block)
      return Rake.application.DefineInformationUnit(LibraryLocationSpec, *args, &block)
    end
    
    #    Visual Studio
    
    def vsProj(*args, &block)
      return Rake.application.DefineInformationUnit(VsProject, *args, &block)
    end
    
    def vsProjUsage(*args, &block)
      return Rake.application.DefineInformationUnit(VsProjectUsage, *args, &block)
    end
    
    def vsProjConf(*args, &block)
      return Rake.application.DefineInformationUnit(VsProjectConfiguration, *args, &block)
    end
    
    def vsProjDescr(*args, &block)
      return Rake.application.DefineInformationUnit(VsProjectDescription, *args, &block)
    end
    
    def vsProjInst(*args, &block)
      return Rake.application.DefineInformationUnit(VsProjectInstance, *args, &block)
    end
    
    def vsProjSpec(*args, &block)
      return Rake.application.DefineInformationUnit(VsProjectSpecification, *args, &block)
    end
    
    def vsSlnDescr(*args, &block)
      return Rake.application.DefineInformationUnit(VsSolutionDescription, *args, &block)
    end

    #    Gpp

    def gppProj(*args, &block)
      return Rake.application.DefineInformationUnit(GppProject, *args, &block)
    end

    def gppProjConf(*args, &block)
      return Rake.application.DefineInformationUnit(GppProjectConfiguration, *args, &block)
    end

    def gppProjDescr(*args, &block)
      return Rake.application.DefineInformationUnit(GppProjectDescription, *args, &block)
    end
    
    ####################################################
    # Processors
    
    # general processors
    def proc(*args, &block)
      return Rake.application.DefineProcessor(nil, *args, &block)
    end
    
    def defineProc(procClass, *args, &block)
      return Rake.application.DefineProcessor(procClass, *args, &block)
    end
    
    def cloneProc(newName, oldName)
      return Rake.application.CloneProcessor(newName, oldName)
    end
    
    def chain(*args, &block)
      return Rake.application.DefineProcessChain(ProcessChain, *args, &block)
    end
    
    def defineChain(chainClass, *args, &block)
      return Rake.application.DefineProcessChain(chainClass, *args, &block)
    end
    
    # finders
    def fileFinder(*args, &block)
      Rake.application.DefineProcessor(FileFinder, *args, &block)
    end
    
    def sourceFinder(*args, &block)
      Rake.application.DefineProcessor(SourceUnitFinder, *args, &block)
    end
    
    def projFinder(*args, &block)
      Rake.application.DefineProcessor(ProjectFinder, *args, &block)
    end
    
    def libFinder(*args, &block)
      Rake.application.DefineProcessor(LibraryFinder, *args, &block)
    end
    
    # visual studio
    def vsProjBuild(*args, &block)
      Rake.application.DefineProcessor(VsProjectBuilder, *args, &block)
    end
    
    def vsSlnBuild(*args, &block)
      Rake.application.DefineProcessor(VsSolutionBuilder, *args, &block)
    end

    # Gpp
    def gppProjBuild(*args, &block)
      Rake.application.DefineProcessor(GppProjectBuilder, *args, &block)
    end
    
    # Multi process
    
    def procArr(*args, &block)
      Rake.application.DefineProcessor(ProcessorArray, *args, &block)
    end
    
    def multiProjBuild(*args, &block)
      Rake.application.DefineProcessor(MultiProjectBuilder, *args, &block)
    end
    
    def multiSlnBuild(*args, &block)
      Rake.application.DefineProcessor(MultiSolutionBuilder, *args, &block)
    end
    
    #####################################################
    # Default Configurations
    
    def defaultProjectConfigurations()
      return Clone(Rake.application.current_project_file.DefaultProjectConfigurations)
    end
    
    def defaultVsProjectConfigurations()
      return Clone(Rake.application.current_project_file.DefaultVsProjectConfigurations)
    end

    def defaultGppProjectConfigurations()
      return Clone(Rake.application.current_project_file.DefaultGppProjectConfigurations)
    end
  end
end

self.extend Rokuby::DSL
