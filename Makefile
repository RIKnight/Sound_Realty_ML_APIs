APP?=flask-api
IMAGE?=yourorg/$(APP)
BLUE_TAG?=0.1.0
GREEN_TAG?=0.2.0

COMPOSE=docker compose

.PHONY: help
help:
\t@echo "Targets:"
\t@echo "  venv             Create venv and install deps"
\t@echo "  test             Run unit tests"
\t@echo "  build-blue       Build blue image"
\t@echo "  build-green      Build green image"
\t@echo "  up-blue          Start Traefik + blue live"
\t@echo "  up-green         Start Traefik + green live"
\t@echo "  promote-blue     Switch live traffic to blue"
\t@echo "  promote-green    Switch live traffic to green"
\t@echo "  scale-blue N=?   Scale blue to N replicas (when blue is live)"
\t@echo "  scale-green N=?  Scale green to N replicas (when green is live)"
\t@echo "  down             Stop all services (keeps images)"

venv:
\tpython -m venv .venv && . .venv/bin/activate && pip install -r requirements.txt

test:
\tpytest -q --cov=app

build-blue:
\tdocker build -t $(IMAGE):$(BLUE_TAG) --build-arg APP_VERSION=$(BLUE_TAG) .

build-green:
\tdocker build -t $(IMAGE):$(GREEN_TAG) --build-arg APP_VERSION=$(GREEN_TAG) .

up-blue:
\tBLUE_TAG=$(BLUE_TAG) GREEN_TAG=$(GREEN_TAG) $(COMPOSE) -f docker-compose.yml -f compose.live-blue.yml up -d
up-green:
\tBLUE_TAG=$(BLUE_TAG) GREEN_TAG=$(GREEN_TAG) $(COMPOSE) -f docker-compose.yml -f compose.live-green.yml up -d

promote-blue: up-blue

promote-green: up-green

scale-blue:
\t@if [ -z "$$N" ]; then echo "Usage: make scale-blue N=3"; exit 1; fi
\t$(COMPOSE) -f docker-compose.yml -f compose.live-blue.yml up -d --scale api_blue=$$N

scale-green:
\t@if [ -z "$$N" ]; then echo "Usage: make scale-green N=3"; exit 1; fi
\t$(COMPOSE) -f docker-compose.yml -f compose.live-green.yml up -d --scale api_green=$$N
down:
\t$(COMPOSE) down

