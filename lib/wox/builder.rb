module Wox
  class Builder < Task
    include Environment
    # def initialize(environment); super end

    def build
      configuration = environment[:configuration]
      puts "Building #{environment[:full_name]} configuration:#{configuration}"

      log_file = File.join environment[:build_dir], "build-#{configuration}.log"

      run_command "/usr/local/bin/xctool #{environment[:build_selector].to_s} 
        #{environment[:target_selector].to_s} 
        -configuration #{configuration} 
        -IDEBuildLocationStyle=Custom 
        -IDECustomBuildLocationType=Absolute
        -IDECustomBuildProductsPath=\"#{environment[:build_dir]}\"
        -IDECustomBuildIntermediatesPath=\"#{environment[:build_dir]}\" 
        clean build OBJROOT=#{environment[:build_dir]} 
        SYMROOT=#{environment[:build_dir]} ", :results => log_file
    end
  end
end
