module RakeBuilder
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
    
    def initialize(name, app, project_file)
      super(name, app, project_file)
      
      _RegisterInputTypes()
    end
    
    def _ProcessInputs
      _SortInputs()
      
      _ExtendVsProjectDescription()
      
      _FilterProjectConfigurations()
      _ExtendVsProjectConfigurations()
      
      @outputs.push(@projectInstance)
      @outputs.push(@projectDescription)
      @outputs.concat(@projectConfigurations)
      @outputs.push(@vsProjectDescription)
      @outputs.concat(@vsProjectConfigurations)
      @outputs.concat(@vsProjects)
    end
    
    def _ExtendVsProjectDescription
      projectFilesBasePath = @projectDescription.ProjectPath + ProjectPath.new(PROJECT_SUBDIR)
      projectFileBaseName = @projectDescription.Name
      
      if(@vsProjectDescription.ProjectFilePath == nil)
        @vsProjectDescription.ProjectFilePath = projectFilesBasePath + ProjectPath.new("#{projectFileBaseName}.vcxproj")
      end
      if(@vsProjectDescription.FilterFilePath == nil)
        @vsProjectDescription.FilterFilePath = projectFilesBasePath + ProjectPath.new("#{projectFileBaseName}.vcxproj.filters")
      end
    end
    
    def _ExtendVsProjectConfigurations
      puts "in _ExtendVsProjectConfigurations: #{@vsProjectConfigurations}"
      
      @vsProjectConfigurations.each() do |vsConf|
        
        # write the libraries for each configuration to the corresponding fields
        @projectInstance.Libraries.each() do |library|
          libInstance = library.GetInstance(vsConf.Platform)
          if(!libInstance)
            next
          end
          
          libInstance.FileSet.LibraryFileSet.FilePaths.each() do |filePath|
            vsConf.AdditionalLibraryDirectories.push(filePath.DirectoryPath())
            vsConf.AdditionalDependencies.push(filePath.FileName)
          end
        end
        
        # add the libraries coming from dependent projects
        @vsProjects.each() do |vsProj|
          vsProjConfiguration = vsProj.GetConfiguration(vsConf.Platform)
          
          outDir = vsProjConfiguration.TargetName
          targetName = vsProjConfiguration.TargetName
          targetExt = vsProjConfiguration.TargetExt
          
          if(targetExt != Vs::Configuration::TargetExt::APPLICATION)
            binaryName = targetName.gsub("$(PlatformName)", @projectDescription.Name) + Vs::Configuration::TargetExt::STATIC # add always the lib file
            
            vsConf.AdditionalLibraryDirectories.push(outDir)
            vsConf.AdditionalDependencies.push(binaryName)
          end
        end
        
        # Set binary name and extension and configuration type
        if(vsConf.TargetName == nil)
          vsConf.TargetName = Vs::Configuration::Variables::PROJECT_NAME + "_" + vsConf.Platform.BinaryExtension()
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
        
        # Set the intermediate and output directories
        if(vsConf.OutputDirectory == nil)
          #puts "setting output directory on configuration #{@projectDescription.BuildPath + ProjectPath.new(vsConf.Platform.Name)}"
          vsConf.OutputDirectory = @projectDescription.BuildPath + ProjectPath.new(vsConf.Platform.Name)
        end
        if(vsConf.IntermediateDirectory == nil)
          vsConf.IntermediateDirectory = @projectDescription.CompilesPath + ProjectPath.new(vsConf.Platform.Name)
        end       
        
      end
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
