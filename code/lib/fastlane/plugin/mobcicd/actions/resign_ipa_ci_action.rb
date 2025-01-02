require 'fastlane/action'
require_relative '../helper/mobcicd_helper'

module Fastlane
  module Actions
    module SharedValues
    end

    class ResignIpaCiAction < Action

      def self.run(params)
        build_configurations = JSON.parse(options[:build_configurations])
        build_config_properties = JSON.parse(options[:build_config_properties])
        provisioning_profiles = other_action.update_project_ci(build_configurations: build_configurations, skip_update_code_signing: true)
        build_config_properties.each do |config_name, properties|
          other_action.resign(
            ipa: properties["path"],
            signing_identity: ENV["CODE_SIGN_IDENTITY"],
            provisioning_profile: provisioning_profiles[config_name]
          )
        end
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
