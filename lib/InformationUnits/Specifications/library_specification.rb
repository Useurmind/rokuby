module RakeBuilder
  # This class defines all information about a library to clearly define to which
  # configuration it belongs and where it can be found.
  # [Name] The name of the library this specification belongs to.
  # [Location] The library file spec that defines where the library can be found.
  # [Platform] The platform for which this library is meant.
  class LibrarySpecification < InformationSpecification
    attr_accessor :Name
    attr_accessor :Platform
    attr_accessor :Location
    
    def initialize()
      super
      @Name = ""
      @Location = LibraryLocationSpec.new()
      @Platform = PlatformConfiguration.new()
    end
    
    def initialize_copy(original)
      super(original)
      @Name = Clone(original.Name)
      @Location = Clone(original.Location)
      @Platform = Clone(original.Platform)
    end
  end
end
