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
        UI.message("Building app for E2E... with scheme: #{scheme}")
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
    end
  end
end
