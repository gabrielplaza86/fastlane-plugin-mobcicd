require 'fastlane/action'
require_relative '../helper/mobcicd_helper'

module Fastlane
  module Actions
    module SharedValues
    end

    class GenerateCompressFileCiAction < Action

      def self.run(params)
        Helper::MobcicdHelper.load_code_config_file if Actions.lane_context[SharedValues::MOBILE_PARAMS].nil?
        version = Actions.lane_context[SharedValues::MOBCICD_VERSION] || other_action.version_ci
        project_key = Helper::MobcicdHelper.get_param[:MOBILE_PROJECT_KEY]
        extension = "tar.gz"
        file_name	= "#{project_key}-#{version}.#{extension}"
        input = Helper::MobcicdHelper.get_param[:MOBILE_FULL_OUTPUT_PATH]
        full_path = "#{Helper::MobcicdHelper.get_param[:MOBILE_CODE_DIRECTORY]}/#{file_name}"
        if file_name.include?(".zip")
          compress_zipped :input => "#{input}", :output => "#{full_path}"
        else
          compress_gzipped :input => "#{input}", :output => "#{full_path}"
        end
        full_path
      end

      def self.compress_gzipped(options)
        Action.sh "tar -czf #{options[:output]} -C #{options[:input]} `ls -A #{options[:input]}`"
      end

      def self.compress_zipped(options)
        other_action.zip(
          path: options[:input],
          output_path: options[:output],
          verbose: false
        )
      end

      def self.description
        "Generate compress file"
      end

      def self.authors
        ["Productivity & Developer Experience"]
      end

      def self.details
        [
        "Generate compress file"
        ].join("\n")
      end

      def self.is_supported?(platform)
         [:ios].include?(platform)
      end
    end
  end
end
