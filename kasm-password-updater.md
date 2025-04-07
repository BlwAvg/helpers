# Update passwords to whatever on kasm
This resets the username and password for the default usernames in a Kasm install.


### Create a python script to creat the hash and salt.
1. `nano kasm-password.py`
2. 
```
import hashlib, uuid

password = "tacoman6000"  # your new simple password
salt = str(uuid.uuid4())  # generate a new salt
hash_obj = hashlib.sha256((password + salt).encode('utf-8'))
pw_hash = hash_obj.hexdigest()

print(f"salt = {salt}")
print(f"pw_hash = {pw_hash}")
```

### Check to see if the usernames exist correctly
```
SELECT user_id, username, pw_hash, salt, locked, disabled, failed_pw_attempts
FROM users
WHERE username = 'admin@kasm.local';

SELECT user_id, username, pw_hash, salt, locked, disabled, failed_pw_attempts
FROM users
WHERE username = 'user@kasm.local';
```

### Run the quieres to update the 
Update these queries with the correct username, hash and salt. This is for admin@kasm.local and user@kasm.local.
```
UPDATE users SET
    pw_hash = 'b91458ca5013db02ff5d40031d9324c03b931bcdd5ffa9c00afc92c95e7ac860',
    salt = 'dc03bc50-cc9b-4dc8-b79e-3996b91f4264',
    secret = NULL,
    set_two_factor = FALSE,
    locked = FALSE,
    disabled = FALSE,
    failed_pw_attempts = 0
WHERE username = 'admin@kasm.local';

UPDATE users SET
    pw_hash = 'b91458ca5013db02ff5d40031d9324c03b931bcdd5ffa9c00afc92c95e7ac860',
    salt = 'dc03bc50-cc9b-4dc8-b79e-3996b91f4264',
    secret = NULL,
    set_two_factor = FALSE,
    locked = FALSE,
    disabled = FALSE,
    failed_pw_attempts = 0
WHERE username = 'user@kasm.local';

/q
```
