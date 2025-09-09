# Hardening Notes (VM with rootless Podman)

Scope: single Fedora 42 host running **nginx + php-fpm + MariaDB** with rootless Podman. Goal: keep attack surface small and ops simple.

## Accounts & SSH
- Create a normal user and use **SSH keys only** (no passwords).
- `/etc/ssh/sshd_config`:
  - `PasswordAuthentication no`
  - `PermitRootLogin no`
  - (Optional) `PubkeyAuthentication yes`
- Restart SSH: `sudo systemctl restart sshd`
- (Optional) Add 2FA (e.g., Google Authenticator PAM) if exposed to the internet.

## Firewall (firewalld)
- Only allow **22 (SSH)** and **443 (HTTPS)**.
```bash
sudo firewall-cmd --permanent --add-service=ssh
sudo firewall-cmd --permanent --add-service=https
sudo firewall-cmd --reload
