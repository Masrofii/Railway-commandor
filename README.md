# COMMANDOR Hosting Server

**COMMANDOR** is the main title. **HOSTING SERVER** is the smaller subtitle. Branding contact: `@xpT_T`.

A simple Ubuntu 24.04 SSH container template for Railway.

## Included

- Ubuntu 24.04
- OpenSSH server
- Node.js 22 and npm
- Python 3, pip and venv
- PM2, pnpm, Yarn, TypeScript, tsx and nodemon
- Git, curl, wget, nano, vim, htop, tmux, SQLite and common utilities
- COMMANDOR SSH welcome screen

## Deploy

1. Push this repository to GitHub.
2. In Railway, create a project and deploy the repository.
3. In the service's Variables tab, optionally set:

| Variable | Purpose |
|---|---|
| `SSH_USERNAME` | SSH username; defaults to `commandor` |
| `SSH_PASSWORD` | Your chosen SSH password. If omitted, a random password is generated and printed once in deployment logs. |
| `AUTHORIZED_KEYS` | Optional SSH **public** key (not a private key). |

4. In Railway Networking, enable a **TCP Proxy** targeting internal port `22`.
5. Copy the public TCP hostname and port Railway assigns.

## Connect

```bash
ssh -p PUBLIC_PORT commandor@PUBLIC_HOST
```

Replace `PUBLIC_PORT` and `PUBLIC_HOST` with the values Railway assigns. The public port is often not 22.

## Important

- If you do not set `SSH_PASSWORD`, the generated password is printed in deployment logs. Keep the Railway project private and save the password immediately. It can change when the container restarts or is redeployed.
- If you want a predictable password across restarts, set `SSH_PASSWORD` in Railway Variables. Do not commit it to GitHub or share it.
- `AUTHORIZED_KEYS` must contain a public key such as the contents of `id_ed25519.pub`. Never upload your private key.
- No dashboard, admin token, session secret, or persistent volume is required for this simple version.
- This is a Railway container, not a full virtual machine. Railway controls its resource limits and networking; some VPS-level functions may not be available.
- Files stored only inside the container may not survive replacement or redeployment. Keep important work in GitHub or another persistent storage service.

## Local Docker test

```bash
docker build -t commandor-hosting .
docker run --rm -p 2222:22 commandor-hosting
```

Then connect using the generated password shown in the container output:

```bash
ssh -p 2222 commandor@localhost
```
