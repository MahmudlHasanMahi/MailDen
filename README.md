# MailDen

> Your home. Your mail. Your rules.

MailDen is a self-hosted personal email storage system that fetches your emails from Gmail, stores them permanently on your home server, and serves them through a clean web interface — keeping your mail off third-party servers and completely under your control.

---

## Features

- Pulls emails from Gmail via IMAP and stores them locally in Maildir format
- Deletes emails from Gmail after syncing (optional)
- Serves mail via Dovecot IMAP server
- Webmail interface via Roundcube
- Sends outgoing mail via Gmail SMTP
- Accessible remotely via Cloudflare Tunnel — no domain, no port forwarding needed
- Fully containerized with Docker Compose

---

## Stack

| Component | Role |
|---|---|
| **mbsync** | Fetches emails from Gmail and stores locally |
| **Maildir** | Local email storage format |
| **Dovecot** | IMAP server that serves mail to Roundcube |
| **Roundcube** | Webmail UI accessible from any browser |
| **Cloudflare Tunnel** | Exposes Roundcube to the internet without port forwarding |

### Architecture

```
Gmail → mbsync → Maildir → Dovecot → Roundcube → Browser
                                                    ↑
                                         Cloudflare Tunnel (remote access)
```

---

## Requirements

- Docker
- Gmail account with IMAP enabled
- Gmail App Password 

---

## Project Structure

```
mailden/
├── docker-compose.yml
├── .env
├── entrypoint.sh
├── maildata/               # Local email storage (Maildir)
├── mbsync/
│   └── .mbsyncrc           # mbsync Gmail config
├── dovecot/
│   └── dovecot.conf        # Dovecot config template
└── roundcube-config/
    └── config.inc.php      # Roundcube config
```

---

## Setup

### 1. Clone the repository

```bash
git clone https://github.com/youruser/mailden.git
cd mailden
```

### 2. Configure environment variables

```bash
nano .env
```

```env
USER_MAIL=your@gmail.com
PASS=your_gmail_app_password
USER_NAME_DOMAIN=gmail.com
DOVECOT_USER=yourname
DOVECOT_PASSWORD=your_hashed_password
```

### 3. Generate a secure Dovecot password

```bash
docker run --rm dovecot/dovecot:latest-root doveadm pw -s SHA512-CRYPT
```

Copy the output and paste it as `DOVECOT_PASSWORD` in your `.env`.

### 4. Configure mbsync

```bash
nano mbsync/.mbsyncrc
```

```
IMAPAccount gmail
Host imap.gmail.com
User your@gmail.com
Pass your_app_password_without_spaces
TLSType IMAPS
CertificateFile /etc/ssl/certs/ca-certificates.crt

IMAPStore gmail-remote
Account gmail

MaildirStore gmail-local
SubFolders Verbatim
Path /mail/
Inbox /mail/Inbox

Channel gmail
Far :gmail-remote:
Near :gmail-local:
Patterns *
Expunge None
SyncState *
Create Both
```

> Set `Expunge None` to keep emails in Gmail during testing. Change to `Expunge Far` in production to delete from Gmail after syncing.

### 5. Start the stack

```bash
./entrypoint.sh
```

---

## Remote Access

MailDen uses Cloudflare Quick Tunnel for remote access — no domain or port forwarding needed.

```bash
cloudflared tunnel --url http://localhost:8080
```

This gives you a temporary URL like `https://random-words.trycloudflare.com`. Open it in any browser to access your webmail from anywhere.

> The URL changes on each restart. For a permanent URL, purchase a domain (~$10/yr) and set up a named Cloudflare Tunnel.

---

## Usage

### Accessing webmail

Open the Cloudflare tunnel URL or `http://localhost:8080` on your local network.

Log in with:
- **Username:** your `DOVECOT_USER` value
- **Password:** your plain password (before hashing)

### Manually syncing emails

```bash
docker compose run mbsync
```

### Archiving emails

```bash
# Create a compressed archive
tar -czf mail-archive-$(date +%Y%m).tar.gz ./maildata

# Download to your local machine
scp user@your-server-ip:~/mailden/mail-archive-*.tar.gz ~/Downloads/
```

### Changing your password

Generate a new hash:
```bash
docker exec -it dovecot doveadm pw -s SHA512-CRYPT
```

Update `DOVECOT_PASSWORD` in `.env`, then restart:
```bash
docker compose restart dovecot
```

---

## Deployment on Home Server

MailDen is designed to run on a home Linux server. Since most home ISPs use CGNAT (shared IP), traditional port forwarding won't work — Cloudflare Tunnel handles remote access instead.

```bash
# On your server
git clone https://github.com/youruser/mailden.git
cd mailden
./entrypoint.sh

# Start Cloudflare tunnel
cloudflared tunnel --url http://localhost:8080
```

---

## Security Notes

- Never commit your `.env` file — it's in `.gitignore`
- Always use hashed passwords in production
- Keep your Gmail App Password secure and revoke it if compromised
- Cloudflare Quick Tunnels are temporary and change on restart — use a named tunnel for production

---

