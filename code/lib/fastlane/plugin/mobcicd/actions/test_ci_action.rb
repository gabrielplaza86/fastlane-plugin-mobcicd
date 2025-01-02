require 'fastlane/action'
require_relative '../helper/mobcicd_helper'

module Fastlane
  module Actions
    module SharedValues
    end

    class TestCiAction < Action

      def self.run(params)
        Helper::MobcicdHelper.load_code_config_file if Actions.lane_context[SharedValues::MOBILE_PARAMS].nil?
        workspace = Helper::MobcicdHelper.get_param[:MOBILE_WORKSPACE]
        scheme = Helper::MobcicdHelper.get_param[:MOBILE_TEST_SCHEME]
        testplan = Helper::MobcicdHelper.get_param[:MOBILE_TEST_PLAN]
        configuration = Helper::MobcicdHelper.get_param[:MOBILE_TEST_CONFIGURATION]
        device = Helper::MobcicdHelper.get_param[:MOBILE_TEST_DEVICE]
        options = { workspace: workspace, scheme: scheme, clean: true, device: device, output_types: "html,junit", xcodebuild_formatter: "xcbeautify", fail_build: true, code_coverage: true, include_simulator_logs: false }
        options[:derived_data_path] = Helper::MobcicdHelper.get_param[:MOBILE_DERIVED_DATA_PATH] || ENV["MOBILE_DERIVED_DATA_PATH"].to_s
        options[:cloned_source_packages_path] = Helper::MobcicdHelper.retrive_source_packages_path workspace: workspace
        options[:testplan] = testplan unless testplan.to_s.empty?
        options[:configuration] = configuration unless configuration.to_s.empty?
        options[:output_directory] = Helper::MobcicdHelper.get_param[:MOBILE_OUTPUT_DIRECTORY]
        options[:output_files] = Helper::MobcicdHelper.get_param[:MOBILE_OUTPUT_FILES]
        UI.message("Running tests... with scheme: #{scheme} and testplan: #{testplan}")
        other_action.scan(options)
        UI.success("Tests passed...")
        UI.success("Converting Files...")
        sonarqube_test_report
      end

      def self.sonarqube_test_report
        other_action.forsis(
          junit_report_file: "#{Helper::MobcicdHelper.get_param[:MOBILE_CODE_DIRECTORY]}/test-reports/unit-test-report.junit",
          sonar_report_directory: "#{Helper::MobcicdHelper.get_param[:MOBILE_CODE_DIRECTORY]}/unit-test-output/"
        )
      end

      def self.description
        "Run all the tests of the project"
      end

      def self.authors
        ["Productivity & Developer Experience"]
      end

      def self.details
        [
        "Run all the tests of the project"
        ].join("\n")
      end

      def self.is_supported?(platform)
         [:ios].include?(platform)
      end
    end
  end
end
