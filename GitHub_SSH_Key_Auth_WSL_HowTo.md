# Setup Github
Setup Github under WSL

```git config --global user.name "USER_NAME"```

```git config --global user.email "YOUR_EMAIL_HERE@domain.com"```

```git config --global credential.helper "/mnt/c/Program\ Files/Git/mingw64/bin/git-credential-manager.exe"```

NOTE: You may need to update git (using an elevated command prompt ```git update-git-for-windows``` for the git-credential-manager tie in.

You can also manually edit the file here:
```~/.gitconfig```

What the file looks like when properly configured:
```
cat ~/.gitconfig
[user]
        name = USER
        email = YOUR_EMAIL@domain.com
[credential]
        helper = /mnt/c/Program\\ Files/Git/mingw64/bin/git-credential-manager.exe
```

# Github Authentication via WSL
NOTE: 
1. When using WSL and VS Code concurrently. The SSH-Agent is not shared between WSL CLI and VS Code. You will have to ```source ~/.bashrc``` to kill the old SSH proxy and start up a new on in VS Code or WSL (assuming you append the script below to .bashrc. It is easier to not have both instances running at the same time. Which ever application was run last will take control of SSH proxy.

## Generating SSH Keys on WSL

1. make ssh key
```ssh-keygen -t ed25519 -C "YOUR_EMAIL@domain.com"```

2. Copy pub up to Github: Settings > SSH and GPG keys. Save as Authentication Key.

3. Enable ssh agent at startup. Copy this into the ~/.bashrc file. I added to the end of my bashrc.

NOTE: 
- The ```##``` are only to make this config easier to find and visually separate it from the rest of the ```~/.bashrc``` config.
- Rename the ``ssh-add -l &>/dev/null || ssh-add ~/.ssh/YOUR_KEYHERE``
```
##
##
##
#NOTE: This works with passphrase keys. It will ask for passphrase on WSL startup (via shell or VS Code).
# To setup SSH Agent on the local host
# Killing existing SSH Agents
existing_agents=$(pgrep -u "$USER" ssh-agent)
if [ -n "$existing_agents" ]; then
        echo "Killing Exisiting SSH agent(s) with PID(s): $existing_agents"
        pkill -u "$USER" ssh-agent
fi

# Enable SSH Agent
eval "$(ssh-agent -s)" > /dev/null
echo "New SSH Agent Pid: $SSH_AGENT_PID"

# Adding SSH Key
echo "**** Enter SSH Key Passphrase ****"
ssh-add -l &>/dev/null || ssh-add ~/.ssh/github-phrase
```

4. Run the new .bashrc
- ```source ~/.bashrc```

6. Add ssh key
- ```ssh-add ~/.ssh/KEY_NAME_HERE```

8. Test/Pull you git repo
- ```ssh -T git@github.com```
- ```git clone git@github.com:USERNAME_HERE/YOUR_REPO_HERE.git```



## Git BASH Windows
This configures gitbash for windows.

1. Move over SSH keys fom WSl to Windows ~/.ssh. All steps will be done in Git Bash
2. Create ssh config file ~/.ssh/config
```
Host github.com
        hostname github.com
        user git
        IdentityFile ~/.ssh/github
```

4. Create ~/.bashrc file and put this in it
```env=~/.ssh/agent.env

agent_load_env () { test -f "$env" && . "$env" >| /dev/null ; }

agent_start () {
    (umask 077; ssh-agent >| "$env")
    . "$env" >| /dev/null ; }

agent_load_env

# agent_run_state: 0=agent running w/ key; 1=agent w/o key; 2=agent not running
agent_run_state=$(ssh-add -l >| /dev/null 2>&1; echo $?)

if [ ! "$SSH_AUTH_SOCK" ] || [ $agent_run_state = 2 ]; then
    agent_start
    ssh-add
elif [ "$SSH_AUTH_SOCK" ] && [ $agent_run_state = 1 ]; then
    ssh-add
fi

unset env
```

4. Try pushing and pulling the config and then try doing it in your repo. I am making this vague because I am sick of trying to document everything.


## Manual Setup of SSH Key Auth for Git Bash or WSL
```eval "$(ssh-agent -s)"```
```ssh-add ~/.ssh/github-phrase```

## Troubleshooting

**Check if the SSH Agent is running**
```pgrep -u "$USER" ssh-agent```

**Check to see if Auth Sock is set**
```echo $SSH_AUTH_SOCK```

**When the agent is running check the ssh keys associated**
```ssh-add -l```

**Test ssh connection to github**
```ssh -T git@github.com```
