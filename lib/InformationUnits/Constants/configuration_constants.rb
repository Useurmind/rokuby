module RakeBuilder
  OPERATING_SYSTEMS = [
    :Ubuntu,
    :Windows
  ]
  
  ARCHITECTURES = [
    :x64,
    :x86
  ]
  
  CONFIGURATION_TYPES = [
    :Debug,
    :Release
  ]
  
  # Default Windows configurations
  PLATFORM_WIN_X86_RELEASE = PlatformConfiguration.new({
    name: "Windows Release(x86)",
    os: :Windows,
    arch: :x86,
    type: :Release
  })
  
  PLATFORM_WIN_X86_DEBUG = PlatformConfiguration.new({
    name: "Windows Debug(x86)",
    os: :Windows,
    arch: :x86,
    type: :Debug
  })
  
  PLATFORM_WIN_X64_RELEASE = PlatformConfiguration.new({
    name: "Windows Release(x64)",
    os: :Windows,
    arch: :x64,
    type: :Release
  })
  
  PLATFORM_WIN_X64_DEBUG = PlatformConfiguration.new({
    name: "Windows Debug(x64)",
    os: :Windows,
    arch: :x64,
    type: :Debug
  })
  
  # Default Ubuntu configurations
  PLATFORM_UBUNTU_X86_RELEASE = PlatformConfiguration.new({
    name: "Ubuntu Release (x86)",
    os: :Ubuntu,
    arch: :x86,
    type: :Release
  })
  
  PLATFORM_UBUNTU_X86_DEBUG = PlatformConfiguration.new({
    name: "Ubuntu Debug (x86)",
    os: :Ubuntu,
    arch: :x86,
    type: :Debug
  })
  
  PLATFORM_UBUNTU_X64_RELEASE = PlatformConfiguration.new({
    name: "Ubuntu Release (x64)",
    os: :Ubuntu,
    arch: :x64,
    type: :Release
  })
  
  PLATFORM_UBUNTU_X64_DEBUG = PlatformConfiguration.new({
    name: "Ubuntu Debug (x64)",
    os: :Ubuntu,
    arch: :x64,
    type: :Debug
  })
end
