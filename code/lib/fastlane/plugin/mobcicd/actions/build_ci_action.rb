require 'fastlane/action'
require_relative '../helper/mobcicd_helper'

module Fastlane
  module Actions
    module SharedValues
    end

    class BuildCiAction < Action

      def self.run(params)
        Helper::MobcicdHelper.load_code_config_file if Actions.lane_context[SharedValues::MOBILE_PARAMS].nil?

        options = {
          configuration: Helper::MobcicdHelper.get_param[:MOBILE_CONFIGURATION],
          scheme: Helper::MobcicdHelper.get_param[:MOBILE_SCHEME],
          skip_archive: Helper::MobcicdHelper.get_param[:MOBILE_SKIP_ARCHIVE],
          clean: true
        }
        options[:workspace] = Helper::MobcicdHelper.get_param[:MOBILE_WORKSPACE] unless Helper::MobcicdHelper.get_param[:MOBILE_WORKSPACE].to_s.empty?
        options[:project] = Helper::MobcicdHelper.get_param[:MOBILE_PROJECT] unless Helper::MobcicdHelper.get_param[:MOBILE_PROJECT].to_s.empty?
        options[:destination] = Helper::MobcicdHelper.get_param[:MOBILE_DESTINATION] unless Helper::MobcicdHelper.get_param[:MOBILE_DESTINATION].to_s.empty?
        options[:derived_data_path] = ENV["MOBILE_DERIVED_DATA_PATH"].to_s unless ENV["MOBILE_DERIVED_DATA_PATH"].to_s.empty?
        options[:cloned_source_packages_path] = Helper::MobcicdHelper.retrive_source_packages_path workspace: options[:workspace]
        options[:output_directory] = ENV["OUTPUTS_DIRECTORY"] || "build/outputs"
        options.delete(:project) unless options[:workspace].to_s.empty?
        options[:export_options] = {
            method: Helper::MobcicdHelper.get_param[:MOBILE_EXPORT_METHOD],
            provisioningProfiles: JSON.parse(config_provisioning_profiles)[options[:configuration]]
        } if Helper::MobcicdHelper.get_param[:MOBILE_PROVISIONING_PROFILES]

        UI.message("Building project... with configuration: #{options[:configuration]} and scheme: #{options[:scheme]}")
        other_action.gym(options)
        UI.success("Build passed...")
        Helper::MobcicdHelper.export_github_vars :github_export => "GITHUB_ENV", :vars => { "MOBILE_CRASH_FILE": Actions.lane_context[SharedValues::DSYM_OUTPUT_PATH].to_s }, :dump => false
        generate_extra_paths
      end

      def self.config_provisioning_profiles
        if Helper::MobcicdHelper.get_param[:MOBILE_PROVISIONING_PROFILES]
          build_configuration = {}
          build_configuration["name"] = Helper::MobcicdHelper.get_param[:MOBILE_CONFIGURATION]
          build_configuration["parameters"] = {}
          build_configuration["parameters"]["project"] = Helper::MobcicdHelper.get_param[:MOBILE_PROJECT]
          build_configuration["parameters"]["scheme"] = Helper::MobcicdHelper.get_param[:MOBILE_SCHEME]
          build_configuration["parameters"]["provisioning_profiles"] = JSON.parse(Helper::MobcicdHelper.get_param[:MOBILE_PROVISIONING_PROFILES])
          provision_profile = other_action.update_project_ci(build_configurations: [build_configuration])
          return JSON.dump(provision_profile)
        end
      end

      def self.generate_extra_paths
        full_build_path = Helper::MobcicdHelper.get_param[:MOBILE_FULL_OUTPUT_PATH]
        begin
          other_action.version_ci
        rescue Exception => e
          UI.error "Version not found: #{e}"
        end
        Helper::MobcicdHelper.export_github_vars :github_export => "GITHUB_ENV", :vars => { "MOBILE_FULL_BUILD_PATH": full_build_path }, :dump => false
        Helper::MobcicdHelper.export_github_vars :github_export => "GITHUB_ENV", :vars => { "MOBILE_DISTRIBUTE_ON": Helper::MobcicdHelper.get_param[:MOBILE_DISTRIBUTE_ON] }, :dump => true
      end

      def self.description
        "Resign the ipa file"
      end

      def self.authors
        ["Productivity & Developer Experience"]
      end

      def self.details
        [
        "Resign the ipa file"
        ].join("\n")
      end

      def self.is_supported?(platform)
         [:ios].include?(platform)
      end
    end
  end
end
