# frozen_string_literal: true

RSpec.describe Spx::LogParser do
  describe "#parse" do
    subject { described_class.new(log_file_path).parse }

    let(:log_file_path) { "spec/fixtures/spider.log" }

    it { is_expected.to eq({ port: 31_325, token: 1_016_990_984 }) }
  end
end
