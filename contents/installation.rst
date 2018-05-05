*************************
Installation and Updates
*************************

Installation
=======================
Swarm is part of the Ethereum stack, the reference implementation is currently at POC (proof of concept) version 0.2.

The source code is found on github: https://github.com/ethereum/go-ethereum/tree/master/

Supported Platforms
=========================

Geth runs on all major platforms (linux, MacOSX, Windows, also raspberry pi, android OS, iOS).

..  note::
  This package has not been tested on platforms other than linux and OSX.

Prerequisites
================

building the swarm daemon :command:`swarm` requires the following packages:

* go: https://golang.org
* git: http://git.org


Grab the relevant prerequisites and build from source.

On linux (ubuntu/debian variants) use ``apt`` to install go and git

.. code-block:: shell

  sudo apt install golang git

while on Mac OSX you'd use :command:`brew`

.. code-block:: shell

    brew install go git

Then you must prepare your go environment setting your GOPATH environment variable.

To do this, follow the instructions for your specific platform at `Setting GOPATH <https://github.com/golang/go/wiki/SettingGOPATH/>`_.

As an example (for Linux) create your go workspace folder.

.. code-block:: shell

  mkdir ~/<your-own-go-workspace>

Edit your ~/.bash_profile to add the following line:

.. code-block:: shell

  export GOPATH=$HOME/<your-own-go-workspace>

Save and exit your editor.

Then, source your ~/.bash_profile.

.. code-block:: shell

  source ~/.bash_profile

Ubuntu
================

The Ubuntu repositories carry an old version of Go.

Ubuntu users can use the 'gophers' PPA to install an up to date version of Go (version 1.7 or later is preferred). See https://launchpad.net/~gophers/+archive/ubuntu/archive for more information. Note that this PPA requires adding /usr/lib/go-1.X/bin to the executable PATH.

Other distros

Download the latest distribution

.. code-block:: shell

  curl -O https://storage.googleapis.com/golang/go1.9.2.linux-amd64.tar.gz 

Unpack it to the /usr/local (might require sudo)

.. code-block:: shell

  tar -C /usr/local -xzf go1.9.2.linux-amd64.tar.gz

Set GOPATH and PATH

For Go to work properly, you need to set the following two environment variables:

Setup a go folder 

.. code-block:: shell

  mkdir -p ~/go; echo "export GOPATH=$HOME/go" >> ~/.bashrc

Update your path 

.. code-block:: shell

  echo "export PATH=$PATH:$HOME/go/bin:/usr/local/go/bin" >> ~/.bashrc

Read the environment variables into current session: 

.. code-block:: shell

  source ~/.bashrc

Installing from source
=======================

Once all prerequisites are met, download and install packages and dependencies for go-ethereum;

.. code-block:: shell

  go get github.com/ethereum/go-ethereum
  cd $GOPATH/src/github.com/ethereum/go-ethereum

This will download the master source code branch.

Finally compile the swarm daemon ``swarm`` and the main go-ethereum client ``geth``.

.. code-block:: shell

  go install -v ./cmd/swarm
  go install -v ./cmd/geth

You can now run :command:`swarm` to start your swarm node.
Let's check `swarm`'s installation

.. code-block:: shell

  $GOPATH/bin/swarm version

Should give you some relevant information back

.. code-block:: shell

  Swarm
  Version: 0.2
  Network Id: 0
  Go Version: go1.9.2
  OS: linux
  GOPATH=/home/user/go
  GOROOT=/usr/local/go

Updating your client
=====================

To update your client simply download the newest source code and recompile.

.. code-block:: shell

  cd $GOPATH/src/github.com/ethereum/go-ethereum
  git checkout master
  git pull
  go install -v ./cmd/geth
  go install -v ./cmd/swarm

