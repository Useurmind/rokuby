module Rokuby
  module FindFile
    def FindFile(fileSpec)
      fileFinder = FileFinder.new()
      fileFinder.AddInput(fileSpec)
      fileFinder.Process()
      return fileFinder.Outputs()[0]
    end
  end
end
