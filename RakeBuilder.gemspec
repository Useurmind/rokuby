require File.join(File.dirname(__FILE__), "lib/rakebuilder/required_files")
require File.join(File.dirname(__FILE__), "lib/rakebuilder/RakeBuilderRake/rake_required_files")

requires_file = "lib/rakebuilder/requires.rb"

files = [
    requires_file,
    "lib/rakebuilder/required_files.rb",
    "lib/rakebuilder/RakeBuilderRake/rake/version.rb",
    "lib/rakebuilder/RakeBuilderRake/rake_required_files.rb"
]

# the documentation files
doc_files = [
    "index.rb",
    "introduction.rb",
    "project_files.rb"
]

doc_files.each() do |docFile|
    files.push "lib/rakebuilder/Doc/" + docFile
end

# required files for the rake version used
Rake::RequiredFiles::FILES.each do |file|
    files.push("lib/rakebuilder/RakeBuilderRake/rake/" + file + ".rb")
end

# required files for the rokuby tool
RakeBuilder::RequiredFiles::FILES.each do |file|
    files.push("lib/rakebuilder/" + file + ".rb")
end

Gem::Specification.new do |s|
  s.name        = 'rakebuilder'
  s.version     = '0.0.0'
  s.date        = '2012-03-19'
  s.summary     = "Advanced builder tool that is based on rake"
  s.description = "Advanced builder tool that is based on rake"
  s.authors     = ["Jochen Gruen"]
  s.email       = 'jochen.gruen@googlemail.com'
  s.files       = files
  s.homepage    = 'http://rubygems.org/gems/none'
  s.rdoc_options = "--main=" + requires_file 
  
  s.executables << 'rakebuilder'
end