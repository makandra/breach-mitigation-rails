require 'base64'

# Backport strict base64 encoding/decoding methods.
#
# As found in the MRI repository:
# https://bugs.ruby-lang.org/projects/ruby-18/repository/revisions/26337/diff/lib/base64.rb

unless defined?(Base64.strict_encode64)
  # Returns the Base64-encoded version of +bin+.
  # This method complies with RFC 4648.
  # No line feeds are added.
  def Base64.strict_encode64(bin)
    [bin].pack((len = bin.bytesize) > 45 ? "m#{len+2}" : "m").chomp
  end
end

unless defined?(Base64.strict_decode64)
  # Returns the Base64-decoded version of +str+.
  # This method complies with RFC 4648.
  # ArgumentError is raised if +str+ is incorrectly padded or contains
  # non-alphabet characters.  Note that CR or LF are also rejected.
  def Base64.strict_decode64(str)
    return str.unpack("m").first if str.bytesize % 4 == 0 &&
      str.match(%r{\A[A-Za-z0-9+/]*([A-Za-z0-9+/]{2}==|[A-Za-z0-9+/]{3}=)?\z}) &&
      (!$1 || $1 == $1.unpack('m').pack('m').chomp)
    raise ArgumentError, 'invalid base64'
  end
end
