Guest Agent Installation
========================

This installation must be done in your guest VM if you want to keep the correct time after hibernate.

Ubuntu and Debian
-----------------

::
	$ sudo apt install qemu-guest-agent

Fedora
------

::
	$ dnf install qemu-guest-agent

RedHat and CentOS
-----------------

::
	$ yum install qemu-guest-agent

Windows
-------

Follow the instructions provided by `Linux KVM <https://www.linux-kvm.org/page/WindowsGuestDrivers/Download_Drivers>`_
