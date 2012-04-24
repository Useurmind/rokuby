module RakeBuilder
  # Symbols that describe different operating systems
  OPERATING_SYSTEMS = [
    :Ubuntu,
    :Windows
  ]
  
  # Symbols that describe different architectures.
  ARCHITECTURES = [
    :x64,
    :x86
  ]
  
  # Symbols that describe different build configurations.
  CONFIGURATION_TYPES = [
    :Debug,
    :Release,
    :RelWithDeb
  ]
end
