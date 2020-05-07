require "pathname"
require "tmpdir"
require "active_support/message_encryptor"
require "active_support/core_ext/hash/keys"

# The main SmartMachine Credentials driver
module SmartMachine
	class Credentials < SmartMachine::Base

		CIPHER = "aes-256-gcm"

		def initialize
		end

		def create
			write_key
			write credentials_template
		end

		def edit
			content_path = Pathname.new "config/credentials.yml.enc"
			tmp_file = "#{Process.pid}.#{content_path.basename.to_s.chomp('.enc')}"
			tmp_path = Pathname.new File.join(Dir.tmpdir, tmp_file)
			contents = read
			tmp_path.binwrite contents

			system("#{ENV['EDITOR']} #{tmp_path}")

			updated_contents = tmp_path.binread

			if updated_contents != contents
				write(updated_contents)
				puts "File encrypted and saved."
			else
				puts "File contents were not changed."
			end
		ensure
			FileUtils.rm(tmp_path) if tmp_path&.exist?
		end

		def read_key
			read_env_key || read_key_file || handle_missing_key
		end

		def config
			@config ||= deserialize(read).deep_symbolize_keys
		end

		private

		def credentials_template
			<<~YAML
			  machine:
			    name: #{SecureRandom.hex(8)}
			    host: 122.122.122.122
			    port: 22
			    root_password: #{SecureRandom.hex(16)}
			    username: #{SecureRandom.hex(8)}
			    password: #{SecureRandom.hex(16)}

  			  minio:
  			    name: #{SecureRandom.hex(8)}
  			    access_key: #{SecureRandom.hex(8)}
  			    secret_key: #{SecureRandom.hex(16)}
  			    browser: on
  			    worm: off

			  mysql:
			    port: 3306
			    root_password: #{SecureRandom.hex(16)}
			    username: #{SecureRandom.hex(8)}
			    password: #{SecureRandom.hex(16)}
			    database_name: #{SecureRandom.hex(8)}

  			  elasticsearch:
  			    port: 9200
			YAML
		end

		def read
			decrypt IO.binread "config/credentials.yml.enc"
		end

		def write(contents)
			IO.binwrite "config/credentials.yml.enc.tmp", encrypt(contents)
			FileUtils.mv "config/credentials.yml.enc.tmp", "config/credentials.yml.enc"
		end

		def encrypt(contents)
			encryptor.encrypt_and_sign contents
		end

		def decrypt(contents)
			encryptor.decrypt_and_verify contents
		end
		
		def encryptor
			@encryptor ||= ActiveSupport::MessageEncryptor.new([ read_key ].pack("H*"), cipher: CIPHER)
		end

		def create_key
			SecureRandom.hex(ActiveSupport::MessageEncryptor.key_len(CIPHER))
		end

		def write_key
			IO.binwrite "config/master.key.tmp", create_key
			FileUtils.mv "config/master.key.tmp", "config/master.key"
		end

		def read_env_key
			ENV['SMARTMACHINE_MASTER_KEY']
		end

		def read_key_file
			IO.binread("config/master.key").strip if File.file?("config/master.key")
		end

		def handle_missing_key
			raise "Missing SMARTMACHINE_MASTER_KEY. Please add SMARTMACHINE_MASTER_KEY to your environment."
		end

		def deserialize(config)
			YAML.load(config).presence || {}
		end
	end
end