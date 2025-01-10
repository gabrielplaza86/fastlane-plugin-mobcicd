require 'fastlane/action'
require_relative '../helper/mobcicd_helper'

module Fastlane
  module Actions
    module SharedValues
    end

    class PublishArtifactCiAction < Action

      def self.run(params)
        platform =  Actions.lane_context[Actions::SharedValues::PLATFORM_NAME]
        UI.user_error!("`DP_TOKEN` environment variable is not set.") unless ENV["DP_TOKEN"]
        if platform.nil? || platform == :ios
          publish_ios_artifact(params)
        else
          publish_android_artifact(params)
        end
        download_link = "#{Actions.lane_context[SharedValues::ARTIFACTORY_DOWNLOAD_URL]}"
        UI.message("Download link: #{download_link}")
        Helper::MobcicdHelper.export_github_vars :github_export => "GITHUB_ENV", :vars => { "DOWNLOAD_LINK": download_link }, :dump => false
      end

      def self.publish_ios_artifact(options)
        Helper::MobcicdHelper.load_code_config_file if Actions.lane_context[SharedValues::MOBILE_PARAMS].nil?
        filename	= options[:filename] || File.basename(options[:file])
        other_action.artifactory(
          api_key: ENV["DP_TOKEN"], # pragma: allowlist secret
          endpoint: options[:endpoint],
          file: options[:file],
          repo: options[:repo],
          repo_path: "/#{Helper::MobcicdHelper.get_param[:MOBILE_PROJECT_KEY]}/#{filename}",
        )
      end

      def self.publish_android_artifact(options)
        pom_files = Dir.glob("#{Dir.pwd}/**/build/repo/**/*.pom")
        aar_jar_files = Dir.glob("#{Dir.pwd}/**/build/repo/**/*.{aar,jar}")

        pom_files.each_with_index do |pom_path, index|
          aar_jar_path = aar_jar_files.find { |path| File.basename(path, ".*") == File.basename(pom_path, ".pom") }
          next unless aar_jar_path
          artifactory_pom = pom_path.gsub(%r{^.*/build/repo/}, '')
          artifactory_aar_jar = aar_jar_path.gsub(%r{^.*/build/repo/}, '')

          other_action.artifactory(
            api_key: ENV["DP_TOKEN"], # pragma: allowlist secret
            endpoint: options[:endpoint],
            repo: options[:repo],
            file: pom_path,
            repo_path: artifactory_pom,
          )

          other_action.artifactory(
            api_key: ENV["DP_TOKEN"], # pragma: allowlist secret
            endpoint: options[:endpoint],
            repo: options[:repo],
            file: aar_jar_path,
            repo_path: artifactory_aar_jar,
          )
        end
      end

      def self.description
        "Publish artifact to Artifactory"
      end

      def self.authors
        ["Productivity & Developer Experience"]
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :endpoint,
                                       env_name: "MOBILE_ARTIFACTORY_ENDPOINT",
                                       description: "Artifactory endpoint",
                                       optional: false,
                                       type: String),
          FastlaneCore::ConfigItem.new(key: :file,
                                        description: "File to be uploaded to artifactory",
                                        optional: true,
                                        type: String),
          FastlaneCore::ConfigItem.new(key: :repo,
                                        description: "Artifactory repo to put the file in",
                                        optional: true,
                                        type: String),
          FastlaneCore::ConfigItem.new(key: :filename,
                                        description: "Filename to use in Artifactory",
                                        optional: true,
                                        type: String)
        ]
      end

      def self.details
        [
        "Publish artifact to Artifactory"
        ].join("\n")
      end

      def self.is_supported?(platform)
         [:ios, :android].include?(platform)
      end
    end
  end
end
