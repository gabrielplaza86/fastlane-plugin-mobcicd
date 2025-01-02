require 'fastlane_core/ui/ui'

module Fastlane
  UI = FastlaneCore::UI unless Fastlane.const_defined?(:UI)

  module Helper
    class MobcicdHelper
      def self.load_code_config_file
        config_settings = generate_config_settings
        configuration = config_settings["name"]
        parameters = config_settings["parameters"]
        load_shared_values(configuration, parameters)
      end

      def self.generate_config_settings
        namespace = ENV["MOBILE_NAMESPACE"] || "default"
        ENV["SKIP_ARCHIVE"] = "false" if namespace.eql? "release"
        UI.message("Loading config settings for namespace: #{namespace}")
        config = YAML.load_file("#{File.expand_path("fastlane/config.yml", Dir.pwd)}", aliases: true)
        struct = OpenStruct.new(config)[namespace]
        struct ? struct.first : OpenStruct.new(config)["default"].first
      end

      def self.get_param
        Actions.lane_context[Actions::SharedValues::MOBILE_PARAMS]
      end

      def self.load_shared_values(configuration, parameters)
        Actions.lane_context[Actions::SharedValues::MOBILE_PARAMS] = {}
        Actions.lane_context[Actions::SharedValues::MOBILE_PARAMS][:MOBILE_TYPE] = ENV["MOBILE_TYPE"].to_s.downcase || "mob"
        Actions.lane_context[Actions::SharedValues::MOBILE_PARAMS][:MOBILE_CODE_DIRECTORY] = Dir.pwd
        Actions.lane_context[Actions::SharedValues::MOBILE_PARAMS][:MOBILE_CONFIGURATION] = configuration
        Actions.lane_context[Actions::SharedValues::MOBILE_PARAMS][:MOBILE_WORKSPACE] = parameters["workspace"]
        Actions.lane_context[Actions::SharedValues::MOBILE_PARAMS][:MOBILE_PROJECT] = parameters["project"]
        Actions.lane_context[Actions::SharedValues::MOBILE_PARAMS][:MOBILE_SCHEME] = parameters["scheme"]
        Actions.lane_context[Actions::SharedValues::MOBILE_PARAMS][:MOBILE_TARGET] = parameters["target"] if parameters.has_key?("target")
        Actions.lane_context[Actions::SharedValues::MOBILE_PARAMS][:MOBILE_EXPORT_METHOD] = parameters["export_method"] || "enterprise"
        Actions.lane_context[Actions::SharedValues::MOBILE_PARAMS][:MOBILE_SKIP_ARCHIVE] = ENV["SKIP_ARCHIVE"].to_s.empty? ? true : ENV["SKIP_ARCHIVE"]
        Actions.lane_context[Actions::SharedValues::MOBILE_PARAMS][:MOBILE_DESTINATION] = parameters["destination"]
        Actions.lane_context[Actions::SharedValues::MOBILE_PARAMS][:MOBILE_OUTPUT] = "#{ (parameters["output"] || "build") }"
        Actions.lane_context[Actions::SharedValues::MOBILE_PARAMS][:MOBILE_BUMP_TYPE] = parameters["bump_type"] || "minor"
        Actions.lane_context[Actions::SharedValues::MOBILE_PARAMS][:MOBILE_PROVISIONING_PROFILES] = JSON.dump(parameters["provisioning_profiles"]) if parameters.has_key?("provisioning_profiles")
        Actions.lane_context[Actions::SharedValues::MOBILE_PARAMS][:MOBILE_DISTRIBUTE_ON] = parameters["distribute_on"]
        Actions.lane_context[Actions::SharedValues::MOBILE_PARAMS][:MOBILE_OUTPUT_DIRECTORY] = Actions.lane_context[Actions::SharedValues::MOBILE_PARAMS][:MOBILE_CODE_DIRECTORY] + "/test-reports"
        Actions.lane_context[Actions::SharedValues::MOBILE_PARAMS][:MOBILE_OUTPUT_FILES] = "unit-test-report.html,unit-test-report.junit"
        Actions.lane_context[Actions::SharedValues::MOBILE_PARAMS][:MOBILE_PRE_RELEASE_SUFFIX] = parameters["pre_release_suffix"] || "SNAPSHOT"

        if parameters.has_key?("test") && parameters["test"]
          Actions.lane_context[Actions::SharedValues::MOBILE_PARAMS][:MOBILE_TEST_SCHEME] = parameters["test"]["scheme"]
          Actions.lane_context[Actions::SharedValues::MOBILE_PARAMS][:MOBILE_TEST_PLAN] = parameters["test"]["plan"]
          Actions.lane_context[Actions::SharedValues::MOBILE_PARAMS][:MOBILE_TEST_CONFIGURATION] = parameters["test"]["configuration"]
          Actions.lane_context[Actions::SharedValues::MOBILE_PARAMS][:MOBILE_TEST_DEVICE] = parameters["test"]["device"]
        end

        if configuration.eql? "Debug"
          Actions.lane_context[Actions::SharedValues::MOBILE_PARAMS][:MOBILE_TEST_SCHEME] = parameters["scheme"]
          Actions.lane_context[Actions::SharedValues::MOBILE_PARAMS][:MOBILE_TEST_PLAN] = parameters["testplan"]
          Actions.lane_context[Actions::SharedValues::MOBILE_PARAMS][:MOBILE_DERIVED_DATA_PATH] = parameters["derived_data_path"]
          Actions.lane_context[Actions::SharedValues::MOBILE_PARAMS][:MOBILE_EXPORT_PATH] = parameters["export_path"]
          Actions.lane_context[Actions::SharedValues::MOBILE_PARAMS][:MOBILE_ARCHIVE_PATH] = parameters["archive_file_path"]
          Actions.lane_context[Actions::SharedValues::MOBILE_PARAMS][:MOBILE_CONFIGURATION] = parameters["configuration"]
          Actions.lane_context[Actions::SharedValues::MOBILE_PARAMS][:MOBILE_UT_OUTPUT_PATH] = parameters["output_directory"] || Actions.lane_context[Actions::SharedValues::MOBILE_PARAMS][:MOBILE_OUTPUT_DIRECTORY]
          Actions.lane_context[Actions::SharedValues::MOBILE_PARAMS][:MOBILE_DEVICE] = parameters["device"]
        end

        if configuration.eql? "Debug_E2E"
          Actions.lane_context[Actions::SharedValues::MOBILE_PARAMS][:MOBILE_E2E_UT_OUTPUT_PATH] = parameters["output_directory"] || Actions.lane_context[Actions::SharedValues::MOBILE_PARAMS][:MOBILE_OUTPUT_DIRECTORY]
          Actions.lane_context[Actions::SharedValues::MOBILE_PARAMS][:MOBILE_E2E_TEST_SCHEME] = parameters["scheme"]
          Actions.lane_context[Actions::SharedValues::MOBILE_PARAMS][:MOBILE_E2E_BUILD_CONFIG] = parameters["configuration"]
          Actions.lane_context[Actions::SharedValues::MOBILE_PARAMS][:MOBILE_E2E_SIMULATOR] = parameters["iphone_simulator"]
          Actions.lane_context[Actions::SharedValues::MOBILE_PARAMS][:MOBILE_E2E_DEVICE] = parameters["device"]
          Actions.lane_context[Actions::SharedValues::MOBILE_PARAMS][:MOBILE_E2E_DEVICE_OS_VERSION] = parameters["device_os_version"]
          Actions.lane_context[Actions::SharedValues::MOBILE_PARAMS][:MOBILE_EXPORT_PATH] = parameters["export_path"]
        end

        if configuration.eql? "Debug_E2E_tp"
          Actions.lane_context[Actions::SharedValues::MOBILE_PARAMS][:MOBILE_E2E_TP_SCHEME] = parameters["scheme"]
          Actions.lane_context[Actions::SharedValues::MOBILE_PARAMS][:MOBILE_E2E_TP_BUILD_CONFIG] = parameters["configuration"]
          Actions.lane_context[Actions::SharedValues::MOBILE_PARAMS][:MOBILE_E2E_TP_TESTPLAN] = parameters["testplan"]
          Actions.lane_context[Actions::SharedValues::MOBILE_PARAMS][:MOBILE_E2E_TP_DEVICE] = parameters["device"]
          Actions.lane_context[Actions::SharedValues::MOBILE_PARAMS][:MOBILE_E2E_TP_OUTPUT_PATH] = parameters["output_directory"] || Actions.lane_context[Actions::SharedValues::MOBILE_PARAMS][:MOBILE_OUTPUT_DIRECTORY]
          Actions.lane_context[Actions::SharedValues::MOBILE_PARAMS][:MOBILE_E2E_TP_APIUM_DEVICE] = parameters["device_os_version"]
          Actions.lane_context[Actions::SharedValues::MOBILE_PARAMS][:MOBILE_E2E_TP_SIMULATOR_SDK] = parameters["iphone_simulator"]
          Actions.lane_context[Actions::SharedValues::MOBILE_PARAMS][:MOBILE_EXPORT_PATH] = parameters["export_path"]
        end

        if configuration.eql? "Debug_E2E_XCUI"
          Actions.lane_context[Actions::SharedValues::MOBILE_PARAMS][:MOBILE_E2E_XC_SCHEME] = parameters["scheme"]
          Actions.lane_context[Actions::SharedValues::MOBILE_PARAMS][:MOBILE_E2E_XC_BUILD_CONFIG] = parameters["configuration"]
          Actions.lane_context[Actions::SharedValues::MOBILE_PARAMS][:MOBILE_E2E_XC_TESTPLAN] = parameters["testplan"]
          Actions.lane_context[Actions::SharedValues::MOBILE_PARAMS][:MOBILE_E2E_XC_DEVICE] = parameters["device"]
          Actions.lane_context[Actions::SharedValues::MOBILE_PARAMS][:MOBILE_E2E_XC_OUTPUT_PATH] = parameters["output_directory"] || Actions.lane_context[Actions::SharedValues::MOBILE_PARAMS][:MOBILE_OUTPUT_DIRECTORY]
          Actions.lane_context[Actions::SharedValues::MOBILE_PARAMS][:MOBILE_E2E_XC_APIUM_DEVICE] = parameters["device_os_version"]
          Actions.lane_context[Actions::SharedValues::MOBILE_PARAMS][:MOBILE_E2E_XC_SIMULATOR_SDK] = parameters["iphone_simulator"]
          Actions.lane_context[Actions::SharedValues::MOBILE_PARAMS][:MOBILE_EXPORT_PATH] = parameters["export_path"]
        end

        if parameters.has_key?("lint") && parameters["lint"]
          Actions.lane_context[Actions::SharedValues::MOBILE_PARAMS][:MOBILE_LINT_CONFIG] = parameters["lint"]["config_file"] || "#{parameters["project_key"]}/.swiftlint.yml"
          Actions.lane_context[Actions::SharedValues::MOBILE_PARAMS][:MOBILE_LINT_MODE] = parameters["lint"]["mode"] || "lint"
          Actions.lane_context[Actions::SharedValues::MOBILE_PARAMS][:MOBILE_LINT_FILES] = parameters["lint"]["files"]
        end

        Actions.lane_context[Actions::SharedValues::MOBILE_PARAMS][:MOBILE_FULL_OUTPUT_PATH] = "#{Actions.lane_context[Actions::SharedValues::MOBILE_PARAMS][:MOBILE_CODE_DIRECTORY]}/#{Actions.lane_context[Actions::SharedValues::MOBILE_PARAMS][:MOBILE_OUTPUT]}"

        if Actions.lane_context[Actions::SharedValues::MOBILE_PARAMS][:MOBILE_TYPE].eql? "mlb"
          module_metadata = Dir["#{Actions.lane_context[Actions::SharedValues::MOBILE_PARAMS][:MOBILE_CODE_DIRECTORY]}/**/ModuleMetadata.swift"]
          if module_metadata.empty?
            UI.error("ModuleMetadata.swift not found")
          else
            Actions.lane_context[Actions::SharedValues::MOBILE_PARAMS][:MOBILE_MODULE_METADATA] = module_metadata.first
          end
        end
      end

      def self.find_cocoapod_spec_file
        spec_file = Dir["#{get_param[:MOBILE_CODE_DIRECTORY]}/**/*.podspec"].first
        UI.message("Cocoapod spec file: #{spec_file}")
        spec_file
      end

      def self.export_github_vars(options)
        filename = ENV["#{options[:github_export]}"].to_s
        File.open(filename, 'a') do |fh|
          options[:vars].each do |key, value|
            value = options[:dump] ? JSON.dump(value) : value
            fh.puts "#{key}=#{value}"
          end
        end if File.file?(filename)
      end

      def self.retrive_source_packages_path(options)
        source_packages_path = ENV["MOBILE_SOURCE_PACKAGES_PATH"] || "#{ENV["MOBILE_DERIVED_DATA_PATH"]}/#{File.basename(options[:workspace], ".*")}"
        export_github_vars :github_export => "GITHUB_ENV", :vars => { "MOBILE_SOURCE_PACKAGES_PATH": source_packages_path }, :dump => false
        source_packages_path
      end

    end
  end
end