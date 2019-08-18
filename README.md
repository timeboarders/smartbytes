# SmartCloud

## Install SmartCloud
1. Install Ruby at the command prompt if you haven't done yet:
```
$ sudo apt-get install ruby-full
```
2. Add gem executables to PATH (remember to check ruby version in the path):
```
$ echo 'export PATH="$PATH:$HOME/.gem/ruby/2.5.0/bin"' >> ~/.bashrc && source ~/.bashrc
```
3. Install smartcloud:
```
$ gem install smartcloud --user-install
```
4. Initialize smartcloud:
```
$ smartcloud init
```

## Setup Machine
1. Getting Started and Securing your Server:
```
$ smartcloud machine install
```

## Install Docker
1. Run docker install command:
```
$ smartcloud docker install
```
2. Add UFW rules for Docker

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
4. Start gitreceive grid:
```
$ smartcloud grids gitreceive start
```

## TODO - Creating New App
1. Creating a new app on the server:
```
$ smartcloud apps create <USERNAME> <APPNAME>
```
