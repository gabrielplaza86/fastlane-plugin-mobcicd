require 'fastlane/action'
require_relative '../helper/mobcicd_helper'

module Fastlane
  module Actions
    module SharedValues
    end

    class GenerateCoverageCiAction < Action

      def self.run(params)
        Helper::MobcicdHelper.load_code_config_file if Actions.lane_context[SharedValues::MOBILE_PARAMS].nil?

        sonar_exclusions = ENV['SONAR_COVERAGE_EXCLUSIONS']
        if sonar_exclusions.nil? || sonar_exclusions.empty?
          UI.user_error!("SONAR_COVERAGE_EXCLUSIONS environment variable is not set")
        else
          ignore = sonar_exclusions
        end

        scheme = Helper::MobcicdHelper.get_param[:MOBILE_TEST_SCHEME]
        configuration = Helper::MobcicdHelper.get_param[:MOBILE_TEST_BUILD_CONFIG]
        workspace = Helper::MobcicdHelper.get_param[:MOBILE_WORKSPACE]
        output_directory = Helper::MobcicdHelper.get_param[:MOBILE_UT_OUTPUT_PATH]
        build_directory = Helper::MobcicdHelper.get_param[:MOBILE_DERIVED_DATA_PATH]
        project = Helper::MobcicdHelper.get_param[:MOBILE_PROJECT]
        options = {
                    sonarqube_xml: true,
                    scheme:scheme,
                    configuration:configuration,
                    workspace:workspace,
                    output_directory:output_directory,
                    build_directory:build_directory,
                    proj:project,
                    source_directory:'./code', ignore:ignore
                  }
        UI.message("Running Slather... with scheme: #{scheme}")
        other_action.slather(options)
        UI.success("Coverage generated...")
      end

      def self.description
        "Generate coverage report"
      end

      def self.authors
        ["Productivity & Developer Experience"]
      end

      def self.details
        [
        "Generate coverage report"
        ].join("\n")
      end

      def self.is_supported?(platform)
         [:ios].include?(platform)
      end
    end
  end
end
