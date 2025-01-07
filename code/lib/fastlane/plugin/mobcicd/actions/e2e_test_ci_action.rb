require 'fastlane/action'
require_relative '../helper/mobcicd_helper'

module Fastlane
  module Actions
    module SharedValues
    end

    class E2eTestCiAction < Action

      def self.run(params)
        cloned_source_packages_path =  Helper::MobcicdHelper.retrive_source_packages_path workspace: params[:workspace]
        options = {
          workspace: params[:workspace],
          scheme: params[:scheme],
          configuration: params[:configuration],
          derived_data_path: params[:derived_data_path],
          cloned_source_packages_path: cloned_source_packages_path,
          device: params[:device],
          clean: true,
          code_coverage: true,
          reset_simulator: true,
          include_simulator_logs: false,
          output_types: "html,junit",
          output_directory: params[:output_directory],
          fail_build: true
        }
        options[:testplan] = params[:testplan] unless params[:testplan].to_s.empty?
        UI.message("Running E2E tests... with scheme: #{params[:scheme]} and testplan: #{params[:testplan]}")
        other_action.scan(options)
        UI.success("Tests E2E passed...")
      end

      def self.description
        "Execute e2e tests"
      end

      def self.authors
        ["Productivity & Developer Experience"]
      end

      def self.details
        [
        "Execute e2e tests"
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
          FastlaneCore::ConfigItem.new(key: :testplan,
                                        env_name: "MOBILE_TESTPLAN",
                                        description: "Project's Testplan",
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
          FastlaneCore::ConfigItem.new(key: :output_directory,
                                        env_name: "MOBILE_OUTPUT_DIRECTORY",
                                        description: "Output directory",
                                        optional: false,
                                        type: String),
          FastlaneCore::ConfigItem.new(key: :derived_data_path,
                                        env_name: "MOBILE_DERIVED_DATA_PATH",
                                        description: "Derived data path",
                                        optional: true,
                                        type: String)
        ]
      end

    end
  end
end
