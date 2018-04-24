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

On linux (ubuntu/debian variants) use ``apt`` to install git

.. code-block:: none

  sudo apt install git

and install go with

.. code-block:: none

  sudo apt install golang

**However**, at the time of writing the version of golang that is in the repositories for Ubuntu and Debian is too old. (See below_. for instructions on how to get the newer version)

while on Mac OSX you'd use :command:`brew`

.. code-block:: none

    brew install go git

Then you must prepare your go environment as follows

.. code-block:: none

  mkdir ~/go
  export GOPATH="$HOME/go"
  echo 'export GOPATH="$HOME/go"' >> ~/.bashrc


.. _below:

Ubuntu
---------

At the time of writing, the Ubuntu repositories carry an older version of Go. Up to date instruction on how to install the newest version of Go in Ubuntu can always be found `here <https://github.com/golang/go/wiki/Ubuntu>`_.

Ubuntu users can use the 'gophers' PPA to install an up to date version of Go. See https://launchpad.net/~gophers/+archive/ubuntu/archive for more information. Note that this PPA requires adding /usr/lib/go-1.X/bin to the executable PATH.
Thus you would install golang 1.10 with

.. code-block:: none

  sudo add-apt-repository ppa:gophers/archive
  sudo apt-get update
  sudo apt-get install golang-1.10-go

and then add ``/usr/lib/go-1.10/bin`` to your ``PATH`` environment variable.

.. code-block:: none

  export PATH="$PATH:/usr/lib/go-1.10/bin"
  echo 'export PATH="$PATH:/usr/lib/go-1.10/bin"' >> ~/.bashrc

You must also set up a go folder and ``GOPATH``.

Generic linux
---------------

The latest version of golang can be found at https://golang.org/dl/
To install it, download the tar.gz file

.. code-block:: none

  curl -O https://dl.google.com/go/go1.10.1.linux-amd64.tar.gz

Unpack it to the /usr/local

.. code-block:: none

  sudo tar -C /usr/local -xzf go1.10.1.linux-amd64.tar.gz

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

Installing Swarm from source
=============================

Once all prerequisites are met, download the go-ethereum source code

.. code-block:: none

  mkdir -p $GOPATH/src/github.com/ethereum
  cd $GOPATH/src/github.com/ethereum
  git clone https://github.com/ethereum/go-ethereum
  cd go-ethereum
  git checkout master
  go get github.com/ethereum/go-ethereum

and finally compile the swarm daemon ``go-swarm`` and the main go-ethereum client ``geth``.

.. code-block:: none

  go install -v ./cmd/geth
  go install -v ./cmd/go-swarm


You can now run :command:`go-swarm` to start your swarm node.
Let's check if the installation of `go-swarm` was successful:

.. code-block:: none

  go-swarm version

or, if your `PATH` is not set and the `go-swarm` command can not be found, try:

.. code-block:: none

  $GOPATH/bin/go-swarm version

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
=====================

To update your client simply download the newest source code and recompile.

.. code-block:: none

  cd $GOPATH/src/github.com/ethereum/go-ethereum
  git checkout master
  git pull
  go install -v ./cmd/geth
  go install -v ./cmd/go-swarm
