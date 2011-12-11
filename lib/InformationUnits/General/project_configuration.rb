module RakeBuilder
  # This class holds value that tells how a project is build.
  class ProjectConfiguration < InformationConfiguration
    
    def initialize
      super
    end
    
    def initialize_copy(original)
      super(original)
    end
  end
end
