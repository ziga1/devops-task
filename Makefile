COMPOSE ?= podman compose -f docker-compose.yml

.PHONY: up down logs ps restart-nginx restart-phpfpm restart-db build-nginx build-phpfpm build-mysql smoke

# Start services (no rebuild)
up:
	$(COMPOSE) up -d

# Stop services (keeps volumes)
down:
	$(COMPOSE) down

logs:
	$(COMPOSE) logs -f

ps:
	$(COMPOSE) ps

# Rebuild single service images if you changed Dockerfiles
build-nginx:
	podman build -t localhost/devops-nginx:local ./nginx

build-phpfpm:
	podman build -t localhost/devops-php-fpm:local ./php-fpm

build-mysql:
	podman build -t localhost/devops-mysql:local ./mysql

# Quick restarts
restart-nginx:
	podman restart nginx

restart-phpfpm:
	podman restart phpfpm

restart-db:
	podman restart devdb

# Minimal smoke test (no side effects)
smoke:
	@echo "==> HTTPS status (expect 200)"
	@curl -kIs https://127.0.0.1/ | head -n1 | grep -q " 200" && echo "PASS" || (echo "FAIL"; exit 1)
	@echo "==> HTTP redirect (expect 301)"
	@podman exec nginx curl -sI http://127.0.0.1/ | head -n1 | grep -q " 301" && echo "PASS" || (echo "FAIL"; exit 1)
	@echo "==> php-fpm listening on 9000"
	@podman exec phpfpm ss -ltn | grep -q ':9000' && echo "PASS" || (echo "FAIL"; exit 1)
	@echo "==> DB ping"
	@podman exec devdb mysqladmin ping -h 127.0.0.1 -u root -p"$$MYSQL_ROOT_PASSWORD" >/dev/null 2>&1 && echo "PASS" || (echo "FAIL"; exit 1)
