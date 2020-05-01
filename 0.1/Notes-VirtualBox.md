# Kutti VM version 0.1 - VirtualBox

## Specifications
Debian version 9.9 with:
  - Stock netinst setup 
  - SSH server only
  - Swap off
  - vim, curl
  - nano
  - docker 18.09.3-ce
  - kubelet, kubeadm, kubectl

### Note
Debian 10.0 currently not used, as there seem to be some incompatibilities.Refer [Support for Debian Buster](https://github.com/kubernetes/release/issues/728) and [kube-proxy currently incompatible with `iptables >= 1.8`](https://github.com/kubernetes/kubernetes/issues/71305).

## Instructions

## For debian base 9.9 
### Base Setup
1. Download **debian-9.9.0-amd64-netinst.iso** (Debian "stable" release) from https://www.debian.org/CD/http-ftp/. 
2. Create a virtual machine with at least 2 cores, 2GB RAM, 8MB video memory and 100GB hard disk. Mount the iso from step 1 on the CDROM device. Boot. From the installer, choose "Install".
3. In the "Set up users and passwords" step, provide a password for the root user, and create a user with "Full Name": User 1 and username: user1.
4. In the "Partition Disks" step, choose "Manual". Select the hard disk. Create a new, empty partition table on it. Select the "Free Space" on the hard disk. Create a new partition, using the maximum space available, type Primary. Set the Bootable flag to on. Finish partitioning and write the changes to disk. Confirm that you do not want swap space, and continue the installation.
5. In the "Software Selection" step, choose _only_ "SSH server".
6. Install GRUB to the hard disk, and complete the installation. Reboot.
7. **Note:** To prevent history from being recorded during setup, run `unset HISTFILE` on every login.
8. Log on as root. Edit **/etc/default/grub**, and ~~add 'swapaccount=1' to the variable **GRUB_CMDLINE_LINUX**~~ set the variable **GRUB_TIMEOUT** to 0. Run `update-grub`. Reboot.
9. Log on as root. Run `apt update && apt install sudo`.
10. Run `adduser user1 sudo`. Log on as user1. Run `sudo ls` to deal with first-time sudo message.

### For VirtualBox VM Additions
11. Run `apt install build-essential linux-headers-$(uname -r) dkms`
12. Insert the VM Additions CD. Run `mount /media/cdrom`.
13. Run `sh /media/cdrom/VBoxLinuxAdditions.run`. Reboot.
14. Log in as root. Run `apt remove dkms linux-headers-$(uname -r) build-essential && apt autoremove`.

### For compacting the VM
15. Run `dd if=/dev/zero of=zerofillfile bs=1G`
16. Run `rm zerofillfile`. 
17. Run `poweroff`.
18. On the host, run `VBoxManage modifyhd --compact "[drive]:\[path_to_image_file]\[name_of_image_file].vdi"`.

### Docker and Kubernetes
19. Login as root. Edit **/etc/ssh/sshd_config**. Add the line `PermitRootLogin yes`. Run `systemctl restart ssh`. Copy the attached **root/rw-installscripts** directory to **/root/rw-installscripts**. Go to that directory and run `chmod +x *.sh`.
20. Run `KUBE_VERSION=<version> ./base-setup.sh` to install kubernetes and supported docker. Currently suppported versions are:
    - 1.16.0-00
    - 1.15.4-00
    - 1.14.7-00
21. Verify that docker is up by running `docker system info`. Verify that kubeadm is installed by running `kubeadm`. Verify the kubectl autocomplete works.

### Kutti admin files
22. Run `adduser --gecos "Kutti Admin" kuttiadmin`. For now, set the password to **Pass@word1**.
23. Run `adduser kuttiadmin sudo && adduser kuttiadmin docker`.
24. Run `visudo -f /etc/sudoers.d/kutti`. In the editor, paste `%kuttiadmin ALL=(ALL:ALL) NOPASSWD:ALL`. Press the tab key, don't type {tab}. Save and close the file.
25. Copy the attached **kuttiadmin/rw-installscripts** directory to **/home/kuttiadmin/rw-installscripts** as kuttiadmin. Go to that directory and run `chmod +x *.sh`.

