COMPOSE ?= podman-compose -f docker-compose.yml

.PHONY: up down logs ps rebuild-nginx

ensure-dotenv:
	@test -f .env || cp .env.example .env

up: ensure-dotenv
	$(COMPOSE) up -d

down:
	$(COMPOSE) down

logs:
	$(COMPOSE) logs -f

ps:
	$(COMPOSE) ps

rebuild-nginx:
	podman build -t devops-nginx:local ./nginx && $(COMPOSE) up -d nginx

smoke:
	@echo "==> Checking ports"
	@podman ps --format "table {{.Names}}\t{{.Ports}}"
	@echo "==> HTTPS status"
	@curl -kIs https://127.0.0.1/ | head -n1 | grep -q " 200" && echo "PASS: HTTPS 200" || (echo "FAIL: HTTPS not 200"; exit 1)
	@echo "==> Title from .env"
	@curl -ks https://127.0.0.1/ | grep -q "App title from ENV: $(shell grep ^APP_TITLE= .env | cut -d= -f2)" && echo "PASS: title matches" || (echo "FAIL: title mismatch"; exit 1)
	@echo "==> Events present"
	@curl -ks "https://127.0.0.1/events.php" | grep -q '"id"' && echo "PASS: events visible" || (echo "FAIL: events not found"; exit 1)
	@echo "==> Network DNS"
	@podman exec -it phpfpm getent hosts devdb >/dev/null && echo "PASS: phpfpm can resolve devdb" || (echo "FAIL: phpfpm cannot resolve devdb"; exit 1)
