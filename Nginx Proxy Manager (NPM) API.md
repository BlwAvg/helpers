# API Commands for Nginx Proxy Manager

Below is a summary of all methods defined in `frontend/js/app/api.js`, along with sample `curl` commands for each:
[NPM Official Github](https://github.com/NginxProxyManager/nginx-proxy-manager/blob/develop/frontend/js/app/api.js)

This is also an awesome reference
https://github.com/Erreur32/nginx-proxy-manager-Bash-API?tab=readme-ov-file#reference-api

## API Methods

| Category                  | Function                           | HTTP Method | Endpoint                                               | Description                                    |
|---------------------------|------------------------------------|-------------|--------------------------------------------------------|------------------------------------------------|
| **Core**                  | `status()`                         | GET         | `/api/`                                                | Health-check/status                            |
| **Tokens**                | `Tokens.login(identity, secret)`   | POST        | `/api/tokens`                                          | Obtain a new JWT                               |
|                           | `Tokens.refresh()`                 | GET         | `/api/tokens`                                          | Refresh current token                          |
| **Users**                 | `Users.getAll(expand, query)`      | GET         | `/api/users`                                           | List users                                     |
|                           | `Users.getById(id, expand)`        | GET         | `/api/users/:id`                                       | Get a single user                              |
|                           | `Users.create(data)`               | POST        | `/api/users`                                           | Create new user                                |
|                           | `Users.update(data)`               | PUT         | `/api/users/:id`                                       | Update existing user                           |
|                           | `Users.delete(id)`                 | DELETE      | `/api/users/:id`                                       | Delete user                                    |
|                           | `Users.setPassword(id, auth)`      | PUT         | `/api/users/:id/auth`                                  | Change user password                           |
|                           | `Users.loginAs(id)`                | POST        | `/api/users/:id/login`                                 | Impersonate another user                       |
|                           | `Users.setPermissions(id, perms)`  | PUT         | `/api/users/:id/permissions`                           | Set RBAC permissions                           |
| **Nginx → Proxy Hosts**   | `ProxyHosts.getAll(expand, query)` | GET         | `/api/nginx/proxy-hosts`                               | List proxy hosts                               |
|                           | `ProxyHosts.get(id)`               | GET         | `/api/nginx/proxy-hosts/:id`                           | Get one proxy host                             |
|                           | `ProxyHosts.create(data)`          | POST        | `/api/nginx/proxy-hosts`                               | Create proxy host                              |
|                           | `ProxyHosts.update(data)`          | PUT         | `/api/nginx/proxy-hosts/:id`                           | Update proxy host                              |
|                           | `ProxyHosts.delete(id)`            | DELETE      | `/api/nginx/proxy-hosts/:id`                           | Delete proxy host                              |
|                           | `ProxyHosts.enable(id)`            | POST        | `/api/nginx/proxy-hosts/:id/enable`                    | Enable proxy host                              |
|                           | `ProxyHosts.disable(id)`           | POST        | `/api/nginx/proxy-hosts/:id/disable`                   | Disable proxy host                             |
| **Nginx → Redirection**   | `RedirectionHosts.getAll(...)`     | GET         | `/api/nginx/redirection-hosts`                         | List redirection hosts                         |
|                           | `RedirectionHosts.get(id)`         | GET         | `/api/nginx/redirection-hosts/:id`                     | Get one redirection host                       |
|                           | `RedirectionHosts.create(data)`    | POST        | `/api/nginx/redirection-hosts`                         | Create redirection host                        |
|                           | `RedirectionHosts.update(data)`    | PUT         | `/api/nginx/redirection-hosts/:id`                     | Update redirection host                        |
|                           | `RedirectionHosts.delete(id)`      | DELETE      | `/api/nginx/redirection-hosts/:id`                     | Delete redirection host                        |
|                           | `RedirectionHosts.setCerts(id)`    | POST        | `/api/nginx/redirection-hosts/:id/certificates`        | Upload certificates                            |
|                           | `RedirectionHosts.enable(id)`      | POST        | `/api/nginx/redirection-hosts/:id/enable`              | Enable redirect                                |
|                           | `RedirectionHosts.disable(id)`     | POST        | `/api/nginx/redirection-hosts/:id/disable`             | Disable redirect                               |
| **Nginx → Streams**       | `Streams.getAll(...)`              | GET         | `/api/nginx/streams`                                   | List TCP/UDP streams                           |
|                           | `Streams.get(id)`                  | GET         | `/api/nginx/streams/:id`                               | Get one stream                                 |
|                           | `Streams.create(data)`             | POST        | `/api/nginx/streams`                                   | Create stream                                  |
|                           | `Streams.update(data)`             | PUT         | `/api/nginx/streams/:id`                               | Update stream                                  |
|                           | `Streams.delete(id)`               | DELETE      | `/api/nginx/streams/:id`                               | Delete stream                                  |
|                           | `Streams.enable(id)`               | POST        | `/api/nginx/streams/:id/enable`                        | Enable stream                                  |
|                           | `Streams.disable(id)`              | POST        | `/api/nginx/streams/:id/disable`                       | Disable stream                                 |
| **Nginx → Dead Hosts**    | `DeadHosts.getAll(...)`            | GET         | `/api/nginx/dead-hosts`                                | List dead hosts                                |
|                           | `DeadHosts.get(id)`                | GET         | `/api/nginx/dead-hosts/:id`                            | Get one dead host                              |
|                           | `DeadHosts.create(data)`           | POST        | `/api/nginx/dead-hosts`                                | Create dead host                               |
|                           | `DeadHosts.update(data)`           | PUT         | `/api/nginx/dead-hosts/:id`                            | Update dead host                               |
|                           | `DeadHosts.delete(id)`             | DELETE      | `/api/nginx/dead-hosts/:id`                            | Delete dead host                               |
|                           | `DeadHosts.setCerts(id)`           | POST        | `/api/nginx/dead-hosts/:id/certificates`               | Upload certificates                            |
|                           | `DeadHosts.enable(id)`             | POST        | `/api/nginx/dead-hosts/:id/enable`                     | Enable dead host                               |
|                           | `DeadHosts.disable(id)`            | POST        | `/api/nginx/dead-hosts/:id/disable`                    | Disable dead host                              |
| **Nginx → Access Lists**  | `AccessLists.getAll(...)`          | GET         | `/api/nginx/access-lists`                              | List access lists                              |
|                           | `AccessLists.create(data)`         | POST        | `/api/nginx/access-lists`                              | Create access list                             |
|                           | `AccessLists.update(data)`         | PUT         | `/api/nginx/access-lists/:id`                          | Update access list                             |
|                           | `AccessLists.delete(id)`           | DELETE      | `/api/nginx/access-lists/:id`                          | Delete access list                             |
| **Nginx → Certificates**  | `Certificates.getAll(...)`         | GET         | `/api/nginx/certificates`                              | List certificates                              |
|                           | `Certificates.create(data)`        | POST        | `/api/nginx/certificates`                              | Create certificate                             |
|                           | `Certificates.update(data)`        | PUT         | `/api/nginx/certificates/:id`                          | Update certificate                             |
|                           | `Certificates.delete(id)`          | DELETE      | `/api/nginx/certificates/:id`                          | Delete certificate                             |
|                           | `Certificates.upload(id)`          | POST        | `/api/nginx/certificates/:id/upload`                   | Upload cert files                              |
|                           | `Certificates.validate(form)`      | POST        | `/api/nginx/certificates/validate`                     | Validate certificate                            |
|                           | `Certificates.renew(id)`           | POST        | `/api/nginx/certificates/:id/renew`                    | Renew via ACME                                 |
|                           | `Certificates.testHttpChallenge(...)` | GET      | `/api/nginx/certificates/test-http?domains=`           | Test HTTP-01 challenge                         |
|                           | `Certificates.download(id)`        | GET         | `/api/nginx/certificates/:id/download`                 | Download cert bundle                           |
| **Audit & Reports**       | `AuditLog.getAll(...)`             | GET         | `/api/audit-log`                                       | Fetch activity log                             |
|                           | `Reports.getHostStats()`           | GET         | `/api/reports/hosts`                                   | Proxy-host usage stats                         |
| **Settings**              | `Settings.getAll()`                | GET         | `/api/settings`                                        | List all settings                              |
|                           | `Settings.getById(id)`             | GET         | `/api/settings/:id`                                    | Fetch one setting                              |
|                           | `Settings.update(data)`            | PUT         | `/api/settings/:id`                                    | Update setting                                 |

## Sample `curl` Commands

### 1) Health-check
```bash
curl -i \
  -H "Accept: application/json" \
  http://NPM_IP_HERE:81/api/
```

### 2) Log in (get token)
```bash
curl -X POST http://NPM_IP_HERE:81/api/tokens \
  -H "Content-Type: application/json" \
  -d '{"identity":"NPM_USERNAME_HERE","secret":"NPM_PASSWORD_HERE"}'
```
or temporarily store your token in a variable
```bash
TOKEN=$(
  curl -s -X POST 'http://NPM_IP_HERE:81/api/tokens' \
    -H 'Content-Type: application/json' \
    -d '{"identity":"NPM_USERNAME_HERE","secret":"NPM_PASSWORD_HERE"}' \
  | sed -n 's/.*"token":"\([^"]*\)".*/\1/p'
  )
```

### 3) Refresh token
```bash
curl -H "Authorization: Bearer $TOKEN" \
     -H "Accept: application/json" \
     http://NPM_IP_HERE:81/api/tokens
```


### 4) List all proxy hosts
```bash
curl -H "Authorization: Bearer $TOKEN" \
     -H "Accept: application/json" \
     "http://NPM_IP_HERE:81/api/nginx/proxy-hosts?expand=owner"
```

### 5) Create a new proxy host
```bash
curl -X POST http://NPM_IP_HERE:81/api/nginx/proxy-hosts \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
        "domain_names":["app.local"],
        "forward_host":"10.0.0.5",
        "forward_port":8080,
        "ssl":{ "certificate_id":2 }
      }'
```

### 6) Renew an ACME certificate
Update the number in the URL with the directory that has the certificate stored
```bash
curl -X POST http://NPM_IP_HERE:81/api/nginx/certificates/5/renew \
  -H "Authorization: Bearer $TOKEN" \
  -H "Accept: application/json"
```
