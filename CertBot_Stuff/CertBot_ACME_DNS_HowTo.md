My DNS Provider did not provide integration with certbot. I found this method worked, but there was not a lot of documentation online. This was my process.

## Prerequisites
- [ACME DNS Server](https://github.com/joohoi/acme-dns/releases)  
- [ACME DNS Client](https://github.com/acme-dns/acme-dns-client/releases)  
- *nix OS  
  - must be done from a non-root account with sudo privileges.  
  - This was done on ubuntu 22.04 LTS. Change your /bin directories to match your *nix environment.  
  - Change the commands to match the version of client and server you downloaded.  
- Certbot  
- Non API compatible Lets Encrypt DNS server. Note, Google DNS is not the same as Google Domains DNS. A list of supported providers can be found [here](https://community.letsencrypt.org/t/dns-providers-who-easily-integrate-with-lets-encrypt-dns-validation/86438). If your DNS server is on the list you can ignore this and check out that plugin.

---

## Acme DNS Server Setup

1. The config file needs to reside in the `/etc/acme-dns` directory.
   
       sudo mkdir /etc/acme-dns
       cd /etc/acme-dns

2. Download the latest [ACME DNS Server](https://github.com/joohoi/acme-dns/releases). Change the command according to the latest release.
   
       sudo wget https://github.com/joohoi/acme-dns/releases/download/v1.0/acme-dns_1.0_linux_amd64.tar.gz

3. Untar the file in the `/etc` directory. Change the command if needed:
   
       sudo tar -xvf acme-dns_1.0_linux_amd64.tar.gz

4. Edit the `config.cfg`:

       sudo nano /etc/config.cfg

   Edit the following lines:
   - `listen =` to be your (likely public) IP that your hosting DNS provider can reach.
   - `domain =` needs to be a subdomain of the domain you want to create. In this example we use `auth.ACME_DNS_DOMAIN.dev`.
   - `nsname =` the zone for your subdomain (likely the same as above). Use `auth.ACME_DNS_DOMAIN.dev`.
   - `nsadmin =` domain contact info. **Do not use '@'** — use a `.`. This example: `webmaster.ACME_DNS_DOMAIN.dev`.
   - `records =` replace domain names with your domain name. Here, `auth.ACME_DNS_DOMAIN.dev`. The IP address should be the same public address as the one used to listen on (e.g. `123.123.123.456`).
   - `ip =` in this example the certbot client resides on the same server. Use `127.0.0.1`.
   - `port =` because this can only be done on the local host, we use port `8080`.
   - `tls =` change to `"none"` since the client is accessed from the local host (no encryption required).

   **Sample config:**

       [general]
       listen = "123.123.123.456:53"
       protocol = "both"
       domain = "auth.ACME_DNS_DOMAIN.dev"
       nsname = "auth.ACME_DNS_DOMAIN.dev"
       nsadmin = "webmaster.ACME_DNS_DOMAIN.dev"
       records = [
           "auth.ACME_DNS_DOMAIN.dev. A 123.123.123.456",
           "auth.ACME_DNS_DOMAIN.dev. NS auth.ACME_DNS_DOMAIN.dev.",
       ]
       debug = false

       [database]
       engine = "sqlite3"
       connection = "/var/lib/acme-dns/acme-dns.db"

       [api]
       ip = "127.0.0.1"
       disable_registration = false
       port = "8080"
       tls = "none"
       tls_cert_privkey = "/etc/tls/example.org/privkey.pem"
       tls_cert_fullchain = "/etc/tls/example.org/fullchain.pem"
       acme_cache_dir = "api-certs"
       notification_email = ""
       corsorigins = [
           "*"
       ]
       use_header = false
       header_name = "X-Forwarded-For"

       [logconfig]
       loglevel = "debug"
       logtype = "stdout"
       logformat = "text"

5. Create a minimal `acme-dns` user. (The service will run under this user):
   
       sudo adduser --system --gecos "acme-dns Service" --disabled-password --group --home /var/lib/acme-dns acme-dns

6. Move the `acme-dns` executable from `/etc/acme-dns` to `/usr/bin/acme-dns` (Any location will work, just be sure to update the service file accordingly):
   
       sudo mv /etc/acme-dns/acme-dns /usr/bin/

7. Edit the `acme-dns.service` file to match the location `/usr/bin/acme-dns`. It should look like:
   
       [Unit]
       Description=Limited DNS server with RESTful HTTP API to handle ACME DNS challenges easily and securely
       After=network.target

       [Service]
       User=acme-dns
       Group=acme-dns
       AmbientCapabilities=CAP_NET_BIND_SERVICE
       WorkingDirectory=~
       ExecStart=/usr/bin/acme-dns
       Restart=on-failure

       [Install]
       WantedBy=multi-user.target

8. Move the systemd service unit from `acme-dns.service` to `/etc/systemd/system/acme-dns.service`:

       sudo mv /etc/acme-dns/acme-dns.service /etc/systemd/system

9. Reload systemd units:

       sudo systemctl daemon-reload

10. Enable acme-dns on boot:

        sudo systemctl enable acme-dns.service

11. Run acme-dns:

        sudo systemctl start acme-dns.service

    - Verify it worked:

          sudo systemctl status acme-dns.service

    - Troubleshoot any issues:

          sudo journalctl --unit acme-dns --follow

---

## Google DNS Configuration

1. Create an `NS` record that points to the subdomain used in the `config.cfg`.
   - **Hostname**: `auth.ACME_DNS_DOMAIN.dev`
   - **Type**: `NS`
   - **Data**: `auth.ACME_DNS_DOMAIN.dev.`

2. Create an `A` record that points to the public IP in the `config.cfg`.
   - **Hostname**: `auth.ACME_DNS_DOMAIN.dev`
   - **Type**: `A`
   - **Data**: `123.123.123.456`

It should look something like this:

![googledomainsdns_1.png?620](googledomainsdns_1.png?620)

---

## Acme DNS Client

1. Download the latest [ACME DNS Client](https://github.com/acme-dns/acme-dns-client/releases):

       sudo wget https://github.com/acme-dns/acme-dns-client/releases/download/v0.3/acme-dns-client_0.3_linux_amd64.tar.gz

2. Untar the file:

       sudo tar -xvf acme-dns-client_0.3_linux_amd64.tar.gz

3. Move the `acme-dns-client` binary to the `/usr/bin` directory (or wherever your distro prefers):

       sudo mv acme-dns-client /usr/bin/

4. Remove any unwanted files from the tar, if necessary.

5. Tie the `_acme-challenge` from your public DNS server to the ACME DNS server:

       sudo acme-dns-client register -d ACME_DNS_DOMAIN.dev -s http://localhost:8080

   - Register to the base domain, **not** the `auth.ACME_DNS_DOMAIN.dev` domain.
   - `http://localhost:8080` is the address defined in the ACME DNS `config.cfg` (`ip =` and `port =`).
   - When asked if you want to monitor the CNAME records change, choose "y".
   - It will give you a record to add to your public DNS. Add it and wait for the app to detect the change.
   
   Example DNS change:
   ![googledomainsdns_2.png?600](googledomainsdns_2.png?600)

   ![googledomainsdns_3.png?600](googledomainsdns_3.png?600)

   - You should see something like:

         [*] CNAME record is now correctly set up!

   - The last question is about setting up a CAA record. You can choose to skip if you’re unsure.

---

## Using Certbot

Use this command to issue a wildcard certificate:

    sudo certbot certonly --manual --preferred-challenges dns --manual-auth-hook 'acme-dns-client' --non-interactive --agree-tos -m webmaster@ACME_DNS_DOMAIN.dev -d *.wildcard_domain.com
