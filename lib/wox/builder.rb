module Wox
  class Builder < Task
    include Environment
    # def initialize(environment); super end

    def build
      configuration, sdk, ipa_file, build_dir = environment[:configuration], environment[:sdk], environment[:ipa_file], environment[:build_dir]
      profile = environment[:provisioning_profile]

      puts "Building #{environment[:full_name]} configuration:#{configuration}"

      log_file = File.join environment[:build_dir], "build-#{configuration}.log"

      command = "xctool #{environment[:build_selector].to_s} #{environment[:target_selector].to_s} -sdk iphoneos -configuration #{configuration} PROVISIONING_PROFILE=\"#{profile}\" clean build"
      puts command
      run_command command, :results => log_file
    end
  end
end
