module Rokuby
  # Project builders are processors that are responsible for building single
  # projects.
  # A project builder takes one project description, one project instance and
  # several configurations and generates a project based on that.
  # They are merely a base class for building complete project builder classes
  # for specific types of projects.
  class ProjectBuilder < ProcessChain
    def initialize(name=nil, app=nil, projectFile=nil)
      super(name, app, projectFile)
    end
  end
end
