require 'spec_helper'
require 'breach_mitigation/core_ext/base64'

describe Base64 do
  # Tests adapted from https://bugs.ruby-lang.org/projects/ruby-18/repository/revisions/26337/entry/test/base64/test_base64.rb

  describe '#strict_encode64' do
    it 'does not add linebreaks, as per RFC 4648' do
      Base64.strict_encode64('X' * 100).should_not include("\n")
    end

    it 'properly encodes given input' do
      Base64.strict_encode64('Send reinforcements').should ==
        'U2VuZCByZWluZm9yY2VtZW50cw=='

      Base64.strict_encode64("Now is the time for all good coders\nto learn Ruby").should ==
        'Tm93IGlzIHRoZSB0aW1lIGZvciBhbGwgZ29vZCBjb2RlcnMKdG8gbGVhcm4gUnVieQ=='

      Base64.strict_encode64("This is line one\nThis is line two\nThis is line three\nAnd so on...\n").should ==
        'VGhpcyBpcyBsaW5lIG9uZQpUaGlzIGlzIGxpbmUgdHdvClRoaXMgaXMgbGluZSB0aHJlZQpBbmQgc28gb24uLi4K'
    end

    it 'properly encodes low and high ASCII chars' do
      Base64.strict_encode64("").should == ""
      Base64.strict_encode64("\0").should == "AA=="
      Base64.strict_encode64("\0\0").should == "AAA="
      Base64.strict_encode64("\0\0\0").should == "AAAA"
      Base64.strict_encode64("\377").should == "/w=="
      Base64.strict_encode64("\377\377").should == "//8="
      Base64.strict_encode64("\377\377\377").should == "////"
      Base64.strict_encode64("\xff\xef").should == "/+8="
    end
  end

  describe '#strict_decode64' do
    it 'properly decodes given input' do
      Base64.strict_decode64('U2VuZCByZWluZm9yY2VtZW50cw==').should ==
        'Send reinforcements'

      Base64.strict_decode64('Tm93IGlzIHRoZSB0aW1lIGZvciBhbGwgZ29vZCBjb2RlcnMKdG8gbGVhcm4gUnVieQ==').should ==
        "Now is the time for all good coders\nto learn Ruby"

      Base64.strict_decode64('VGhpcyBpcyBsaW5lIG9uZQpUaGlzIGlzIGxpbmUgdHdvClRoaXMgaXMgbGluZSB0aHJlZQpBbmQgc28gb24uLi4K').should ==
        "This is line one\nThis is line two\nThis is line three\nAnd so on...\n"
    end

    it 'properly decodes to low and high ASCII chars' do
      Base64.strict_decode64("").should == ""
      Base64.strict_decode64("AA==").should == "\0"
      Base64.strict_decode64("AAA=").should == "\0\0"
      Base64.strict_decode64("AAAA").should == "\0\0\0"
      Base64.strict_decode64("/w==").should == "\377"
      Base64.strict_decode64("//8=").should == "\377\377"
      Base64.strict_decode64("////").should == "\377\377\377"
      Base64.strict_decode64("/+8=").should == "\xff\xef"
    end

    it 'raises an ArgumentError on malformed input' do
      expect { Base64.strict_decode64("^") }.to raise_error(ArgumentError)
      expect { Base64.strict_decode64("A") }.to raise_error(ArgumentError)
      expect { Base64.strict_decode64("A^") }.to raise_error(ArgumentError)
      expect { Base64.strict_decode64("AA") }.to raise_error(ArgumentError)
      expect { Base64.strict_decode64("AA=") }.to raise_error(ArgumentError)
      expect { Base64.strict_decode64("AA===") }.to raise_error(ArgumentError)
      expect { Base64.strict_decode64("AA=x") }.to raise_error(ArgumentError)
      expect { Base64.strict_decode64("AAA") }.to raise_error(ArgumentError)
      expect { Base64.strict_decode64("AAA^") }.to raise_error(ArgumentError)
      expect { Base64.strict_decode64("AB==") }.to raise_error(ArgumentError)
      expect { Base64.strict_decode64("AAB=") }.to raise_error(ArgumentError)
    end
  end

end
