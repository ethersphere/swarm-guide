
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


CLI Usage
-----------

The Swarm CLI now integrates commands to make FUSE usage easier and streamlined.

.. note:: When using FUSE from the CLI, we assume you are running a local Swarm node on your machine. The FUSE commands attach to the running node through `bzzd.ipc`

Mount
^^^^^^^^

To mount a Swarm manifest, first upload a content to Swarm using the `swarm up` command.
Once you get the returned manifest hash, use it to mount the manifest to a mount point:

.. code-block:: none

	swarm fs mount --ipcpath <path-to-bzzd.ipc> <manifest-hash> <mount-point>

Your running Swarm node terminal output should show something similar to the following in case the command returned successfuly:

.. code-block:: none

	Attempting to mount /path/to/mount/point  
	Serving 6e4642148d0a1ea60e36931513f3ed6daf3deb5e499dcf256fa629fbc22cf247 at /path/to/mount/point
	Now serving swarm FUSE FS                manifest=6e4642148d0a1ea60e36931513f3ed6daf3deb5e499dcf256fa629fbc22cf247 mountpoint=/path/to/mount/point


Unmount
^^^^^^^^
To unmount a swarmfs mount, either use the List Mounts command below, or use a known mount point:

.. code-block:: none

	swarm fs unmount --ipcpath <path-to-bzzd.ipc> <mount-point>

Your Swarm node should now show the following output:

.. code-block:: none

	UnMounting /path/to/mount/point succeeded 


List Mounts
^^^^^^^^^^^^^^^^^^

To see all existing swarmfs mount points, use the List Mounts command:

.. code-block:: none

	swarm fs list --ipcpath <path-to-bzzd.ipc>

Example Output:

.. code-block:: none

	Found 1 swarmfs mount(s):
	0:
		Mount point: /path/to/mount/point
		Latest Manifest: 6e4642148d0a1ea60e36931513f3ed6daf3deb5e499dcf256fa629fbc22cf247
		Start Manifest: 6e4642148d0a1ea60e36931513f3ed6daf3deb5e499dcf256fa629fbc22cf247

