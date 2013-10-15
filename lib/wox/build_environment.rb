require 'plist'

module Wox
  module Environment
    attr_reader :environment
    def initialize environment
      @environment = environment
    end
  end

  class BuildEnvironment
    attr_reader :info_plist, :build_dir, :default_sdk

    def best_selector(selectors)
      res = (selectors.drop_while {|sel| sel[:arg] == nil || sel[:arg].empty? }).first
      res[:class].new(res[:arg]) unless res == nil
    end

    def initialize options
      @options = options

      options[:info_plist] ||= 'Resources/Info.plist'
      options[:version] ||= Plist::parse_xml(options[:info_plist])['CFBundleVersion']
      options[:build_dir] ||= `pwd`.strip() + '/build'
      options[:sdk] ||= 'iphoneos'
      options[:configuration] ||= 'Release'
      options[:build_selector] = best_selector([{:class => WorkspaceBuildSelector, :arg => options[:workspace_name]},
                                                {:class => ProjectBuildSelector, :arg => options[:project_name]},
                                                {:class => WorkspaceBuildSelector, :arg => workspaces.first},
                                                {:class => ProjectBuildSelector, :arg => projects.first}])
      options[:target_selector] = best_selector([{:class => SchemeSelector, :arg => options[:scheme]},
                                                 {:class => TargetSelector, :arg => options[:target]},
                                                 {:class => SchemeSelector, :arg => schemes.first},
                                                 {:class => TargetSelector, :arg => targets.first}])

      name = options[:build_selector].build_name
      options[:full_name] ||= "#{name} #{self[:version]}"

      options[:app_file] ||= name

      if options[:ipa_name]
        options[:ipa_file] ||= File.join self[:build_dir],
                                [self[:ipa_name], self[:version], self[:configuration]].join("-") + ".ipa"
        options[:dsym_file] ||= File.join self[:build_dir],
                                [self[:ipa_name], self[:version], self[:configuration]].join("-") + ".dSYM.zip"
      end
    end

    def apply options, &block
      yield BuildEnvironment.new @options.merge(options)
    end

    def version
      self[:version]
    end

    def sdks
      @sdks ||= `xcodebuild -showsdks`.scan(/-sdk (.*?$)/m).flatten
    end

    def configurations
      @configurations ||= begin
        start_line = xcodebuild_list.find_index{ |l| l =~ /configurations/i } + 1
        end_line = xcodebuild_list.find_index{ |l| l =~ /if no/i } - 1
        xcodebuild_list.slice start_line...end_line
      end
    end

    def targets
      @targets ||= begin
        start_line = xcodebuild_list.find_index{ |l| l =~ /targets/i } + 1
        end_line = xcodebuild_list.find_index{ |l| l =~ /configurations/i } - 1
        xcodebuild_list.slice(start_line...end_line).map{|l| l.gsub('(Active)','').strip }
      end
    end

    def workspaces
      @workspaces = Dir.glob("*.xcworkspace")
    end

    def projects
      @projects = Dir.glob("*.xcodeproj")
    end

    def schemes
      @schemes ||= begin
        start_line = xcodebuild_list.find_index{ |l| l =~ /schemes/i } + 1
        end_line = xcodebuild_list.find_index{ |l| l =~ /if no/i } - 1
        xcodebuild_list.slice start_line...end_line
      end
    end

    def [](name)
      fail "You need to specify :#{name} in Rakefile" unless @options[name]
      @options[name].respond_to?(:call) ? @options[name].call : @options[name]
    end

    def has_entry? name
      @options[name]
    end

    private
      def xcodebuild_list
        @xcodebuild_list ||= `xcodebuild -list`.lines.map{|l| l.strip }.to_a
      end

  end
end
