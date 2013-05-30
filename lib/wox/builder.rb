module Wox
  class Builder < Task
    include Environment
    # def initialize(environment); super end

    def build
      configuration = environment[:configuration]
      puts "Building #{environment[:full_name]} configuration:#{configuration}"

      log_file = File.join environment[:build_dir], "build-#{configuration}.log"

      if environment[:workspace_name] then
        run_command "xcodebuild -workspace #{environment[:workspace_name]} -scheme '#{environment[:scheme]}' -configuration #{configuration} clean build OBJROOT=#{environment[:build_dir]} SYMROOT=#{environment[:build_dir]}", :results => log_file
      else
        run_command "xcodebuild -project #{environment[:project_name]} -target '#{environment[:target]}' -configuration #{configuration} clean build OBJROOT=#{environment[:build_dir]} SYMROOT=#{environment[:build_dir]}", :results => log_file
      end
    end
  end
end
