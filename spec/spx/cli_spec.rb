# frozen_string_literal: true

RSpec.describe Spx::CLI do
  let(:cli) { described_class.new([], { sonic_pi_log: "", output: "" }) }
  let(:output) { StringIO.new }
  let(:runner) { double }
  let(:log_parser) { double }

  before do
    allow(cli).to receive(:say) { |str| output.write(str) }

    allow(Spx::Runner).to receive(:new).and_return(runner)
    allow(runner).to receive(:test_connection).and_return(connected)

    allow(Spx::LogParser).to receive(:new).and_return(log_parser)
    allow(log_parser).to receive(:parse).and_return({})
  end

  describe "#test_connection" do
    subject do
      cli.test_connection
      output.string
    end

    context "when connection is successful" do
      let(:connected) { true }

      it { is_expected.to eq("OK") }
    end

    context "when connection fails" do
      let(:connected) { false }

      it { is_expected.to eq("NG") }
    end
  end

  describe "#play" do
    subject(:play) { cli.play(input) }

    let(:input) { "file.rb" }

    context "when connection is successful" do
      let(:connected) { true }

      before do
        allow(runner).to receive(:play)
        allow(File).to receive(:read).with(input).and_return(input)
      end

      it do
        play
        expect(runner).to have_received(:play).with(input)
      end
    end

    context "when connection fails" do
      let(:connected) { false }

      it do
        play
        expect(output.string).to eq("Cannot connect to Sonic Pi")
      end
    end
  end

  describe "#record" do
    subject(:record) { cli.record(input) }

    let(:input) { "file.rb" }

    context "when connection is successful" do
      let(:connected) { true }

      before do
        allow(runner).to receive(:record)
        allow(File).to receive(:read).with(input).and_return(input)
      end

      it do
        record
        expect(runner).to have_received(:record).with(input, File.expand_path("."))
      end
    end

    context "when connection fails" do
      let(:connected) { false }

      it do
        record
        expect(output.string).to eq("Cannot connect to Sonic Pi")
      end
    end
  end

  describe "#version" do
    subject do
      cli.version
      output.string
    end

    let(:connected) { false }

    it { is_expected.to eq(Spx::VERSION.to_s) }
  end
end
