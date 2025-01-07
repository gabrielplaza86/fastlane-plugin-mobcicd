require 'fastlane/action'
require_relative '../helper/mobcicd_helper'

module Fastlane
  module Actions
    module SharedValues
    end

    class PublishArtifactCiAction < Action

      def self.run(params)
        Helper::MobcicdHelper.load_code_config_file if Actions.lane_context[SharedValues::MOBILE_PARAMS].nil?
        filename	= params[:filename] || File.basename(params[:file])
        other_action.artifactory(
          api_key: ENV["DP_TOKEN"], # pragma: allowlist secret
          endpoint: params[:endpoint],
          file: params[:file],
          repo: params[:repo],
          repo_path: "/#{Helper::MobcicdHelper.get_param[:MOBILE_PROJECT_KEY]}/#{filename}",
        )
        download_link = "#{Actions.lane_context[SharedValues::ARTIFACTORY_DOWNLOAD_URL]}"
        UI.message("Download link: #{download_link}")
        Helper::MobcicdHelper.export_github_vars :github_export => "GITHUB_ENV", :vars => { "DOWNLOAD_LINK": download_link }, :dump => false
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
         [:ios].include?(platform)
      end
    end
  end
end
