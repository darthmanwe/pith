require 'spec_helper'
require 'pith/server'
require 'rack/mock'

describe Pith::Server::OutputFinder do

  let(:output_path) { "dir/index.html" }
  let(:output) { double(:path => Pathname(output_path), :build => true) }

  let(:project) do
    double(:outputs => [output])
  end

  let(:app) do
    lambda do |env|
      [
        200,
        { "Location" => env["PATH_INFO"] },
        ["OKAY"]
      ]
    end
  end

  let(:middleware) do
    Pith::Server::OutputFinder.new(app, project)
  end

  let(:request_uri) { "/foo" }
  let(:request_env) do
    Rack::MockRequest.env_for(request_uri)
  end

  let(:result) do
    middleware.call(request_env)
  end

  let(:result_status) do
    result[0]
  end

  let(:result_headers) do
    result[1]
  end

  let(:result_path) do
    result_headers["Location"]
  end

  context "request for a non-existant file" do

    let(:request_uri) { "/bogus.html" }

    it "does not build the output" do
      expect(output).not_to receive(:build)
      result_path
    end

    it "passes on the env unchanged" do
      expect(result_path).to eq("/bogus.html")
    end

  end

  def self.can_request_output(description, uri)

    context "request for output #{description}" do

      let(:request_uri) { uri }

      it "builds the output" do
        expect(output).to receive(:build)
        result_path
      end

      it "passes on request" do
        expect(result_path).to eq("/dir/index.html")
      end

    end

  end

  can_request_output "directly", "/dir/index.html"

  can_request_output "without .html", "/dir/index"

  can_request_output "directory with slash", "/dir/"

  context "request for directory without slash" do

    let(:request_uri) { "/dir" }

    it "redirects" do
      expect(result_status).to eq(302)
      expect(result_headers["Location"]).to eq("/dir/")
    end

  end

end
