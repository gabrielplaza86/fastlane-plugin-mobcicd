require 'fastlane/action'
require_relative '../helper/mobcicd_helper'

module Fastlane
  module Actions
    module SharedValues
    end

    class ExecutesE2eAppiumCiAction < Action

      def self.run(params)
        Helper::MobcicdHelper.load_code_config_file if Actions.lane_context[SharedValues::MOBILE_PARAMS].nil?
        options = {}
        options[:workspace] = Helper::MobcicdHelper.get_param[:MOBILE_WORKSPACE]
        options[:scheme] = Helper::MobcicdHelper.get_param[:MOBILE_SCHEME]
        options[:simulator] = Helper::MobcicdHelper.get_param[:MOBILE_SIMULATOR]
        options[:derived_data_path] = Helper::MobcicdHelper.get_param[:MOBILE_DERIVED_DATA_PATH]
        options[:configuration] = Helper::MobcicdHelper.get_param[:MOBILE_CONFIGURATION]
        options[:device] = Helper::MobcicdHelper.get_param[:MOBILE_DEVICE]
        options[:device_os_version] = Helper::MobcicdHelper.get_param[:MOBILE_DEVICE_OS_VERSION]
        options[:archive_path] = Helper::MobcicdHelper.get_param[:MOBILE_ARCHIVE_PATH]
        options[:export_path] = Helper::MobcicdHelper.get_param[:MOBILE_EXPORT_PATH]
        other_action.e2e_build_ci(options)
      end

      def self.description
        "Executes E2E tests with traffiparrot and appium"
      end

      def self.authors
        ["Productivity & Developer Experience"]
      end

      def self.details
        [
        "Executes E2E tests with traffiparrot and appium"
        ].join("\n")
      end

      def self.is_supported?(platform)
         [:ios].include?(platform)
      end
    end
  end
end
