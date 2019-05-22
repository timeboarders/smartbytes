# The main Smartcloud Apps driver
module Smartcloud
	class Apps
		def initialize
		end

		# Creating App!
		#
		# Example:
		#   >> Apps.create
		#   => Creation Complete
		#
		# Arguments:
		#   name => (String)
		def self.create(name)
			puts "-----> Creating App"			
			puts "-----> Creation Complete"
		end

		# Destroying App!
		#
		# Example:
		#   >> Apps.destroy
		#   => Destruction Complete
		#
		# Arguments:
		#   name => (String)
		def self.destroy(name)
		end

		# Running App!
		#
		# Example:
		#   >> Apps.run
		#   => Running Complete
		#
		# Arguments:
		#   name => (String)		
		def self.start(name)
			# 	echo "-----> Launching Application"
			# 	if [ "$(docker ps -a -q -f name=$REPOSITORY_BASENAME)" ]; then
			# 		docker stop "$REPOSITORY_BASENAME" && docker rm "$REPOSITORY_BASENAME"
			# 	fi
			# 	docker create \
			# 		--log-opt mode=non-blocking --log-opt max-buffer-size=4m \
			# 		--name="$REPOSITORY_BASENAME" \
			# 		--env-file="$REPOSITORY_PATH/env" \
			# 		--volume="$APPS_ROOT/containers/$REPOSITORY_BASENAME/$NOW_DATE:/code" \
			# 		--volume="~/.smartcloud/grid-git/buildpacks/rails/gems:/.gems" \
			# 		--network="nginx-network" \
			# 		--expose="5000" \
			# 		--restart="always" \
			# 		smartcloud/buildpacks/rails
			# 	docker network connect solr-network $REPOSITORY_BASENAME
			# 	docker start $REPOSITORY_BASENAME
			# 	docker logs $REPOSITORY_BASENAME --follow
		end
		
		def self.stop(name)
		end
	end
end