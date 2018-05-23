*************************
Installation and Updates
*************************

Swarm is part of the Ethereum stack, the reference implementation is currently at POC3 (proof of concept 3), or version 0.3.


Swarm runs on all major platforms (linux, MacOSX, Windows, also raspberry pi, android OS, iOS).

..  note::
  The swarm package has not been tested on platforms other than linux and OSX.

Installing Swarm binaries
=========================

THIS SECTION IS MISSING


Installing Swarm from source
=============================

The swarm source code can be found on github:

https://github.com/ethersphere/go-ethereum/tree/swarm-network-rewrite/

Prerequisites
-------------

building the Swarm daemon :command:`swarm` requires the following packages:

* go: https://golang.org
* git: http://git.org


Grab the relevant prerequisites and build from source.

Ubuntu / Debian linux
^^^^^^^^^^^^^^^^^^^^^

.. code-block:: none

  sudo apt install git
  sudo apt install golang

Archlinux
^^^^^^^^^

.. code-block:: none

  pacman -S git go

Generic linux
^^^^^^^^^^^^^

The latest version of golang can be found at https://golang.org/dl/

To install it, download the tar.gz file

.. code-block:: none

  curl -O https://dl.google.com/go/go1.10.1.linux-amd64.tar.gz

Unpack it to the /usr/local

.. code-block:: none

  sudo tar -C /usr/local -xzf go1.10.1.linux-amd64.tar.gz

Mac OSX
^^^^^^^

.. code-block:: none

    brew install go git

Configuration
-------------

You should then prepare your go environment, for example:

.. code-block:: none

  mkdir $HOME/go
  export GOPATH=$HOME/go
  echo 'export GOPATH=$HOME/go' >> ~/.bashrc
  export PATH=$PATH:$GOPATH/bin
  echo 'export PATH=$PATH:$GOPATH/bin' >> ~/.bashrc
  source ~/.bashrc

Compiling and installing
-------------------------

Once all prerequisites are met, download the go-ethereum source code

.. code-block:: none

  mkdir -p $GOPATH/src/github.com/ethereum
  cd $GOPATH/src/github.com/ethereum
  git clone https://github.com/ethersphere/go-ethereum
  cd go-ethereum
  git checkout swarm-network-rewrite
  go get github.com/ethereum/go-ethereum

and finally compile the swarm daemon ``swarm`` and the main go-ethereum client ``geth``.

.. code-block:: none

  go install -v ./cmd/geth
  go install -v ./cmd/swarm


You can now run :command:`swarm` to start your Swarm node.
Let's check if the installation of `swarm` was successful:

.. code-block:: none

  swarm version

or, if your `PATH` is not set and the `swarm` command can not be found, try:

.. code-block:: none

  $GOPATH/bin/swarm version

This should return some relevant information. For example:

.. code-block:: none

  Swarm
  Version: 0.3
  Network Id: 0
  Go Version: go1.10.1
  OS: linux
  GOPATH=/home/user/go
  GOROOT=/usr/local/go

Updating your client
---------------------

To update your client simply download the newest source code and recompile.

.. code-block:: none

  cd $GOPATH/src/github.com/ethereum/go-ethereum
  git checkout master
  git pull
  go install -v ./cmd/geth
  go install -v ./cmd/swarm
