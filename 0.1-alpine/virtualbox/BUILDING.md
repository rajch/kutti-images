# Kutti VM version 0.1-alpine - VirtualBox

## Instructions

### Base Setup
1. Download **alpine-virt-3.12.0-x86_64.iso** (Alpine "virtual" image) from https://alpinelinux.org/. 
2. Create a virtual machine with at least 2 cores, 2GB RAM, and 100GB hard disk. Mount the iso from step 1 on the CDROM device. 
3. Boot. Login as root, no password, and issue the `setup-alpine` command.
4. For keyboard layouts, choose **us** and for variant, choose **us**.
5. For hostname, specify **kutti**.
6. Initialize the first available network interface with DHCP and no manual network configuration.
7. When asked for preferred repository mirror, choose 1. Do NOT choose "fastest".
8. When the setup is over, issue the `poweroff` command. Go to VM settings and remove the ISO file from the CDROM device. Start the VM. Login as root.
9. Edit **/etc/update-extlinux.conf**, and add set the variable **timeout** to 1.
10. Run `update-extlinux`. Reboot the VM with the `reboot` command.
11. Login as root. Run `swapoff -a`. Edit **/etc/fstab**, and comment out the line containing "swap".
12. Edit **/etc/apk/repositories**. Comment out all the lines containing **v3.12** repository and uncomment the lines containing **edge/main**, **edge/community**,  and **edge/testing**.
13. Run `apk upgrade --update-cache --available`.
14. Run `sync && reboot`. Log in as root.
15. Run `apk add sudo`
16. Use `visudo` to allow sudo access to "sudo" group.
17. Run `addgroup sudo` to add the "sudo" group.
18. Run `apk add vim curl bash bash-completion`.
19. Run `adduser -g "User 1" -s /bin/bash user1`.
20. Run `adduser -g "Kutti Admin" -s /bin/bash kuttiadmin`. For now, set the password to **Pass@word1**.
21. Run `adduser user1 sudo`.
22. Run `adduser kuttiadmin sudo` and `adduser kuttiadmin root`.
23. Run `visudo -f /etc/sudoers.d/kutti`. In the editor, paste `%kuttiadmin ALL=(ALL:ALL) NOPASSWD:ALL`. Save and close the file. Log out.
24. Log on as user1. Run `sudo ls` to deal with first-time sudo message. Verify that it asks for a password. Log out.
25. Log on as kuttiadmin. Run `sudo ls`. Verify that it does not ask for a password. Log out.

### For VirtualBox VM Additions
26. Log on as root. Run `apk add virtualbox-guest-modules-virt virtualbox-guest-additions`. Verify the presence of **/usr/sbin/VBoxService** and **/etc/init.d/virtualbox-guest-additions**.
27. Run `service virtualbox-guest-additions start`. Verify that it has started by running `ps aux | grep VBoxService`.
28. If the previous two steps succeeded, run `rc-update add virtualbox-guest-additions`. Reboot.

### Docker 
29. Logon as root. 
30. Run `apk add docker`.
31. Run `service docker start`. 
32. If the last two steps work, run `rc-update add docker` to ensure docker runs at system startup. Also run `adduser user1 docker` and `adduser kuttiadmin docker`.

### Kubernetes
33. Run `apk add kubelet`. This will also install a package called cni-plugins in **/usr/libexec/cni**.
34. Run `rc-update add kubelet`.
35. Run `apk add kubeadm`.
36. Run `apk add kubectl`.

### Copy Scripts
37. Forward the SSH port for the installation VM. Start the VM. Copy the attached **kuttiadmin/kutti-installscripts** directory  to **/home/kuttiadmin/kutti-installscripts** in the VM using scp. The files should have UNIX line endings after the copy. Verify that, and rectify by running `sed "s/\r$//" *.sh` if needed.
38. Use SSH to log on to the installation VM as kuttiadmin. Go to the **kutti-installscripts** directory and run `chmod +x *.sh`.

### motd
39. Edit the file **/etc/motd**. Replace its contents with: `Welcome to kutti.`

### Icon
40. Shut down the VM. On the host, run `VBoxManage modifyvm <name of vm> --iconfile <path to kutti.png>`.

### Compact and export
41. Start the VM. Log on as root. Run `dd if=/dev/zero of=zerofillfile bs=1G`
42. Run `rm zerofillfile`. 
43. Run `poweroff`.
44. On the host, run `VBoxManage modifyhd --compact "[drive]:\[path_to_image_file]\[name_of_image_file].vdi"`.
45. Export to an ova file.
