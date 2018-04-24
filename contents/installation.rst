*************************
Installation and Updates
*************************

Supported Platforms
=========================

Swarm must be run in combination with Geth which runs on Linux, macOSX, Windows, Raspberry Pi, Android and iOS.

..  note::
  This package has not been tested on platforms other than Linux and OSX.


Installing from PPA
=======================
Swarm is part of the Ethereum stack, the reference implementation is currently only available as a proof of concept stage in the `ethereum-unstable` package

.. code-block:: none

  sudo add-apt-repository -y ppa:ethereum/ethereum
  sudo apt-get update
  sudo apt-get install ethereum-unstable

You should now be able to run ``swarm`` and connect to the network.

Building from source
=======================

The source code for Swarm can be found on GitHub: https://github.com/ethereum/go-ethereum/
Updates and fixes are merged into the ``master`` branch.

Prerequisites
================

Building Swarm requires the following prerequisites

* Go - https://golang.org
* Git - https://git-scm.com/

On Linux (Ubuntu/Debian variants)

.. code-block:: none

  sudo apt install golang git

On macOS

.. code-block:: none

    brew install go git

Then prepare your Go environment

.. code-block:: none

  mkdir ~/go
  export GOPATH="$HOME/go"
  echo 'export GOPATH="$HOME/go"' >> ~/.profile



Ubuntu
================

The Ubuntu repositories carry an old version of Go.

Ubuntu users can use the 'gophers' PPA to install an up to date version of Go (version 1.7 or later is preferred). See https://launchpad.net/~gophers/+archive/ubuntu/archive for more information. Note that this PPA requires adding /usr/lib/go-1.X/bin to the executable PATH.

Other distros

Download the latest distribution

.. code-block:: none

  curl -O https://storage.googleapis.com/golang/go1.9.2.linux-amd64.tar.gz 

Unpack it to the /usr/local (might require sudo)

.. code-block:: none

  tar -C /usr/local -xzf go1.9.2.linux-amd64.tar.gz

Set GOPATH and PATH

For Go to work properly, you need to set the following two environment variables:

Setup a go folder 

.. code-block:: none

  mkdir -p ~/go; echo "export GOPATH=$HOME/go" >> ~/.bashrc

Update your path 

.. code-block:: none

  echo "export PATH=$PATH:$HOME/go/bin:/usr/local/go/bin" >> ~/.bashrc

Read the environment variables into current session: 

.. code-block:: none

  source ~/.bashrc

Installing from source
=======================

Once all prerequisites are met, download the go-ethereum source code

.. code-block:: none

  mkdir -p $GOPATH/src/github.com/ethereum
  cd $GOPATH/src/github.com/ethereum
  git clone https://github.com/ethereum/go-ethereum
  cd go-ethereum
  git checkout master
  go get github.com/ethereum/go-ethereum

and compile the ``geth`` client and ``swarm`` daemon.

.. code-block:: none

  go install -v ./cmd/geth
  go install -v ./cmd/swarm

You can now run ``swarm`` to start your swarm node.
Let's check Swarm's installation

.. code-block:: none

  $GOPATH/bin/swarm version

Should give you some relevant information back

.. code-block:: none

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

.. code-block:: none

  cd $GOPATH/src/github.com/ethereum/go-ethereum
  git checkout master
  git pull
  go install -v ./cmd/geth
  go install -v ./cmd/swarm

