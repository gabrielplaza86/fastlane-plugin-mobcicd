require 'fastlane/action'
require_relative '../helper/mobcicd_helper'

module Fastlane
  module Actions
    module SharedValues
    end

    class BumpDevelopmentVersionCiAction < Action
      def self.run(params)
        current_version = Actions.lane_context[SharedValues::MOBCICD_VERSION] || other_action.version_ci
        current_version = current_version.gsub("-SNAPSHOT", "")
        new_version = custom_increment_version_number_ci(
          version_number: current_version,
          bump_type: Helper::MobcicdHelper.get_param[:MOBILE_BUMP_TYPE]
        )
        new_version = "#{new_version}-SNAPSHOT"
        other_action.bump_version_ci new_version: new_version
      end

      def self.custom_increment_version_number_ci(options)
        sem_ver = options[:version_number]
        increment_type = options[:bump_type]
        if not /\d+\.\d+\.\d+/.match(sem_ver)
          raise "Your semantic version must match the format 'X.X.X'."
        end
        if not ["patch", "minor", "major"].include?(increment_type)
          raise "Only 'patch', 'minor' and 'major' are supported increment types."
        end
        major, minor, patch = sem_ver.split(".")
        case increment_type
          when "patch"
            patch = patch.to_i + 1
          when "minor"
            minor = minor.to_i + 1
            patch = 0
          when "major"
            major = major.to_i + 1
            minor = 0
            patch = 0
        end
        "#{major}.#{minor}.#{patch}"
      end

      def self.description
        "Bump development the project version"
      end

      def self.authors
        ["Productivity & Developer Experience"]
      end

      def self.return_value
        "Returns the bump development version of the project as a string and set the environment variable MOBCICD_VERSION"
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
                                        type: String,
                                        verify_block: proc do |value|
                                          UI.user_error!("No API token for App Center given, pass using `api_token: 'token'`") unless value && !value.empty?
                                        end),
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
