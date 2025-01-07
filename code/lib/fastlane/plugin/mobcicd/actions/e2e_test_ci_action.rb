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
    end
  end
end
