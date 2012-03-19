module RakeBuilder
  module Defaults    
    module PlatformConfigurations
      PLATFORM_ALL = PlatformConfiguration.new({
        name: "All Platforms"
      })
      
      # Default Windows configurations  
      PLATFORM_WIN = PlatformConfiguration.new({
        name: "Windows",
        os: :Windows
      })
      
      PLATFORM_WIN_X86 = PlatformConfiguration.new({
        name: "Windows (x86)",
        os: :Windows,
        arch: :x86
      })
      
      PLATFORM_WIN_X64 = PlatformConfiguration.new({
        name: "Windows (x64)",
        os: :Windows,
        arch: :x64
      })
      
      PLATFORM_WIN_X86_RELEASE = PlatformConfiguration.new({
        name: "Windows Release (x86)",
        os: :Windows,
        arch: :x86,
        type: :Release
      })
      
      PLATFORM_WIN_X86_DEBUG = PlatformConfiguration.new({
        name: "Windows Debug (x86)",
        os: :Windows,
        arch: :x86,
        type: :Debug
      })
      
      PLATFORM_WIN_X86_RELWITHDEB = PlatformConfiguration.new({
        name: "Windows Debug (x86)",
        os: :Windows,
        arch: :x86,
        type: :RelWithDeb
      })
      
      PLATFORM_WIN_X64_RELEASE = PlatformConfiguration.new({
        name: "Windows Release (x64)",
        os: :Windows,
        arch: :x64,
        type: :Release
      })
      
      PLATFORM_WIN_X64_DEBUG = PlatformConfiguration.new({
        name: "Windows Debug (x64)",
        os: :Windows,
        arch: :x64,
        type: :Debug
      })
      
      PLATFORM_WIN_X64_RELWITHDEB = PlatformConfiguration.new({
        name: "Windows Release With Debug (x64)",
        os: :Windows,
        arch: :x64,
        type: :RelWithDeb
      })
      
      # Default Ubuntu configurations
      PLATFORM_UBUNTU  = PlatformConfiguration.new({
        name: "Ubuntu",
        os: :Ubuntu
      })
      
      PLATFORM_UBUNTU_X86 = PlatformConfiguration.new({
        name: "Ubuntu (x86)",
        os: :Ubuntu,
        arch: :x86
      })
      
      PLATFORM_UBUNTU_X64 = PlatformConfiguration.new({
        name: "Ubuntu (x64)",
        os: :Ubuntu,
        arch: :x64
      })
      
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
    
    def Defaults.InitDefaultProjectConfigurations()
      configs = []
      
      configs.push Rake.application.DefineInformationUnit ProjectConfiguration, "DEFAULT_X64_RELEASE", :plat => PLATFORM_WIN_X64_RELEASE
      configs.push Rake.application.DefineInformationUnit ProjectConfiguration, "DEFAULT_X64_RELWITHDEB", :plat => PLATFORM_WIN_X64_RELWITHDEB
      configs.push Rake.application.DefineInformationUnit ProjectConfiguration, "DEFAULT_X64_DEBUG", :plat => PLATFORM_WIN_X64_DEBUG
      configs.push Rake.application.DefineInformationUnit ProjectConfiguration, "DEFAULT_X86_RELEASE", :plat => PLATFORM_WIN_X86_RELEASE
      configs.push Rake.application.DefineInformationUnit ProjectConfiguration, "DEFAULT_X86_RELWITHDEB", :plat => PLATFORM_WIN_X86_RELWITHDEB
      configs.push Rake.application.DefineInformationUnit ProjectConfiguration, "DEFAULT_X86_DEBUG", :plat => PLATFORM_WIN_X86_DEBUG
      
      return configs
    end    
  end
end

include RakeBuilder::Defaults::PlatformConfigurations