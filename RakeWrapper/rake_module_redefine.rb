module Rake

  # Rake module singleton methods.
  #
  class << self
    # Current Rake Application
    def application
      @application ||= RakeBuilder::Application.new
    end

    # Set the current Rake application object.
    def application=(app)
      @application = app
    end

    # Return the original directory where the Rake application was started.
    def original_dir
      application.original_dir
    end

    # Load a rakefile.
    def load_rakefile(path)
      application.LoadProjectFile(path)
    end
  end

end