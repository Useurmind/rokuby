module Rokuby
  $SimulateTasks = false
end

require File.join(File.dirname(__FILE__), "RokubyRake/rake_required_files")

Rake::RequiredFiles::FILES.each() do |file|
  require File.join(File.dirname(__FILE__), "RokubyRake/rake/" + file)
end

require "yaml"
require "pathname"
require File.join(File.dirname(__FILE__), "required_files")

#puts File.dirname(__FILE__)
#puts File.join(File.dirname(__FILE__), "XML/XmlHelper")

Rokuby::RequiredFiles::FILES.each() do |file|
  require File.join(File.dirname(__FILE__), file)
end
