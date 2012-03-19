module RakeBuilder
  $SimulateTasks = false
end

require "rake"
require "rake/clean"
require "pathname"
require File.join(File.dirname(__FILE__), "required_files")

#puts File.dirname(__FILE__)
#puts File.join(File.dirname(__FILE__), "XML/XmlHelper")

RakeBuilder::RequiredFiles::FILES.each() do |file|
  require File.join(File.dirname(__FILE__), file)
end