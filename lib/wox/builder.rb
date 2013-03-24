module Wox
  class Builder < Task
    include Environment
    # def initialize(environment); super end
    
    def build
      configuration = environment[:configuration]
      puts "Building #{environment[:full_name]} configuration:#{configuration}"
      
      log_file = File.join environment[:build_dir], "build-#{configuration}.log"
      
      run_command "xcodebuild -#{environment[:project_or_ws]} #{environment[:project_name]} -#{environment[:target_or_scheme]} '#{environment[:target]}' -configuration #{configuration} clean build OBJROOT=#{environment[:build_dir]} SYMROOT=#{environment[:build_dir]}", :results => log_file
    end
  end
end