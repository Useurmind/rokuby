require File.join(File.dirname(__FILE__), "lib/rakebuilder/required_files")
require File.join(File.dirname(__FILE__), "lib/rakebuilder/RakeBuilderRake/rake_required_files")

files = [
    "lib/rakebuilder/requires.rb",
    "lib/rakebuilder/required_files.rb",
    "lib/rakebuilder/RakeBuilderRake/rake/version.rb",
    "lib/rakebuilder/RakeBuilderRake/rake_required_files.rb"
]

Rake::RequiredFiles::FILES.each do |file|
    files.push("lib/rakebuilder/RakeBuilderRake/rake/" + file + ".rb")
end

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
  s.executables << 'rakebuilder'
end