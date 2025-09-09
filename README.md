# DevOps Task — PHP + Nginx + MariaDB

Stack: nginx (HTTPS, 497→HTTPS) → php-fpm (PHP 8.x) → MariaDB/MySQL.  
Runs with rootless Podman on Fedora 42. CI builds images on GitLab.

## What this repository contains
- nginx and php-fpm Dockerfiles + minimal configs
- PHP app that reads `APP_TITLE` and `DB_*` from environment variables
- MariaDB image with optional first-boot seed SQL
- Podman kube manifests (ConfigMap, Secret example)
- Hardening notes (`docs/HARDENING.md`)

## Basic usage (local)
- Create `.env` from `.env.example` (keep `.env` out of git)
- Generate local dev certs and place them in `nginx/certs/` (not committed)
- Start with Podman Compose and open `https://127.0.0.1/`

## Security measures implemented
- Secrets/certs are **not** committed; example files provided for guidance
- HTTPS enabled for local dev; HTTP redirected to HTTPS; nginx handles error **497**
- Containers run **rootless**; mounts labeled for SELinux on Fedora (`:Z`/`:z`)
- Logs go to stdout/stderr (inspect with `podman logs`)
- Minimal set of env vars used by the app; no hardcoded credentials
- Hardening documented separately (SSH keys only, firewall 22/443, fail2ban, SELinux, updates, backup approach)

## CI/CD (GitLab)
A minimal pipeline builds and pushes `mysql`, `php-fpm`, and `nginx` images to the project’s registry.  
Tags by commit SHA and `latest` on the default branch.
