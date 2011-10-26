module Rake
  class Application
    DEFAULT_RAKEFILES = ["ProjectDefinition", "ProjectDefinition.rb"].freeze
    
    # Project path to the topmost project file that was evaluated.
    attr_reader :TopmostProjectFile
    
    def initialize
      super
      @name = "RakeBuilder"
    end
    
    def run
      standard_exception_handling do
        init
        load_rakefile
        top_level
      end

    end
    
    def find_rakefile_location
      here = Dir.pwd
      while ! (fn = have_rakefile)
        Dir.chdir("..")
        if Dir.pwd == here || options.nosearch
          return nil
        end
        here = Dir.pwd
      end
      [fn, here]
    ensure
      Dir.chdir(Rake.original_dir)
    end
  end
end
