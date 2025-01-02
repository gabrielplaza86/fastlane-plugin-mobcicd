require 'fastlane/action'
require_relative '../helper/mobcicd_helper'

module Fastlane
  module Actions
    module SharedValues
    end

    class BuildPromoteCiAction < Action

      def self.run(params)
        Helper::MobcicdHelper.load_code_config_file if Actions.lane_context[SharedValues::MOBILE_PARAMS].nil?

        build_json_properties = {}
        build_configurations = JSON.parse(params[:build_configurations])
        provisioning_profiles = other_action.update_project_ci(build_configurations: build_configurations)
        timestamp = Time.now.strftime("%Y%m%d%H%M%S")

        build_configurations.each_with_index do |build_configuration, index|
          path = app_path = ""
          parameters = build_configuration["parameters"]
          configuration = build_configuration["name"]
          code_directory = Helper::MobcicdHelper.get_param[:MOBILE_CODE_DIRECTORY] || File.expand_path("..", Dir.pwd)
          build_directory = parameters["build_directory"] || "build/Build/Products"
          output_name = "#{parameters["scheme"]}_#{index}"
          options = {}
          options[:configuration] = configuration
          options[:scheme] = parameters["scheme"]
          options[:export_method] = parameters["export_method"] || ENV["MOBILE_DISTRIBUTION"].to_s
          options[:skip_codesigning] = options[:export_method].eql?("development")
          options[:skip_archive] = options[:export_method].eql?("development")
          options[:workspace] = parameters["workspace"] if parameters["workspace"]
          options[:project] = parameters["project"] if parameters["project"]
          options[:output_directory] = options[:output_directory] || "build/outputs"
          options[:sdk] = parameters["sdk"] if parameters["sdk"]
          options[:output_name] = parameters["output_name"] || output_name
          options[:derived_data_path] = parameters["derived_data_path"] || ENV["MOBILE_DERIVED_DATA_PATH"].to_s
          options[:cloned_source_packages_path] = Helper::MobcicdHelper.retrive_source_packages_path workspace: options[:workspace]
          options[:clean] = true
          other_action.increment_build_number(build_number: timestamp,xcodeproj: parameters["project"]) if parameters["project"]
          options.delete(:project) unless options[:workspace].to_s.empty?
          options[:export_options] = {
            method: options[:export_method],
            provisioningProfiles: provisioning_profiles[configuration]
          }

          gym(options)
          path = Actions.lane_context[SharedValues::IPA_OUTPUT_PATH]

          if parameters.has_key?("generate_app") && parameters["generate_app"]
            options[:destination] = parameters["destination"] || "generic/platform=iOS Simulator"
            options[:skip_package_ipa] = true
            other_action.gym(options)
            archive_path = Actions.lane_context[SharedValues::XCODEBUILD_ARCHIVE]
            app_directory = Dir.glob("#{archive_path.to_s}/**/*.app").reject { |item| File.symlink?(item) }.first.to_s
            unless app_directory.empty?
              zip_app_folder app_directory: app_directory, output_directory: options[:output_directory], basename: output_name
              app_path = Actions.lane_context[:APP_OUTPUT_PATH].to_s
            end
          end

          build_properties = {}
          build_properties["path"] = path.to_s.gsub("#{options[:project_dir]}/","")
          build_properties["app_path"] = app_path.to_s.gsub("#{options[:project_dir]}/","")
          build_properties["dsym_path"] = Actions.lane_context[SharedValues::DSYM_OUTPUT_PATH].to_s.gsub("#{options[:project_dir]}/","")
          build_properties["archive_path"] = Actions.lane_context[SharedValues::XCODEBUILD_ARCHIVE].to_s.gsub("#{options[:project_dir]}/","")
          build_json_properties["#{configuration}"] = build_properties
        end
        Helper::MobcicdHelper.export_github_vars :github_export => "GITHUB_OUTPUT", :vars => { "build_configurations": build_configurations.map { |bc| bc["name"] }, "build_config_properties": build_json_properties }, :dump => true
        Helper::MobcicdHelper.export_github_vars :github_export => "GITHUB_ENV", :vars => { "MOBILE_OUTPUT_STEP": "build", "MOBILE_OUTPUT_VALUE": "build_config_properties" }, :dump => false
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
