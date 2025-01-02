describe Fastlane::Actions::MobcicdAction do
  describe '#run' do
    it 'prints a message' do
      expect(Fastlane::UI).to receive(:message).with("The mobcicd plugin is working!")

      Fastlane::Actions::MobcicdAction.run(nil)
    end
  end
end
