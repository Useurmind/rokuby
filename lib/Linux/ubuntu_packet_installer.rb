require "rake"

module RakeBuilder

  # A class that will preinstall any packets that are needed for the compilation.
  # [TaskName] The name of the task that is created (default: "PacketInstallerTask" )
  # [PacketNames] The names of the packets that need to be installed.
  class UbuntuPacketInstaller
    include GeneralUtility
    
    attr_accessor :ProjectName
    attr_accessor :TaskName
    attr_accessor :PacketNames
    
    def initialize
      @ProjectName = ""
      @PacketNames = []
      @TaskName = GenerateTaskName({
        projectName: @ProjectName,
        type: "UbuntuPacketInstallerTask"
      })
    end
    
    # Create the task that can be used to install the packets.
    def CreatePacketInstallationTask 
      task @TaskName do
        @PacketNames.each { |packet|
          SystemWithFail("sudo apt-get install #{packet}", "Could not install packet #{packet}")
        }
      end
    end
    
  end

end