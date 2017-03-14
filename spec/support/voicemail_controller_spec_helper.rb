module VoicemailControllerSpecHelper
  def self.included(test_case)
    test_case.let(:from)    { "sip:user@server.com" }
    test_case.let(:call)    { Adhearsion::Call.new from: from, active?: true }
    test_case.let(:config)  { Voicemail::Plugin.config }
    test_case.let(:greeting) { nil }
    test_case.let(:mailbox) do
      {
        id:            100,
        pin:           1234,
        greeting:      greeting,
        send_email:    true,
        email_address: 'lpradovera@mojolingo.com'
      }
    end
    test_case.let(:storage_instance) { double 'StorageInstance' }
    test_case.let(:metadata) do
      { :mailbox => 100, :storage => storage_instance }
    end

    test_case.subject(:controller) { test_case.described_class.new(call, metadata) }

    test_case.before(:each) do
      expect(storage_instance).to receive(:get_mailbox).with(metadata[:mailbox]).and_return(mailbox)
    end
  end

  def should_play(*args)
    expect(subject).to receive(:play).once.tap { |exp| exp.with(*args) if args.count > 0 }
  end

  def should_ask(*args)
    expect(subject).to receive(:ask).with(*args).once
  end

  def should_invoke(*args)
    expect(subject).to receive(:invoke).once.with(*args)
  end
end
