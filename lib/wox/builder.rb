module Wox
  class Builder < Task
    include Environment
    # def initialize(environment); super end

    def build
      configuration = environment[:configuration]
      puts "Building #{environment[:full_name]} configuration:#{configuration}"

      log_file = File.join environment[:build_dir], "build-#{configuration}.log"

      command = "xctool #{environment[:build_selector].to_s} #{environment[:target_selector].to_s} -sdk iphoneos -configuration #{configuration} clean build"
      puts command
      run_command command, :results => log_file
    end
  end
end
