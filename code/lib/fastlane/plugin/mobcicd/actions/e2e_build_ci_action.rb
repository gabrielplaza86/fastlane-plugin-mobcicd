require 'fastlane/action'
require_relative '../helper/mobcicd_helper'

module Fastlane
  module Actions
    module SharedValues
    end

    class E2eBuildCiAction < Action

      def self.run(params)
        destination = "platform=iOS Simulator,name=#{params[:device]},OS=#{params[:device_os_version]}"
        export_path_arranged = "#{File.expand_path("..", Dir.pwd)}/#{params[:export_path]}"
        options = {
          workspace: params[:workspace],
          scheme: params[:scheme],
          sdk: params[:simulator],
          configuration: params[:configuration],
          derived_data_path: params[:derived_data_path],
          archive_path: params[:archive_path],
          skip_codesigning: true,
          destination: destination,
          xcargs: "IPHONEOS_DEPLOYMENT_TARGET='#{params[:device_os_version]}' CODE_SIGNING_ALLOWED='NO' SYMROOT='#{export_path_arranged}'"
        }
        UI.message("Building app for E2E... with scheme: #{params[:scheme]}")
        other_action.xcodebuild(options)
        UI.success("App compiled...")
      end

      def self.description
        "Execute e2e build"
      end

      def self.authors
        ["Productivity & Developer Experience"]
      end

      def self.details
        [
        "Execute e2e build"
        ].join("\n")
      end

      def self.is_supported?(platform)
         [:ios].include?(platform)
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :workspace,
                                        env_name: "MOBILE_WORKSPACE",
                                        description: "Project's Workspace",
                                        optional: false,
                                        type: String),
          FastlaneCore::ConfigItem.new(key: :scheme,
                                       env_name: "MOBILE_SCHEME",
                                       description: "Project's Scheme",
                                       optional: false,
                                       type: String),
          FastlaneCore::ConfigItem.new(key: :simulator,
                                        env_name: "MOBILE_SIMULATOR",
                                        description: "Simulator to run the tests",
                                        optional: true,
                                        type: String),
          FastlaneCore::ConfigItem.new(key: :configuration,
                                        env_name: "MOBILE_CONFIGURATION",
                                        description: "Project's Configuration",
                                        optional: false,
                                        type: String),
          FastlaneCore::ConfigItem.new(key: :device,
                                        env_name: "MOBILE_DEVICE",
                                        description: "Device to run the tests",
                                        optional: false,
                                        type: String),
          FastlaneCore::ConfigItem.new(key: :device_os_version,
                                        env_name: "MOBILE_DEVICE_OS_VERSION",
                                        description: "Device OS version",
                                        optional: false,
                                        type: String),
          FastlaneCore::ConfigItem.new(key: :derived_data_path,
                                        env_name: "MOBILE_DERIVED_DATA_PATH",
                                        description: "Derived data path",
                                        optional: true,
                                        type: String),
          FastlaneCore::ConfigItem.new(key: :archive_path,
                                        env_name: "MOBILE_ARCHIVE_PATH",
                                        description: "Archive path",
                                        optional: true,
                                        type: String),
          FastlaneCore::ConfigItem.new(key: :export_path,
                                        env_name: "MOBILE_EXPORT_PATH",
                                        description: "Export path",
                                        optional: true,
                                        type: String)
        ]
      end

    end
  end
end
