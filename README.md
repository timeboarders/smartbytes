# SmartCloud
Smartcloud is a full-stack deployment framework for Rails optimized for programmer happiness and peaceful administration. It encourages natural simplicity by favoring convention over configuration.

Deploy your Rails apps to your own server with - git push production master

## How it Works

After you run the below commands, you get.
1. Setup of basic best practices of setting up and securing a VPS server.
2. Setup and installation of Docker.
3. Setup and installation of docker based Mysql, Solr, Nginx, Runner.
4. Deployment of your Rails apps to your own server with - git push production master

## Setup a New Machine - Ubuntu 18.04 LTS
1. Getting Started with Linode:
```
https://www.linode.com/docs/getting-started/
```
2. How to Secure Your Server:
```
https://www.linode.com/docs/security/securing-your-server/
```

## Install SmartCloud
1. Install Ruby:
```
$ sudo apt-get install ruby-full
```
2. Add gem executables to PATH (remember to check ruby version in the path):
```
$ echo 'export PATH="$PATH:$HOME/.gem/ruby/2.5.0/bin"' >> ~/.bashrc && source ~/.bashrc
```
3. Install smartcloud for current user:
```
$ gem install smartcloud --user-install
```
4. Initialize smartcloud:
```
$ smartcloud init
```

<!--
## TODO - Setup Machine
1. Getting Started and Securing your Server:
```
$ smartcloud machine install
```
-->

## Install Docker
1. Run docker install command:
```
$ smartcloud docker install
```
2. Add UFW rules for Docker as specified at the end of installation.

## Starting Grids as per Choice
1. Start mysql grid:
```
$ smartcloud grids mysql start
```
2. Start solr grid:
```
$ smartcloud grids solr start
```
3. Start nginx grid:
```
$ smartcloud grids nginx start
```
4. Start runner grid:
```
$ smartcloud grids runner start
```

## TODO - Creating New App
1. Creating a new bare app on the server:
```
$ smartcloud apps create <USERNAME> <APPNAME>
```
