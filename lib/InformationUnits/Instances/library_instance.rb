module RakeBuilder
  # This class represents an instance of a library used on a certain plaform.
  # [FileSet] The set of files that belong to this specific library.
  # [Platform] The platform that this library is for.
  class LibraryInstance < InformationInstance
    attr_accessor :FileSet
    attr_accessor :Platform
    
    def initialize
      super
      @FileSet = FileSet.new()
      @Platform = PlatformConfiguration.new()
    end
    
    def initialize_copy(original)
      super(original)
      @FileSet = Clone(original.FileSet)
      @Platform = Clone(original.Platform)
    end
  end
end
