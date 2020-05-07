module SmartMachine
	class Sync < SmartMachine::Base

		def run(**params)
			puts "-----> Syncing SmartMachine"

			only = params[:only] ? Array(params[:only]).flatten : [:push, :pull]

			pull if only.include? :pull
			yield if block_given?
			push if only.include? :push

			puts "-----> Syncing SmartMachine Complete"
		end

		private

		def pull
			print "-----> Sync pulling ... "
			system("rsync -azumv --delete --include={#{pull_files_list}} --exclude=* -e ssh #{SmartMachine.credentials.machine[:username]}@#{SmartMachine.credentials.machine[:address]}:~/.smartmachine/ .")
			puts "done"
		end

		def push
			print "-----> Sync pushing ... "
			system("rsync -azumv --delete --include={#{push_files_list}} --exclude=* -e ssh ./ #{SmartMachine.credentials.machine[:username]}@#{SmartMachine.credentials.machine[:address]}:~/.smartmachine")
			puts "done"
		end

		def pull_files_list
			files = [
				'apps/***',

				'grids',

				'grids/elasticsearch',
				'grids/elasticsearch/data/***',
				'grids/elasticsearch/logs/***',

				'grids/minio',
				'grids/minio/data/***',

				'grids/mysql',
				'grids/mysql/data/***',

				'grids/nginx',
				'grids/nginx/certificates/***',

				'grids/solr',
				'grids/solr/solr/***',
			]
			files.join(',')
		end

		def push_files_list
			files = [
				'apps',
				'apps/containers',
				'apps/containers/.keep',
				'apps/repositories',
				'apps/repositories/.keep',

				'bin/***',

				'config',
				'config/credentials.yml.enc',
				'config/environment.rb',

				'grids',

				'grids/elasticsearch',
				'grids/elasticsearch/data',
				'grids/elasticsearch/data/.keep',
				'grids/elasticsearch/logs',
				'grids/elasticsearch/logs/.keep',

				'grids/minio',
				'grids/minio/data',
				'grids/minio/data/.keep',

				'grids/mysql',
				'grids/mysql/data',
				'grids/mysql/data/.keep',

				'grids/nginx',
				'grids/nginx/certificates',
				'grids/nginx/certificates/.keep',
				'grids/nginx/htpasswd/***',
				'grids/nginx/fastcgi.conf',
				'grids/nginx/nginx.tmpl',

				'grids/prereceiver',
				'grids/prereceiver/pre-receive',

				'grids/redis',
				'grids/redis/data',
				'grids/redis/data/.keep',

				'grids/solr',
				'grids/solr/solr',
				'grids/solr/solr/.keep',

				'tmp/***',
			]
			files.join(',')
		end
	end
end
