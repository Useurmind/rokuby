require File.join(File.dirname(__FILE__), "lib/rokuby/required_files")
require File.join(File.dirname(__FILE__), "lib/rokuby/RokubyRake/rake_required_files")

requires_file = "lib/rokuby/requires.rb"

files = [
    requires_file,
    "lib/rokuby/required_files.rb",
    "lib/rokuby/RokubyRake/rake/version.rb",
    "lib/rokuby/RokubyRake/rake_required_files.rb"
]

# documentation is generated with yard
# the documentation files
#doc_files = [
#    "introduction.rb",
#    "project_files.rb",
#    "projects.rb",
#    "libraries.rb",
#    "gcc.rb",
#    "visual_studio.rb"
#]

# the images for the documentation
#doc_images = [
#	"vs_project_workflow.svg",
#	"vs_solution_workflow.svg"
#]

#doc_files.each() do |docFile|
#    files.push("lib/rokuby/Doc/" + docFile)
#end

#doc_images.each() do |docImage|
#    files.push("lib/rokuby/Doc/images/" + docImage)
#end

# required files for the rake version used
Rake::RequiredFiles::FILES.each do |file|
    files.push("lib/rokuby/RokubyRake/rake/" + file + ".rb")
end

# required files for the rokuby tool
Rokuby::RequiredFiles::FILES.each do |file|
    files.push("lib/rokuby/" + file + ".rb")
end

$rokubySpec = Gem::Specification.new do |s|
  s.name        = 'Rokuby'
  s.version     = '0.0.0'
  s.date        = '2012-03-19'
  s.summary     = "Advanced builder tool that is based on rake"
  s.description = "Advanced builder tool that is based on rake"
  s.authors     = ["Jochen Gruen"]
  s.email       = 'jochen.gruen@googlemail.com'
  s.files       = files
  s.homepage    = 'http://rubygems.org/gems/none'
  s.rdoc_options = "--main=" + requires_file 
  
  s.executables << 'rokuby'
end