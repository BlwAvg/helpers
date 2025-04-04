# Firefox HSTS Preload List – `network.stricttransportsecurity.preloadlist`

1. open Firefox, in the search bar type `about:config`.
2. From the about:config window search for `network.stricttransportsecurity.preloadlist`
3. Change value from true to false.

**NOTE: This CANNOT done in  Chrome, Chromium (unless you do a custom build) or MS Edge.**

---

## 🔐 What is HSTS?

**HTTP Strict Transport Security (HSTS)** is a web security policy mechanism that forces browsers to interact with websites only over **secure HTTPS connections**. It is enabled by the web server via the `Strict-Transport-Security` HTTP header.

### Example:
```http
Strict-Transport-Security: max-age=63072000; includeSubDomains; preload
```

---

## 📋 What is the HSTS Preload List?

The **HSTS preload list** is a list of domains hardcoded into browsers (like Firefox and Chrome) that must **always** be accessed over HTTPS — even on the **first visit**.

- Maintained by [Google](https://hstspreload.org)
- Used by Firefox, Chrome, Edge, Safari, and others
- Prevents SSL stripping or downgrade attacks

### ✅ Requirements to be added:
- HTTPS must be enabled
- Must serve a valid HSTS header with `preload`
- Must support HTTPS on all subdomains

---

## 🛠 `network.stricttransportsecurity.preloadlist` in Firefox

- **Type**: `Boolean`
- **Default**: `true`
- **Function**:
  - When `true`, Firefox **enforces HTTPS** for all sites on the HSTS preload list.
  - When `false`, Firefox ignores the preload list and only enforces HSTS for sites that have been previously visited with a valid HSTS header.

---

## 🔄 Use Cases

| Setting | Behavior | Use Case |
|--------|----------|-----------|
| `true` (default) | Enforces HTTPS for all preloaded sites | Recommended for maximum security |
| `false` | Ignores preload list | For debugging or development/testing environments |

> ⚠️ **Warning**: Disabling this setting reduces browser security and opens you to downgrade attacks. Only disable it temporarily for testing purposes.

---

## 🔍 Check if a Site is Preloaded

You can check if a domain is on the HSTS preload list at [hstspreload.org](https://hstspreload.org).


