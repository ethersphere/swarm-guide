
FUSE
======================


Another way of interacting with Swarm is by mounting it as a local filesystem using `FUSE <https://en.wikipedia.org/wiki/Filesystem_in_Userspace>`_ (Filesystem in Userspace). There are three IPC API's which help in doing this.

.. note:: FUSE needs to be installed on your Operating System for these commands to work. Windows is not supported by FUSE, so these command will work only in Linux, Mac OS and FreeBSD. For installation instruction for your OS, see "Installing FUSE" section below.


Installing FUSE
----------------

1. Linux (Ubuntu)

.. code-block:: none

	sudo apt-get install fuse
	sudo modprobe fuse
	sudo chown <username>:<groupname> /etc/fuse.conf
	sudo chown <username>:<groupname> /dev/fuse

2. Mac OS

   Either install the latest package from https://osxfuse.github.io/ or use brew as below

.. code-block:: none

	brew update
	brew install caskroom/cask/brew-cask
	brew cask install osxfuse
