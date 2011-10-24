module RakeBuilder
  # An information set is a unit of information that flows through the build process.
  # [Forward] Should this information be forwarded through the build process.
  class InformationSet
    attr_accessor :Forward
  end
end
