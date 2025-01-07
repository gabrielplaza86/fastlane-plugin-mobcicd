require 'fastlane/action'
require_relative '../helper/mobcicd_helper'

module Fastlane
  module Actions
    module SharedValues
    end

    class ExecutesE2eTpCiAction < Action

      def self.run(params)
        Helper::MobcicdHelper.load_code_config_file if Actions.lane_context[SharedValues::MOBILE_PARAMS].nil?
        options = {}
        options[:workspace] = Helper::MobcicdHelper.get_param[:MOBILE_WORKSPACE]
        options[:scheme] = Helper::MobcicdHelper.get_param[:MOBILE_E2E_TP_SCHEME]
        options[:testplan] = Helper::MobcicdHelper.get_param[:MOBILE_E2E_TP_TESTPLAN]
        options[:output_directory] = Helper::MobcicdHelper.get_param[:MOBILE_E2E_TP_OUTPUT_PATH]
        options[:derived_data_path] = Helper::MobcicdHelper.get_param[:MOBILE_DERIVED_DATA_PATH]
        options[:configuration] = Helper::MobcicdHelper.get_param[:MOBILE_E2E_TP_BUILD_CONFIG]
        options[:device] = Helper::MobcicdHelper.get_param[:MOBILE_E2E_TP_DEVICE]
        other_action.e2e_test_ci(options)
      end

      def self.description
        "Executes E2E tests with Traffic Parrot"
      end

      def self.authors
        ["Productivity & Developer Experience"]
      end

      def self.details
        [
        "Executes E2E tests with Traffic Parrot"
        ].join("\n")
      end

      def self.is_supported?(platform)
         [:ios].include?(platform)
      end
    end
  end
end
