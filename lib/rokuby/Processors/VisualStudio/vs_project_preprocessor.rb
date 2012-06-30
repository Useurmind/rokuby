module Rokuby
  # This class takes the necessary steps to combine project description/configuration
  # and visual studio project description/configuration.
  # The input of this processor are the (vs) project descriptions and configurations
  # and the output are the copies of these objects that were modified.
  # The basic steps that are taken is to initialize the visual studio objects with values
  # that represent a proper combination of the values in general project description/
  # configuration and visual studio description/configuration.
  # This normally means that values in the visual studio configuration that are not set
  # can be overwritten/modified by values in the project configuration. Values that are
  # set by the user in the visual studio project objects should never be modified.
  class VsProjectPreprocessor < Processor
    include VsProjectProcessorUtility
    include DirectoryUtility
    
    def _ProcessInputs(taskArgs=nil)
      _SortInputs()      
      
      if(@projectDescription == nil)
        raise "No ProjectDescription in #{self.class}:#{@Name}"
      end
      
      if(@projectInstance == nil)
        raise "No ProjectInstance in #{self.class}:#{@Name}"
      end
      
      if(@vsProjectDescription == nil)
        raise "No VsProjectDescription in #{self.class}:#{@Name}"
      end
      
      _ExtendVsProjectDescription()
      
      _FilterProjectConfigurations()
      _ExtendVsProjectConfigurations()
      
      _ForwardOutputs()
    end
    
    def _ExtendVsProjectDescription      
      projectFileBaseName = @projectDescription.Name
      projectFilesBasePath = @vsProjectDescription.ProjectBasePath + ProjectPath.new(projectFileBaseName)
      
      if(@vsProjectDescription.ProjectFilePath == nil)
        @vsProjectDescription.ProjectFilePath = projectFilesBasePath + ProjectPath.new("#{projectFileBaseName}.vcxproj")
      end
      if(@vsProjectDescription.FilterFilePath == nil)
        @vsProjectDescription.FilterFilePath = projectFilesBasePath + ProjectPath.new("#{projectFileBaseName}.vcxproj.filters")
      end
    end
    
    def _ExtendVsProjectConfigurations
      #puts "in _ExtendVsProjectConfigurations: #{@vsProjectConfigurations}"
      
      # add c and h file for each idl file, as a source unit
      if(@vsProjectInstance)
        @vsProjectInstance.IdlFileSet.FilePaths.each() do |idlFilePath|
          sourceUnitInstance = SourceUnitInstance.new()
          idlFileName = idlFilePath.FileName(false)
          
          srcFilePath = ProjectPath.new({relative: idlFileName + "_i.c"})
          headerFilePath = ProjectPath.new({relative: idlFileName + "_h.h"})
          
          sourceUnitInstance.SourceFileSet.FilePaths = [@vsProjectDescription.ProjectFilePath.DirectoryPath() + srcFilePath]
          sourceUnitInstance.SourceFileSet.RootDirectories = [@vsProjectDescription.ProjectFilePath.DirectoryPath()]
          
          sourceUnitInstance.IncludeFileSet.FilePaths = [@vsProjectDescription.ProjectFilePath.DirectoryPath() + headerFilePath]
          sourceUnitInstance.IncludeFileSet.RootDirectories = [@vsProjectDescription.ProjectFilePath.DirectoryPath()]
          
          @projectInstance.SourceUnits.push(sourceUnitInstance)
        end
      end
      
      @vsProjectConfigurations.each() do |vsConf|
        
        _SetDependencyValues(vsConf)
        
        # Set binary name and extension and configuration type
        if(vsConf.TargetName == nil)
          vsConf.TargetName = @projectDescription.Name + "_" + vsConf.Platform.BinaryExtension()
        end
        
        if(@projectDescription.BinaryType == :Application)
          if(vsConf.TargetExt == nil)
            vsConf.TargetExt = Vs::Configuration::TargetExt::APPLICATION
          end
          if(vsConf.ConfigurationType == nil)
            vsConf.ConfigurationType = Vs::Configuration::ConfigurationType::APPLICATION
          end
        elsif(@projectDescription.BinaryType == :Shared)
          if(vsConf.TargetExt == nil)
            vsConf.TargetExt = Vs::Configuration::TargetExt::SHARED
          end
          if(vsConf.ConfigurationType == nil)
            vsConf.ConfigurationType = Vs::Configuration::ConfigurationType::SHARED
          end
        elsif(@projectDescription.BinaryType == :Static)
          if(vsConf.TargetExt == nil)
            vsConf.TargetExt = Vs::Configuration::TargetExt::STATIC
          end
          if(vsConf.ConfigurationType == nil)
            vsConf.ConfigurationType = Vs::Configuration::ConfigurationType::STATIC
          end
        end
        
        subfolderName = @projectDescription.Name + "_" + vsConf.Platform.BinaryExtension()
        
        # Set the intermediate and output directories
        if(vsConf.OutputDirectory == nil)
          #puts "setting output directory on configuration #{@projectDescription.BuildPath + ProjectPath.new(vsConf.Platform.Name)}"
          vsConf.OutputDirectory = @projectDescription.BuildPath + ProjectPath.new(subfolderName)
        end
        if(vsConf.IntermediateDirectory == nil)
          vsConf.IntermediateDirectory = @projectDescription.CompilesPath + ProjectPath.new(subfolderName)
        end       
        
        vsConf.PreprocessorDefinitions |= _GatherDefines(vsConf)
        vsConf.PreprocessorDefinitions = vsConf.PreprocessorDefinitions.uniq
      end
    end
    
    # For example libs, lib paths, include dirs
    def _SetDependencyValues(vsConf)
      # add the include directories for the project itself
      # this is the complete tree under the include directories
      includePaths = []
      @projectInstance.SourceUnits.each() do |su|
        su.IncludeFileSet.RootDirectories.each() do |rootDir|
          includePaths |= GetDirectoryTree(rootDir)
        end        
      end
      vsConf.AdditionalIncludeDirectories |= includePaths
      
      # add the project path to include paths if any idl files were found
      if(@vsProjectInstance != nil)
        if(@vsProjectInstance.IdlFileSet.FilePaths.length > 0)
          puts "Adding #{@vsProjectDescription.ProjectFilePath.DirectoryPath()} to includes"
          vsConf.AdditionalIncludeDirectories.push(@vsProjectDescription.ProjectFilePath.DirectoryPath())
        end
      end
      
      #puts "Libraries in project configuration #{vsConf.PlatformName} of project #{@projectDescription.Name}: #{@projectInstance.Libraries}"
      
      # write the lib name, path and include directories for all libs in this project
      @projectInstance.Libraries.each() do |library|
        libInstance = library.GetInstance(vsConf.Platform)
        if(!libInstance)
          next
        end
        
        #puts "Pushing root directories of library #{library.Name} into additional include directories #{[libInstance.FileSet.IncludeFileSet]}"
        libInstance.FileSet.IncludeFileSet.RootDirectories.each() do |rootDir|
          vsConf.AdditionalIncludeDirectories.push(rootDir)          
        end
        
        libInstance.FileSet.LibraryFileSet.FilePaths.each() do |filePath|
          if(libInstance.FileSet.LibraryFileSet.RootDirectories.length > 0)
            vsConf.AdditionalLibraryDirectories.push(filePath.DirectoryPath())
          end          
          vsConf.AdditionalDependencies.push(filePath.FileName)
        end
      end
      
      # add the library include paths and set defaults for the usage criteria depending on the current project
      @vsProjects.each() do |vsProj|
        vsProjConfiguration = vsProj.GetConfiguration(vsConf.Platform)
        
        # if the user defined a special usage behaviour take it
        vsProjUsage = _GetProjectUsage(vsProj.Guid)        
        if(vsProjUsage)
          #puts "Adopting new project usage for #{vsProj.Name}"
          vsProj.Usage = Clone(vsProjUsage)
        #else
        #  puts "Could not find usage pattern for project #{vsProj.Name} with guid #{vsProj.Guid}"
        #  puts "Available usages are #{VsProjectUsages()}"
        end
        
        
        outDir = vsProjConfiguration.OutputDirectory
        targetName = vsProjConfiguration.TargetName
        targetExt = vsProjConfiguration.TargetExt
        
        if(targetExt != Vs::Configuration::TargetExt::APPLICATION)
          binaryName = targetName.gsub("$(PlatformName)", @projectDescription.Name) + Vs::Configuration::TargetExt::STATIC # add always the lib file
          
          vsConf.AdditionalIncludeDirectories |= (vsProj.IncludePaths)
          # use dependencies instead
          #vsConf.AdditionalLibraryDirectories.push(outDir)
          #vsConf.AdditionalDependencies.push(binaryName)
          
          vsProj.Libraries.each() do |lib|
            libInstance = lib.GetInstance(vsConf.Platform)
            if(libInstance)
              vsConf.AdditionalIncludeDirectories |= libInstance.FileSet.IncludeFileSet.RootDirectories
            end
          end
          
          vsProj.Dependencies.each() do |dep|
            vsConf.AdditionalIncludeDirectories |= dep.IncludePaths
          end
        end
      end
      
      vsConf.AdditionalIncludeDirectories = vsConf.AdditionalIncludeDirectories.uniq
      vsConf.AdditionalLibraryDirectories = vsConf.AdditionalLibraryDirectories.uniq
      vsConf.AdditionalDependencies = vsConf.AdditionalDependencies.uniq
    end
    
    # Gather the defines that should be applied to a project configuration.
    def _GatherDefines(vsConf)
      defines = []
      defines |= @projectInstance.GatherDefines(vsConf.Platform)
      if(@vsProjectInstance)        
        defines |= @vsProjectInstance.GatherDefines()
      end
      defines |= @projectDescription.GatherDefines()
      defines |= @vsProjectDescription.GatherDefines()
      #puts "found defines for vsconf: #{defines}"
      @vsProjects.each() do|vsProj|
        defines |= vsProj.GetPassedDefines(vsConf.Platform)
      end
      return defines
    end
    
    # Filter out unused configurations
    # Only vs configurations that have a matching project configuration (the same platform)
    # are allowed for further use.
    def _FilterProjectConfigurations
      remainingConfigurations = []
      @vsProjectConfigurations.each() do |vsConf|
        if(_HaveProjectConfiguration(vsConf.Platform))
          remainingConfigurations.push(vsConf)
        end
      end
      
      @vsProjectConfigurations = remainingConfigurations
    end
    
    def _HaveProjectConfiguration(platform)
      @projectConfigurations.each() do |conf|
        if(conf.Platform == platform)
          return true
        end
      end
      return false
    end
  end
end
