module RakeBuilder
  # This class is responsible for building a project with the gpp compiler.
  # This class and its subprocessors work as follows:
  # - Each processor is responsible for executing tasks concerned with certain parts of the project.
  # - When input is added the 
  class GppProjectBuilder < ProcessChain
    def initialize(name=nil, app=nil, project_file=nil)
      super(name, app, project_file)

      @projectFinder = defineProc ProjectFinder, "#{@Name}_ProjFinder"
      @projectPreprocessor = defineProc ProjectCompiler, "#{@Name}_ProjPrep"
      @projectCompiler = defineProc ProjectCompiler, "#{@Name}_ProjComp"
      @projectLinker = defineProc ProjectCompiler, "#{@Name}_ProjLink"
      @projectCreator = defineProc ProjectCompiler, "#{@Name}_ProjCreator"

      Connect(:in, @projectFinder.to_s, @projectPreprocessor.to_s, @projectCompiler.to_s, @projectLinker.to_s, @projectCreator.to_s, :out)


    end
  end
end