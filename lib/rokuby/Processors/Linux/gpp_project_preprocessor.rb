module Rokuby
  class GppProjectPreprocessor < Processor
    include GppProjectProcessorUtility
    include DirectoryUtility
    
    def initialize(name, app, project_file)
      super(name, app, project_file)

      _RegisterInputTypes()
    end

    def _ProcessInputs(taskArgs=nil)
      _SortInputs()
      
      platBinExt = GetPlatformBinaryExtensions(taskArgs)
      
      _ExtendGppProjectConfigurations(platBinExt)
      
      _ForwardOutputs()
    end
    
    def _ExtendGppProjectConfigurations(platBinExt)
      #puts "Extending configurations"
      
      gppConf = _GetGppProjectConf(platBinExt)
        
      subfolderName = @projectDescription.Name + "_" + gppConf.Platform.BinaryExtension()
      
      if(gppConf.CompileDirectory == nil)
        gppConf.CompileDirectory = @projectDescription.CompilesPath + ProjectPath.new(subfolderName)
      end
      
      if(gppConf.OutputDirectory == nil)
        gppConf.OutputDirectory = @projectDescription.BuildPath + ProjectPath.new(subfolderName)
      end
      
      if(gppConf.TargetName == nil)
        if(@projectDescription.BinaryName)
            gppConf.TargetName = @projectDescription.BinaryName
        else
          if(@projectDescription.BinaryType == :Shared)
            gppConf.TargetName = "lib" + @projectDescription.Name + "_" + gppConf.Platform.BinaryExtension()
          else
            gppConf.TargetName = @projectDescription.Name + "_" + gppConf.Platform.BinaryExtension()
          end
        end  
      end
      
      if(@projectDescription.BinaryType == :Application)
        if(gppConf.TargetExt == nil)
          gppConf.TargetExt = Gpp::Configuration::TargetExt::APPLICATION
        end
      elsif(@projectDescription.BinaryType == :Shared)
        if(gppConf.TargetExt == nil)
          gppConf.TargetExt = Gpp::Configuration::TargetExt::SHARED_LIB
        end
      elsif(@projectDescription.BinaryType == :Static)
        if(gppConf.TargetExt == nil)
          gppConf.TargetExt = Gpp::Configuration::TargetExt::STATIC_LIB
        end
      end
      
      gppConf.IncludePaths |= _GatherIncludePaths(gppConf)
      
      gppConf.Defines |= _GatherDefines(gppConf)
      gppConf.Defines = gppConf.Defines.uniq
    end
    
    def _GatherDefines(gppConf)
      defines = []
      defines |= @projectInstance.GatherDefines(gppConf.Platform)
      defines |= @projectDescription.GatherDefines()
      defines |= @gppProjectDescription.GatherDefines()
      #puts "found defines for vsconf: #{defines}"
      @gppProjects.each() do|gppProj|
        defines |= gppProj.GetPassedDefines(gppConf.Platform)
      end
      return defines
    end
    
    def _GatherIncludePaths(gppConf)            
      includePaths = []
      
      #puts "Getting include paths by making them relative to #{@ProjectFile.Path.DirectoryPath()}"
      
      @projectInstance.SourceUnits.each() do |su|
        su.IncludeFileSet.RootDirectories.each() do |rootDir|
          includePaths |= GetDirectoryTree(rootDir)
        end
      end
      
      @projectInstance.Libraries.each() do |lib|
        libInstance = lib.GetInstance(gppConf.Platform)
        if(libInstance)
          includePaths |= libInstance.FileSet.IncludeFileSet.RootDirectories.map() {|fileDir| fileDir.MakeRelativeTo(@ProjectFile.Path.DirectoryPath())}
        end        
      end
      
      @gppProjects.each() do |childProject|
        includePaths |= _GetSubProjectIncludePaths(childProject, gppConf)
      end
      
      return includePaths
    end
    
    def _GetSubProjectIncludePaths(gppProj, gppConf)
      includePaths = gppProj.IncludePaths.map() {|fileDir| fileDir.MakeRelativeTo(@ProjectFile.Path.DirectoryPath())}
      
      gppProj.Libraries.each() do |lib|
        libInstance = lib.GetInstance(gppConf.Platform)
        if(libInstance)
          includePaths |= libInstance.FileSet.IncludeFileSet.RootDirectories.map() {|fileDir| fileDir.MakeRelativeTo(@ProjectFile.Path.DirectoryPath())}
        end        
      end
      
      gppProj.Dependencies.each() do |depProj|
        includePaths |= _GetSubProjectIncludePaths(depProj, gppConf)
      end      
      
      return includePaths
    end
  end
end
