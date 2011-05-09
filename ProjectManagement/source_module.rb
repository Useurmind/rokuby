require "general_utility"

module RakeBuilder
  # This class represents a part of the source code which can be excluded from
  # compilation.
  # Such a module can for example roughly correspond to the use of a library.
  # This is especially useful for excluding source code that uses a library
  # not available on a certain OS.
  # A source module is defined by a set of source/header files and a preprocessor
  # define which can be used to blend out the includes for the given files or
  # the declaration/definition of factory methods for types defined in them.
  class SourceModule
    include GeneralUtility

    attr_accessor :HeaderPatterns
    attr_accessor :SourcePatterns
    attr_accessor :Define

    def initialize
      @HeaderPatterns = []
      @SourcePatterns = []
    end

    def initialize_copy(original)
      @HeaderPatterns = Clone(original.HeaderPatterns)
      @SourcePatterns = Clone(original.SourcePatterns)
      @Define = Clone(original.Define)
    end
  end
end
