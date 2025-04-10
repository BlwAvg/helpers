# 💻 Enable Local Account Setup in Windows 11 OOBE
All credit goes to: https://x.com/witherornot1337/status/1906050664741937328


By default, Windows 11 setup requires a Microsoft account and internet connection. This guide shows how to bypass that and create a **local account** instead.

## 🔧 Steps

1. When at the **OOBE (Out-Of-Box Experience)** screen, and prompted to connect to a network:

2. Press the following keyboard shortcut to open a command prompt:
```
Shift + F10
```

4. **Run the following command:**
```
start ms-cxh:localonly
```


 This bypasses the network requirement and allows you to create a local user account instead of being forced to sign in with a Microsoft account.
