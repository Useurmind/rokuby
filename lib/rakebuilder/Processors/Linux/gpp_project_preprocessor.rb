module RakeBuilder
  class GppProjectPreprocessor < Processor
    include GppProjectProcessorUtility
    include DirectoryUtility
    
    def initialize(name, app, project_file)
      super(name, app, project_file)

      _RegisterInputTypes()
    end

    def _ProcessInputs(taskArgs=nil)
      _SortInputs()
      
      _ExtendGppProjectConfigurations()
      
      _ForwardOutputs()
    end
    
    def _ExtendGppProjectConfigurations()
      #puts "Extending configurations"
      @gppProjectConfigurations.each() do |gppConf|
        #puts "Extending gppConf #{[gppConf]}"
        subfolderName = @projectDescription.Name + gppConf.Platform.BinaryExtension()
        
        if(gppConf.CompileDirectory == nil)
          gppConf.CompileDirectory = @projectDescription.BuildPath + ProjectPath.new(subfolderName)
        end
        
        if(gppConf.OutputDirectory == nil)
          gppConf.OutputDirectory = @projectDescription.CompilesPath + ProjectPath.new(subfolderName)
        end
        
        if(gppConf.TargetName == nil)
          gppConf.TargetName = subfolderName
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

        #puts "extensions done for configuration: #{[gppConf]}"
      end
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
      
      # The include directories of the project itself
      @projectInstance.SourceUnits.each() do |su|
        su.IncludeFileSet.RootDirectories.each() do |rootDir|
          includePaths |= GetDirectoryTree(rootDir)
        end
      end
      
      # The include paths of project on which this project depends
      @gppProjects.each() do |gppProj|
        includePaths |= gppProj.IncludePaths
      end
      
      # The include paths of libraries this project depends on
      @projectInstance.Libraries.each() do |lib|
        libInstance = lib.GetInstance(gppConf.Platform)
        puts "trying to retrieve include paths for lib"
        if(libInstance)
          puts "found library instance #{[libInstance]}"
          includePaths |= libInstance.FileSet.IncludeFileSet.RootDirectories
        end
      end
      
      return includePaths
    end
  end
end
