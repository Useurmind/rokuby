module RakeBuilder
  module Defaults
    def Defaults.InitDefaultGppProjectConfigurations
      configs = []
      configs.push Rake.application.DefineInformationUnit(GppProjectConfiguration, "DEFAULT_X64_RELEASE", :plat => PLATFORM_UBUNTU_X64_RELEASE,
                                                                                                          :defines => ["X64"],
                                                                                                          :CompileOptions =>  [
                                                                                                                               Gpp::Configuration::CompileOptions::USE_CPP0X,
                                                                                                                               Gpp::Configuration::CompileOptions::OPTIMIZE_LEVEL_3
                                                                                                                               ],
                                                                                                          :LinkOptions => [
                                                                                                                           
                                                                                                                           ]
                                                         )

      configs.push Rake.application.DefineInformationUnit(GppProjectConfiguration, "DEFAULT_X64_DEBUG", :plat => PLATFORM_UBUNTU_X64_DEBUG,
                                                                                                          :defines => ["X64"],
                                                                                                          :CompileOptions =>  [
                                                                                                                               Gpp::Configuration::CompileOptions::USE_CPP0X,
                                                                                                                               Gpp::Configuration::CompileOptions::CREATE_DEBUG_INFORMATION
                                                                                                                               ],
                                                                                                          :LinkOptions => [
                                                                                                                           Gpp::Configuration::LinkOptions::CREATE_DEBUG_INFORMATION
                                                                                                                           ]
                                                         )

      configs.push Rake.application.DefineInformationUnit(GppProjectConfiguration, "DEFAULT_X86_RELEASE", :plat => PLATFORM_UBUNTU_X86_RELEASE,
                                                                                                          :defines => ["X64"],
                                                                                                          :CompileOptions =>  [
                                                                                                                               Gpp::Configuration::CompileOptions::USE_CPP0X,
                                                                                                                               Gpp::Configuration::CompileOptions::OPTIMIZE_LEVEL_3
                                                                                                                               ],
                                                                                                          :LinkOptions => [

                                                                                                                           ]
                                                         )

      configs.push Rake.application.DefineInformationUnit(GppProjectConfiguration, "DEFAULT_X86_DEBUG", :plat => PLATFORM_UBUNTU_X86_DEBUG,
                                                                                                          :defines => ["X64"],
                                                                                                          :CompileOptions =>  [
                                                                                                                               Gpp::Configuration::CompileOptions::USE_CPP0X,
                                                                                                                               Gpp::Configuration::CompileOptions::CREATE_DEBUG_INFORMATION
                                                                                                                               ],
                                                                                                          :LinkOptions => [
                                                                                                                           Gpp::Configuration::LinkOptions::CREATE_DEBUG_INFORMATION
                                                                                                                           ]
                                                         )
      return configs
    end
  end
end
