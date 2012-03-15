module RakeBuilder
   # This processor processes VSProjectSpecifications to produce corresponding instances.
   class VsProjectFinder < Processor
      include FindFile
      
      alias initialize_processor initialize
      def initialize(name=nil, app=nil, project_file=nil)
         initialize_processor(name, app, project_file)
         
         @knownInputClasses.push(RakeBuilder::VsProjectSpecification)
      end
    
      def _ProcessInputs         
         vsProjectInstance = VsProjectInstance.new()
         @inputs.each() do |input|
           if(input.is_a?(RakeBuilder::VsProjectSpecification))
             resFileSet = FindFile(input.ResourceFileSpec)
             vsProjectInstance.ResourceFileSet = vsProjectInstance.ResourceFileSet + resFileSet
           end
         end
         
         puts "searched: #{@inputs}"
         puts "rsources found: #{[vsProjectInstance.ResourceFileSet]}"
         
         @outputs = [vsProjectInstance]
      end
   end
end
