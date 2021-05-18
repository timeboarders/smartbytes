# frozen_string_literal: true

version = File.read(File.expand_path("../../SMARTBYTES_VERSION", __dir__)).strip

module SmartOS
  VERSION = version.to_s
end
