# Kutti Interface

The kutti tool interacts with VirtualBox VMs created by this image via the following interface:

## VM Additions
The interface requires VirtualBox VM Additions to be installed in each VM. Kutti uses the `VBoxManage guestcontrol run` command to communicate with the VM.

## User
Kutti uses a user called `kuttiadmin` with a hardcoded password to run commands inside VMs. This user has sudo privileges without the need of a password.

## Scripts
Kutti uses a number of scripts to perform common operations inside VMs. These are all installed in a subdirectory called `kutti-installscripts` under the home directory of the `kuttiadmin` user.

The scripts are listed below:

## set-hostname
This changes the hostname of a VM. It is invoked when a new node is added to a kutti cluster.

