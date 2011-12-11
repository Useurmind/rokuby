module RakeBuilder
  # A base class for all configurations.
  # Configurations are associated using their platform values.
  # If the platform values are equal they belong together.
  # [Platform] The platform this configuration is meant for.
  # [Defines] A list of defines that should be used in this configuration.
  class InformationConfiguration < InformationUnit
    attr_accessor :Platform
    attr_accessor :Defines
    
    def initialize()
      super
      
      @Platform = PlatformConfiguration.new()
      @Defines = []
    end
    
    def initialize_copy(original)
      super(original)
      
      @Platform = Clone(original.Platform)
      @Defines = Clone(original.Defines)
    end
  end
end
