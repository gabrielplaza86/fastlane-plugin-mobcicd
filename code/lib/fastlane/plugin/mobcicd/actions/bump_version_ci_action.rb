require 'fastlane/action'
require_relative '../helper/mobcicd_helper'

module Fastlane
  module Actions
    module SharedValues
    end

    class BumpVersionCiAction < Action
      MOBILE_TYPES = %w[mlb mob]
      def self.run(params)
        Helper::MobcicdHelper.load_code_config_file if Actions.lane_context[SharedValues::MOBILE_PARAMS].nil?
        value = custom_bump_version_ci(params)
        unless value.to_s.empty?
          Actions.lane_context[SharedValues::MOBCICD_VERSION] = value
          Helper::MobcicdHelper.export_github_vars :github_export => "GITHUB_ENV", :vars => { "MOBILE_VERSION": value }, :dump => false
          UI.success("Bump Version: #{value}")
        end
        return value
      end

      def self.custom_bump_version_ci(options)
        UI.user_error!("`MOBILE_TYPE` environment variable is not set. Use `mlb` or `mob` values") unless ENV["MOBILE_TYPE"]
        UI.user_error!("`MOBILE_TYPE` #{ENV["MOBILE_TYPE"]} environment value is invalid. Use `mlb` or `mob` values") unless MOBILE_TYPES.include?(ENV["MOBILE_TYPE"].downcase)
        mobile_type = ENV["MOBILE_TYPE"].downcase
        eval("custom_bump_version_ci_for_#{mobile_type}(options)")
      end

      def self.custom_bump_version_ci_for_mob(options)
        bump_version_ci_in_xcodeproj(options)
      end

      def self.custom_bump_version_ci_for_mlb(options)
        new_version = bump_version_ci_in_module_metadata options
        bump_version_ci_in_xcodeproj options
        bump_version_ci_in_cocoapod_spec options
        new_version
      end

      def self.bump_version_ci_in_xcodeproj(options)
        new_version = options[:new_version]
        Action.sh("sed -i '' -e 's/MARKETING_VERSION \\= [^\\;]*\\;/MARKETING_VERSION = #{new_version};/' #{Helper::MobcicdHelper.get_param[:MOBILE_PROJECT]}/project.pbxproj")
        new_version
      end

      def self.bump_version_ci_in_module_metadata(options)
        new_version = options[:new_version]
        module_metadata = Helper::MobcicdHelper.get_param[:MOBILE_MODULE_METADATA]
        if module_metadata.to_s.empty?
          UI.important("Module metadata file not found")
        else
          Action.sh("sed -i '' -e 's/let version[[:blank:]]*=[[:blank:]]*\"[^\"]*\"/let version = \"#{new_version}\"/' #{module_metadata}")
          UI.message("Version from module metadata file: #{new_version}")
        end
        new_version
      end

      def self.bump_version_ci_in_cocoapod_spec(options)
        new_version = options[:new_version]
        spec_file = Helper::MobcicdHelper.find_cocoapod_spec_file
        if spec_file.to_s.empty?
          UI.important("Cocoapod spec file not found")
        else
          other_action.version_bump_podspec(path: spec_file, version_number: new_version)
          UI.message("Version from cocoapod spec file: #{new_version}")
        end
        new_version
      end

      def self.description
        "Bump the project version"
      end

      def self.authors
        ["Productivity & Developer Experience"]
      end

      def self.return_value
        "Returns the bump version of the project as a string and set the environment variable MOBCICD_VERSION"
      end

      def self.output
        [
          ['MOBCICD_VERSION', 'The current version of the project']
        ]
      end

      def self.details
        [
          "A small command line tool to simplify releasing software by updating all version strings in your source code by the correct increment",
          "The version is set in the xcodeproj file or the cocoapod spec file.",
        ].join("\n")
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :new_version,
                                        env_name: "NEW_VERSION",
                                        description: "The new version number",
                                        optional: false,
                                        type: String),
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
