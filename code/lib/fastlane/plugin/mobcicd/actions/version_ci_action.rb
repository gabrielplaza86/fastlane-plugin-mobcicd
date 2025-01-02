require 'fastlane/action'
require_relative '../helper/mobcicd_helper'

module Fastlane
  module Actions
    module SharedValues
      MOBILE_PARAMS = :MOBILE_PARAMS
      MOBCICD_VERSION = :MOBCICD_VERSION
    end

    class VersionCiAction < Action
      MOBILE_TYPES = %w[mlb mob]
      def self.run(params)
        Helper::MobcicdHelper.load_code_config_file if Actions.lane_context[SharedValues::MOBILE_PARAMS].nil?
        value = custom_version_ci
        unless value.to_s.empty?
          Actions.lane_context[SharedValues::MOBCICD_VERSION] = value
          Helper::MobcicdHelper.export_github_vars :github_export => "GITHUB_ENV", :vars => { "MOBILE_VERSION": value }, :dump => false
          UI.success("Version: #{value}")
        end
        return value
      end

      def self.custom_version_ci
        UI.user_error!("`MOBILE_TYPE` environment variable is not set. Use `mlb` or `mob` values") unless ENV["MOBILE_TYPE"]
        UI.user_error!("`MOBILE_TYPE` #{ENV["MOBILE_TYPE"]} environment value is invalid. Use `mlb` or `mob` values") unless MOBILE_TYPES.include?(ENV["MOBILE_TYPE"].downcase)
        mobile_type = ENV["MOBILE_TYPE"].downcase
        eval("custom_version_ci_for_#{mobile_type}")
      end

      def self.custom_version_ci_for_mob
        version_ci_from_xcodeproj
      end

      def self.custom_version_ci_for_mlb
        UI.message("Receive the version number from module metadata file")
        output_path = Helper::MobcicdHelper.get_param[:MOBILE_FULL_OUTPUT_PATH]
        module_metadata = Helper::MobcicdHelper.get_param[:MOBILE_MODULE_METADATA]
        version = File.open(module_metadata).grep(/version/).first.scan(/\d\.\d\.\d+[-\w]*/).first if module_metadata

        if version.to_s.empty?
          UI.important("Version not found in module metadata file, using version from cocoapos spec file")
          version = version_ci_from_cocoapod_spec
          if version.to_s.empty?
            UI.important("Version not found in cocoapod spec file, using version from xcodeproj")
            version = version_ci_from_xcodeproj
          end
        end
        version
      end

      def self.version_ci_from_xcodeproj
        command = "xcodebuild -showBuildSettings -scheme #{Helper::MobcicdHelper.get_param[:MOBILE_SCHEME]} -project #{Helper::MobcicdHelper.get_param[:MOBILE_PROJECT]} -configuration #{Helper::MobcicdHelper.get_param[:MOBILE_CONFIGURATION]} 2>&1 | grep MARKETING_VERSION"
        version = Action.sh(command, print_command: true, print_command_output: false, error_callback: proc { |result| UI.error("Error: #{result}") })
        version = version.split("=").last.to_s.strip
        if version.to_s.empty?
          UI.important("Version not found in xcodeproj")
        else
          UI.success("Version from xcodeproj: #{version}")
        end
        version
      end

      def self.version_ci_from_cocoapod_spec
        spec_file = Helper::MobcicdHelper.find_cocoapod_spec_file
        if spec_file.to_s.empty?
          UI.important("Cocoapod spec file not found")
        else
          version = other_action.version_get_podspec(path: spec_file)
          UI.message("Version from cocoapod spec file: #{version}")
        end
        version
      end



      def self.description
        "Retrive the current version of the project"
      end

      def self.authors
        ["Productivity & Developer Experience"]
      end

      def self.return_value
        "Returns the current version of the project as a string and set the environment variable MOBCICD_VERSION"
      end

      def self.output
        [
          ['MOBCICD_VERSION', 'The current version of the project']
        ]
      end

      def self.details
        [
          "This action retrieves the current version of the project.",
          "The version is retrieved from the xcodeproj file or the cocoapod spec file.",
        ].join("\n")
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :mobile_type,
                                       env_name: "MOBILE_TYPE",
                                       description: "The type of the mobile project",
                                       optional: false)
        ]
      end

      def self.is_supported?(platform)
         [:ios].include?(platform)
      end
    end
  end
end
