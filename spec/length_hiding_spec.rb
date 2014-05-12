require "spec_helper"
require "breach_mitigation/length_hiding"
require 'rack/body_proxy'
require 'rack/response'

describe BreachMitigation::LengthHiding do
  let(:length_hiding) { BreachMitigation::LengthHiding.new(double()) }

  describe "#random_html_comment" do
    it "should have different lengths on different runs" do
      lengths = []
      10.times do
        random_comment = length_hiding.send(:random_html_comment)
        lengths << random_comment.size
      end
      lengths.uniq.size.should > 1
    end
  end

  describe '#call' do
    let(:request_headers) { { 'Content-Type' => 'text/html' } }
    let(:env) { {
      'rack.url_scheme' => 'https',
      'SERVER_PORT' => '443'
    } }

    let(:response_from_app) { Rack::Response.new('Hello Universe') }
    let(:payload) { [ 200, request_headers, response_from_app ] }
    let(:app) { double('app', :call => payload) }

    subject do
      described_class.new(app).tap do |middleware|
        middleware.stub :random_html_comment => '<!-- random html comment -->'
      end
    end

    it 'injects the random-length HTML comment into the page body' do
      status, headers, response = subject.call(env)
      response.body.join.should == 'Hello Universe<!-- random html comment -->'
    end

    it 'does not inject the comment into a non-HTML response' do
      request_headers['Content-Type'] = 'text/javascript'
      status, headers, response = subject.call(env)
      response.body.join.should == 'Hello Universe'
    end

    it 'does not inject the comment on HTTP connections' do
      env['rack.url_scheme'] = 'http'
      status, headers, response = subject.call(env)
      response.body.join.should == 'Hello Universe'
    end
  end
end
