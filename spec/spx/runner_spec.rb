# frozen_string_literal: true

RSpec.describe Spx::Runner do
  let(:runner) { described_class.new(1, token, 3) }
  let(:token) { "token" }

  let(:server) { double }
  let(:client) { double }

  before do
    allow(OSC::Server).to receive(:new).and_return(server)
    allow(server).to receive(:run)

    allow(OSC::Client).to receive(:new).and_return(client)
    allow(client).to receive(:send)
  end

  describe "#test_connection" do
    subject { runner.test_connection }

    context "when connection is successful" do
      before do
        allow(server).to receive(:add_method).and_yield
      end

      it { is_expected.to be true }
    end

    context "when connection fails" do
      before do
        allow(server).to receive(:add_method)
      end

      it { is_expected.to be false }
    end
  end

  describe "#play" do
    subject(:run) { runner.play("code") }

    let(:code) { "code" }

    it do
      run

      message = OSC::Message.new(described_class::MESSAGES[:run_code], token, code)
      expect(client).to have_received(:send).with(message)
    end
  end

  describe "#record" do
    subject(:run) { runner.record(code, output_file) }

    let(:code) { "code" }
    let(:output_file) { "output.wav" }

    before do
      allow(server).to receive(:add_method) do |_, &block|
        Thread.new do
          sleep 0.2
          block.call
        end
      end
    end

    it do
      run

      aggregate_failures do
        start_message = OSC::Message.new(described_class::MESSAGES[:start_recording], token)
        expect(client).to have_received(:send).with(start_message)

        run_message = OSC::Message.new(
          described_class::MESSAGES[:run_code],
          token,
          runner.send(:code_with_callback, code, described_class::MESSAGES[:record_callback])
        )
        expect(client).to have_received(:send).with(run_message)

        stop_message = OSC::Message.new(described_class::MESSAGES[:stop_recording], token)
        expect(client).to have_received(:send).with(stop_message)

        save_message = OSC::Message.new(described_class::MESSAGES[:save_recording], token, output_file)
        expect(client).to have_received(:send).with(save_message)
      end
    end
  end
end
