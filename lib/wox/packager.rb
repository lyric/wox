module Wox
  class Packager < Task
    include Environment
    
    def package
      configuration, sdk, ipa_file, build_dir = environment[:configuration], environment[:sdk], environment[:ipa_file], environment[:build_dir]

      app_file = File.join build_dir, "#{configuration}-#{sdk}", environment[:app_file]
      app_file += ".app" unless app_file =~ /\.app^/
      
      fail "Couldn't find #{app_file}" unless File.exists? app_file
    
      provisioning_profile_file = find_matching_mobile_provision environment[:provisioning_profile]
      fail "Unable to find matching provisioning profile for '#{environment[:provisioning_profile]}'" if provisioning_profile_file.empty?
          
      puts "Creating #{ipa_file}"
      log_file = File.join build_dir, "ipa.log"
      command = "xcrun -sdk #{sdk} PackageApplication -v '#{app_file}' -o '#{File.expand_path ipa_file}' --sign '#{environment[:developer_certificate]}' --embed '#{provisioning_profile_file}'", :results => log_file
      puts command
      run_command command
    end
    
    def find_matching_mobile_provision match_text
      `grep -rl '#{match_text}' '#{ENV['HOME']}/Library/MobileDevice/Provisioning\ Profiles/'`.strip
    end
    
  end
end
