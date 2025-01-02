require 'fastlane/action'
require_relative '../helper/mobcicd_helper'

module Fastlane
  module Actions
    module SharedValues
    end

    class LintCiAction < Action

      def self.run(params)
        Helper::MobcicdHelper.load_code_config_file if Actions.lane_context[SharedValues::MOBILE_PARAMS].nil?
        config_file = Helper::MobcicdHelper.get_param[:MOBILE_LINT_CONFIG]
        mode = Helper::MobcicdHelper.get_param[:MOBILE_LINT_MODE]
        files = Helper::MobcicdHelper.get_param[:MOBILE_LINT_FILES]
        options = { mode: mode, config_file: config_file }
        options[:files] = files unless files.to_s.empty?
        options[:ignore_exit_status] = true
        UI.message("Running lint... with mode: #{mode} and config file: #{config_file}")
        other_action.swiftlint(options)
        UI.success("Lint passed...")
      end

      def self.description
        "Lint the project"
      end

      def self.authors
        ["Productivity & Developer Experience"]
      end

      def self.details
        [
        "SwiftLint enforces the style guide rules that are generally accepted by the Swift community.",
        "It is a tool to enforce Swift style and conventions, loosely based on the now archived GitHub Swift Style Guide."
        ].join("\n")
      end

      def self.is_supported?(platform)
         [:ios].include?(platform)
      end
    end
  end
end
