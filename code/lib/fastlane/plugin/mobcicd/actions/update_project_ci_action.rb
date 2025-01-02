require 'fastlane/action'
require_relative '../helper/mobcicd_helper'

module Fastlane
  module Actions
    module SharedValues
    end

    class UpdateProjectCiAction < Action

      def self.run(params)
        provisioning_profiles = {}
        params[:skip_update_code_signing] ||= false
        build_configurations = params[:build_configurations]
        build_configurations.each do |build_configuration|

          code_sign_identity = ENV["CODE_SIGN_IDENTITY"]
          team_id = ENV["DEVELOPMENT_TEAM_ID"]
          configuration = build_configuration["name"]
          parameters = build_configuration["parameters"]
          path = parameters["project"]
          provisioning_profiles[configuration] = {}
          parameters["provisioning_profiles"].each do |provisioning_profile|
            app_identifier = provisioning_profile["app_identifier"]
            provision_name = provisioning_profile["provision_name"]
            target_filter = provisioning_profile["target_filter"]
            if params[:skip_update_code_signing]
              provisioning_profiles[configuration][app_identifier] = "#{ENV["PROVISION_PROFILE_DIR"]}/#{provision_name.gsub(" ","_")}.mobileprovision"
            else
              provisioning_profiles[configuration][app_identifier] = provision_name
            end

            other_action.update_code_signing_settings(
              use_automatic_signing: false,
              code_sign_identity: code_sign_identity,
              team_id: team_id,
              bundle_identifier: app_identifier,
              profile_name: provision_name,
              targets: [target_filter],
              path: path,
              build_configurations: [configuration]
            ) unless params[:skip_update_code_signing]
          end
        end
        provisioning_profiles
      end

      def self.description
        "Update the project configuration"
      end

      def self.authors
        ["Productivity & Developer Experience"]
      end

      def self.details
        [
        "Update the project configuration"
        ].join("\n")
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :build_configurations,
                                        env_name: "MOBILE_BUILD_CONFIGURATIONS",
                                        description: "The build configurations",
                                        optional: false,
                                        type: Array),
          FastlaneCore::ConfigItem.new(key: :skip_update_code_signing,
                                       env_name: "MOBILE_SKIP_UPDATE_CODE_SIGNING",
                                       description: "Skip update code signing",
                                       optional: true,
                                       type: Boolean)
        ]
      end

      def self.is_supported?(platform)
         [:ios].include?(platform)
      end
    end
  end
end
