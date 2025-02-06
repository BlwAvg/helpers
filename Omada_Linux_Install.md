Omada was a pain to install. This is what I did to get it working.

## Networking

To rename interfaces to something more straightforward (e.g., eth0, eth1, etc.) and enable a VLAN interface.

---

### Configure Grub

Make sure grub has the `net.ifnames=0 biosdevname=0` option:

1. Edit the grub config:
   
       sudo nano /etc/default/grub

   Update or add the following lines:

       GRUB_DEFAULT=0
       GRUB_TIMEOUT=5
       GRUB_DISTRIBUTOR=`lsb_release -i -s 2> /dev/null || echo Debian`
       GRUB_CMDLINE_LINUX_DEFAULT="quiet"
       GRUB_CMDLINE_LINUX="net.ifnames=0 biosdevname=0"

2. Update grub:

       sudo update-grub

3. Reboot (You can wait to reboot until after making the interface changes below):

       sudo reboot

---

### Networking Changes

1. Install VLAN support:

       sudo apt install vlan

2. Load the 8021q module:

       sudo modprobe 8021q

3. Edit the networking interface:

       sudo nano /etc/network/interfaces

   Example contents:
   
       # This file describes the network interfaces available on your system
       # and how to activate them. For more information, see interfaces(5).

       source /etc/network/interfaces.d/*

       # The loopback network interface
       auto lo
       iface lo inet loopback

       # untagged interface
       allow-hotplug eth0

       # The primary network interface
       auto vlan70
       iface vlan70 inet dhcp
       vlan-raw-device eth0

---

## Omada Install

Refer to [this guide](https://www.tp-link.com/us/support/faq/3272/).  
Using OpenJDK11 installation.

---

### Repos and Software

This section gets the repositories and software required:

    wget -qO - https://www.mongodb.org/static/pgp/server-4.4.asc | sudo apt-key add -
    sudo touch /etc/apt/sources.list.d/mongodb-org-4.4.list
    echo "deb [ arch=amd64 ] https://repo.mongodb.org/apt/debian/ buster/mongodb-org/4.4 main" | sudo tee /etc/apt/sources.list.d/mongodb-org-4.4.list
    sudo apt update
    sudo apt install openjdk-11-jre-headless curl mongodb-org autoconf make gcc openjdk-11-jdk-headless

---

### JSVS Compile

Compile the correct `jsvc` version. (Get the current jsvc package from [Apache Commons Daemon](https://dlcdn.apache.org/commons/daemon/source/)):

    sudo apt remove jsvc
    cd /opt
    wget https://dlcdn.apache.org/commons/daemon/source/commons-daemon-X.X.X-src.tar.gz
    tar -zxvf commons-daemon-X.X.X-src.tar.gz
    cd commons-daemon-X.X.X-src/src/native/unix
    sudo ./configure --with-java=/usr/lib/jvm/java-11-openjdk-amd64
    sudo make
    sudo ln –s /opt/commons-daemon-1.3.0-src/src/native/unix/jsvc /usr/bin/
    rm -rf /opt/commons-daemon-X.X.X-src.tar.gz

---

### Omada Install

To install the Omada software ([download here](https://www.tp-link.com/us/support/download/omada-software-controller/#Controller_Software)):

    cd /opt/
    wget https://static.tp-link.com/upload/software/2022/202205/20220507/Omada_SDN_Controller_v5.3.1_Linux_x64.tar.gz
    tar -zxvf Omada_SDN_Controller_v5.3.1_Linux_x64.tar.gz
    cd Omada_SDN_Controller_v5.3.1_Linux_x64
    sudo ./install.sh
    sudo rm -rf Omada_SDN_Controller_v5.3.1_Linux_x64.tar.gz
