module Rokuby
  module Defaults
    def Defaults.InitDefaultGppProjectConfigurations
      configs = []
      configs.push Rake.application.DefineInformationUnit(GppProjectConfiguration, "DEFAULT_X64_RELEASE", :plat => PLATFORM_UBUNTU_X64_RELEASE,
                                                                                                          :Defines => ["X64"],
                                                                                                          :CompileOptions =>  [
                                                                                                                               Gpp::Configuration::CompileOptions::USE_CPP0X
                                                                                                                               ],
                                                                                                          :LinkOptions => [
                                                                                                                           
                                                                                                                           ],
                                                                                                          :OptimizationLevel => 3
                                                         )

      configs.push Rake.application.DefineInformationUnit(GppProjectConfiguration, "DEFAULT_X64_DEBUG", :plat => PLATFORM_UBUNTU_X64_DEBUG,
                                                                                                          :Defines => ["X64", "DEBUG", "_DEBUG"],
                                                                                                          :CompileOptions =>  [
                                                                                                                               Gpp::Configuration::CompileOptions::USE_CPP0X,
                                                                                                                               Gpp::Configuration::CompileOptions::CREATE_DEBUG_INFORMATION
                                                                                                                               ],
                                                                                                          :LinkOptions => [
                                                                                                                           Gpp::Configuration::LinkOptions::CREATE_DEBUG_INFORMATION
                                                                                                                           ],
                                                                                                          :OptimizationLevel => nil
                                                         )

      configs.push Rake.application.DefineInformationUnit(GppProjectConfiguration, "DEFAULT_X86_RELEASE", :plat => PLATFORM_UBUNTU_X86_RELEASE,
                                                                                                          :Defines => [],
                                                                                                          :CompileOptions =>  [
                                                                                                                               Gpp::Configuration::CompileOptions::USE_CPP0X
                                                                                                                               ],
                                                                                                          :LinkOptions => [

                                                                                                                           ],
                                                                                                          :OptimizationLevel => 3
                                                         )

      configs.push Rake.application.DefineInformationUnit(GppProjectConfiguration, "DEFAULT_X86_DEBUG", :plat => PLATFORM_UBUNTU_X86_DEBUG,
                                                                                                          :Defines => ["DEBUG", "_DEBUG"],
                                                                                                          :CompileOptions =>  [
                                                                                                                               Gpp::Configuration::CompileOptions::USE_CPP0X,
                                                                                                                               Gpp::Configuration::CompileOptions::CREATE_DEBUG_INFORMATION
                                                                                                                               ],
                                                                                                          :LinkOptions => [
                                                                                                                           Gpp::Configuration::LinkOptions::CREATE_DEBUG_INFORMATION
                                                                                                                           ],
                                                                                                          :OptimizationLevel => nil
                                                         )
      return configs
    end
  end
end
