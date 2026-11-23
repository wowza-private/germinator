require "spec_helper"

RSpec.describe Germinator do
  it "loads alongside the bundled actionview" do
    expect(Germinator::VERSION).to match(/\A\d+\.\d+\.\d+\z/)
    expect(Germinator::SEED_PATH).to eq("db/germinate")
  end

  # CI sets RAILS_VERSION per matrix entry so a mis-resolved bundle fails loudly
  # instead of silently testing the wrong Rails.
  it "runs against the expected Rails series", if: ENV["RAILS_VERSION"] do
    expected = ENV["RAILS_VERSION"].sub(/\.x\z/, "")
    expect(ActionView.version.to_s).to start_with("#{expected}.")
  end

  it "declares an actionview dependency satisfied by the loaded version" do
    spec = Gem::Specification.load(File.expand_path("../germinator.gemspec", __dir__))
    dependency = spec.dependencies.find { |d| d.name == "actionview" }

    expect(dependency.requirement).to be_satisfied_by(ActionView.version)
  end

  describe Germinator::SeedFile do
    subject(:seed_file) { described_class.new("/app/db/germinate/20150223231929_add_sample_records.rb") }

    it "parses the version and name out of the file name" do
      expect(seed_file.version).to eq("20150223231929")
      expect(seed_file.name).to eq("add_sample_records")
      expect(seed_file.seed_name).to eq("20150223231929_add_sample_records")
    end
  end

  describe Germinator::SeedConfig do
    it "defaults to running in every environment without stopping on errors" do
      expect(described_class.new.to_hash).to eq(
        stop_on_error: false,
        stop_on_invalid_model: false,
        environments: true,
        valid_models: true
      )
    end
  end
end
