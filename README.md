# SmartCloud

## Setup Machine
1. Getting Started with Linode:
```
https://www.linode.com/docs/getting-started/
```
2. How to Secure Your Server:
```
https://www.linode.com/docs/security/securing-your-server/
```

## Install SmartCloud
1. Install Ruby at the command prompt if you haven't done yet:
```
$ sudo apt-get install ruby-full
```
2. Add gem executables to PATH:
```
$ echo 'export PATH="$PATH:$HOME/.gem/ruby/2.5.0/bin"' >> ~/.bashrc && source ~/.bashrc
```
3. Install smartcloud:
```
$ gem install smartcloud --user-install
```

## Install Docker
1. Run docker install command of smartcloud:
```
$ smartcloud docker install
```
2. Add UFW rules for Docker
