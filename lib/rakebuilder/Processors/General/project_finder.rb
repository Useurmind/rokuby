module RakeBuilder
  # This class finds all necessary parts for a project instance that is given
  # through a project specification.
  # Allowed inputs are ProjectSpecifications, SourceUnitSpecifications and
  # LibrarySpecifications.
  # Output is one ProjectInstance that contains all the gathered information.
  class ProjectFinder < ProcessChain
    include PlatformTester
    
    def initialize(name=nil, app=nil, project_file=nil)
      super(name, app, project_file)
      
      @projSplitter =  defineProc ProjectSplitter, "#{@Name}_Splitter"
      @suFinder = defineProc SourceUnitFinder, "#{@Name}_SuFinder"
      @libFinder = defineProc LibraryFinder, "#{@Name}_LibFinder"
      @projJoiner = defineProc ProjectJoiner, "#{@Name}_Joiner"
      
      Connect(:in, @projSplitter.to_s)
      Connect(@projSplitter.to_s, @libFinder.to_s, @projJoiner.to_s)
      Connect(@projSplitter.to_s, @suFinder.to_s, @projJoiner.to_s)
      Connect(@projJoiner.to_s, :out)
      
      @knownInputClasses.push(RakeBuilder::ProjectSpecification)
      @knownInputClasses.push(RakeBuilder::SourceUnitSpecification)
      @knownInputClasses.push(RakeBuilder::LibrarySpecification)
    end
  end
end
