# How to install Kea and Stork on Linux
I really disliked the documentation for installing Kea and Stork. This is what I did to install it on a Proxmox LXC container. 

## Software installation as root in container
Start by installing the things:

```apt update```

```apt install curl apt-transport-https ca-certificates gnupg postgresql```

```curl -1sLf 'https://dl.cloudsmith.io/public/isc/kea-dev/cfg/setup/bash.deb.sh' | bash```

```curl -1sLf 'https://dl.cloudsmith.io/public/isc/stork/cfg/setup/bash.deb.sh' | bash```

```apt install isc-kea isc-stork-server```

```systemctl enable isc-stork-server```

**Notes:**
- Curl scripts are provided by Cloudsmith and automatically add the repos to /etc/apt/sources.d
- This installs the lastes dev version, if you want something specifc look up the repo (provided below) and install whatever package you want.
- Kea is systemctl enabled and started on install, Stork is not. This is pending the DB setup.
- For installing the repo make sure to install isc-* so it will use the newly added repo and the default Debian package.

## Change to user postgres to set db password and create db
1. Change to postgres user ```su - postgres```
3. Launch postgres ```psql```
4. Set the password for user postgres in the db ```ALTER USER postgres PASSWORD 'SUPER_SECRET_PASSWORD_HERE._IF_I_MAKE_THIS_LONG_ENOUGH_YOU_MAY_NOTICE_THIS_AND_CHANGE_IT._YOU_IDIOT';``` then quit the db ```\q```
5. Dont forget to quit psql with ```\q```
6. After existing the database and at a bash prompt use the stork tool to create the db ```stork-tool db-create --db-name stork --db-user postgres --db-password SUPER_SECRET_PASSWORD_HERE._IF_I_MAKE_THIS_LONG_ENOUGH_YOU_MAY_NOTICE_THIS_AND_CHANGE_IT._YOU_IDIOT```
7. Got back to root ```exit```

## Edit the Stork configuration and start Stork
1. Nano is better than VI you poser ```nano /etc/stork/server.env```
2. Add this to the config. The top is just fine.
```
STORK_DATABASE_HOST=127.0.0.1
STORK_DATABASE_PORT=5432
STORK_DATABASE_NAME=stork
STORK_DATABASE_USER_NAME=postgres
STORK_DATABASE_PASSWORD=SUPER_SECRET_PASSWORD_HERE._IF_I_MAKE_THIS_LONG_ENOUGH_YOU_MAY_NOTICE_THIS_AND_CHANGE_IT._YOU_IDIOT
```
  - **NOTE:** Make sure to remove or comment out the existing line in the config for ```STORK_DATABASE_PASSWORD=```
3. Start Stork ```systemctl start isc-stork-server```
4. Check to see if you messed up ```systemctl status isc-stork-server```
5. the site can be found at YOUR_IP_HERE:8080. Default Username and password is admin/admin

## Install and Setup Stork Agent
I though this was done until I opened up stork and realized I couldnt configure anything. So here is more stuff.

1. Install the stork agent ```apt install isc-stork-agent```
2. Enable the service ```systemctl enable isc-stork-agent.service```
3. configure the stork agent by running this command and following the prompts.
```su stork-agent -s /bin/sh -c 'stork-agent register --server-url http://127.0.0.1:8080'```
  - For this prompt ```Enter the Stork server access token (optional):``` you can get the key from the stork server by clicking on the "How to Install Agent on New Machine". It says optional. I configured it with the key provided.
  - For this prompt ```Enter port number that Stork Agent will listen on [8080]:``` enter ```8081```. This didnt actually change the port for me, so I had to do it manually my self. This only needs to be changes if the stork agent and server are on the same box. Or share the same port. If you changed the stork server port then your dont need to change this.
3. (IF NEEDED) modify the service to use the correct port because the script didnt work. ```nano /lib/systemd/system/isc-stork-agent.service``` and add ```--port=8081``` to the ExecStart line like so ```ExecStart=/usr/bin/stork-agent --port=8081```
4. If you modified the service reload the daemon and restart the service
```
systemctl daemon-reload
systemctl restart isc-stork-agent.service
qsystemctl status isc-stork-agent.service
```

## Notes
- Stork Server does not read the /etc/stork/server.env by default when calling the binary directly (not using systemd). 
-	Obviously modify the script with command with sudo if using a non-root user
- Kea Services
  - isc-kea-dhcp4 — Kea DHCPv4 server package
  - isc-kea-dhcp6 — Kea DHCPv6 server package
  - isc-kea-dhcp-ddns — Kea DHCP DDNS server
  - isc-kea-ctrl-agent — Kea Control Agent for remote configuration
  - isc-kea-admin — Kea database administration tools
  - isc-kea-hooks — Kea open source DHCP hooks

## Links
- [Stork Documentation](https://stork.readthedocs.io/en/latest/install.html)
- [Stork Cloudsmith Repo](https://cloudsmith.io/~isc/repos/stork/packages/)
- [Kea Documentation](https://kea.readthedocs.io/en/latest/)
- [Kea Dev Cloudsmith Repo](https://cloudsmith.io/~isc/repos/kea-dev/packages/)

### Proxmox container settings
NOTE: IF you have the FW enabled make sure you allow the required traffic to pass or crap won’t work.
```
arch: amd64
cores: 2
features: nesting=1
hostname: dhcp
memory: 2048
nameserver: CONTAINER_HOSTNAME_HERE
net0: name=eth0,bridge=BRIDGE_HERE,firewall=1,gw=CONTAINER_GW_HERE,hwaddr=BL:AH:BL:AH:BL:AH,ip=CONTAINER_IP_HERE/SUBNET,type=veth
ostype: debian
rootfs: local-lvm:vm-110-disk-0,size=8G
searchdomain: YOUR_SUPER_COOL_DOMAIN_HERE
swap: 2048
unprivileged: 1
```
