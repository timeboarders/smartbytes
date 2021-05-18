# SmartMachine

Git push should deploy.

SmartMachine is a full-stack deployment framework for rails optimized for admin programmer happiness and peaceful administration. It encourages natural simplicity by favoring convention over configuration.

Before you begin, you should install ruby on your system.

Deploy your Rails apps to your own server with - git push production master

### How it Works

After you run the below commands, you get.
1. Setup of basic best practices of setting up and securing a VPS server.
2. Setup and installation of Docker.
3. Setup and installation of docker based Mysql, Solr, Nginx, App Prereceiver.
4. Deployment of your Rails apps to your own server with - git push production master

### Prerequisites

If using SmartMachine on a server, perform the below steps before proceeding.

1. Ensure that you have debian LTS installed on the server.

    $ cat /etc/issue

   here it should say some latest version of debian LTS.

2. Getting Started with Linode:

    https://www.linode.com/docs/getting-started/

3. How to Secure Your Server:

    https://www.linode.com/docs/security/securing-your-server/

## Getting Started

1. Install SmartMachine at the command prompt:

    $ gem install smartmachine

2. At the command prompt create a new SmartMachine move into it:

    $ smartmachine new yourmachinename
    $ cd yourmachinename

   here "yourmachinename" is the machine name you can choose

3. Install docker from the command prompt, and add UFW rules for Docker if specified at the end of installation. For Mac OSX ensure that 
'Use gRPC FUSE for file sharing' is turned off in experimental features of docker preferences:

    $ smartmachine docker install

4. Install engine from the command prompt:

    $ smartmachine engine install

5. Install buildpackers from the command prompt:

    $ smartmachine buildpackers install

### Choosing Grids of your Choice

Feel free to choose only the grids you need. You can start or stop a grid at anytime using <b>up</b> or <b>down</b> commands respectively.

#### 1. Nginx Grid
Lets you run a nginx web server fully equipped with https encryption using letsencrypt.
    
    $ smartmachine grids nginx up
    $ smartmachine grids nginx down

#### 2. Prereceiver Grid
Lets you push rails apps to your server without any additional configuration or downtime using <b>git push production master</b>.

    $ smartmachine grids prereceiver install
    $ smartmachine grids prereceiver up
    $ smartmachine grids prereceiver down
    $ smartmachine grids prereceiver uninstall

#### 3. Mysql Grid
Lets you run a mysql server instance with as many databases as you need.

    $ smartmachine grids mysql up
    $ smartmachine grids mysql down

#### 4. Minio Grid
Lets you run minio server instance with file storage persistance.

    $ smartmachine grids minio up
    $ smartmachine grids minio down

#### 5. Elasticsearch Grid
Lets you run elasticsearch server instance with data persistance.

    $ smartmachine grids elasticsearch install
    $ smartmachine grids elasticsearch up
    $ smartmachine grids elasticsearch down
    $ smartmachine grids elasticsearch uninstall

#### 4. Redis Grid - Coming Soon
Lets you run redis server instance for cache storage and job queueing.

    $ smartmachine grids redis up
    $ smartmachine grids redis down

#### 6. Scheduler Grid
Lets you setup scheduling services like database backups, etc.

    $ smartmachine grids scheduler install
    $ smartmachine grids scheduler up
    $ smartmachine grids scheduler down
    $ smartmachine grids scheduler uninstall

### Creating Apps on Server

1. Creating a new bare app on the server:

    $ smartmachine apps create <USERNAME> <APPNAME>

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/timeboardcode/smartmachine. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/timeboardcode/smartmachine/blob/master/CODE_OF_CONDUCT.md).

## License

SmartMachine is released under the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the SmartMachine project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/timeboardcode/smartmachine/blob/master/CODE_OF_CONDUCT.md).
