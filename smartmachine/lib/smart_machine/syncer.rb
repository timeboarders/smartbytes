module SmartMachine
	class Syncer < SmartMachine::Base

    def sync(**params)
      if SmartMachine.config.machine_mode == :server
        puts "-----> Syncing SmartMachine"

        only = params[:only] ? Array(params[:only]).flatten : [:push, :pull]

        pull if only.include? :pull
        push if only.include? :push

        puts "-----> Syncing SmartMachine Complete"
      else
        puts "There is no need to sync when using smartmachine for a local machine."
      end
    end

		private

		def pull
			print "-----> Syncer pulling ... "
			system("rsync -azumv -e 'ssh -p #{SmartMachine.credentials.machine[:port]}' --delete --include={#{pull_files_list}} --exclude=* #{SmartMachine.credentials.machine[:username]}@#{SmartMachine.credentials.machine[:address]}:~/smartmachine/ .")
			puts "done"
		end

		def push
			print "-----> Syncer pushing ... "
			system("rsync -azumv -e 'ssh -p #{SmartMachine.credentials.machine[:port]}' --delete --include={#{push_files_list}} --exclude=* ./ #{SmartMachine.credentials.machine[:username]}@#{SmartMachine.credentials.machine[:address]}:~/smartmachine")
			puts "done"
		end

		def pull_files_list
			files = [
				'apps/***',

				'bin/***',

				'grids',

				'grids/elasticsearch',
				'grids/elasticsearch/data/***',
				'grids/elasticsearch/logs/***',

				'grids/minio',
				'grids/minio/data/***',

				'grids/mysql',
				'grids/mysql/backups/***',
				'grids/mysql/data/***',

				'grids/nginx',
				'grids/nginx/certificates/***',

				'grids/scheduler',
				'grids/scheduler/crontabs/***',

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

				'config',
				'config/mysql',
				'config/mysql/schedule.rb',
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
				'grids/mysql/backups',
				'grids/mysql/backups/.keep',
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

				'grids/scheduler',
				'grids/scheduler/crontabs',
				'grids/scheduler/crontabs/.keep',

				'grids/solr',
				'grids/solr/solr',
				'grids/solr/solr/.keep',

				'tmp/***',
			]
			files.join(',')
		end
	end
end
