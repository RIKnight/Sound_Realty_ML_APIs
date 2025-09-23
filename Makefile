APP_NAME?=flask-api
IMAGE?=dataknight/$(APP_NAME)
BLUE_TAG?=0.1.0
GREEN_TAG?=0.2.0

COMPOSE=docker compose

.PHONY: help
help:
	@echo "Targets:"
	@echo "  venv             Create Flask venv and install deps"
	@echo "  train-venv       Create scikit-learn venv and install deps"
	@echo "  test             Run unit tests in Flask venv"
	@echo "  train-model      Train a new model in training venv"
	@echo "  build-blue       Build blue image"
	@echo "  build-green      Build green image"
	@echo "  up-blue          Start Traefik + blue live"
	@echo "  up-green         Start Traefik + green live"
	@echo "  promote-blue     Switch live traffic to blue"
	@echo "  promote-green    Switch live traffic to green"
	@echo "  scale-blue N=?   Scale blue to N replicas (when blue is live)"
	@echo "  scale-green N=?  Scale green to N replicas (when green is live)"
	@echo "  down             Stop all services (keeps images)"

venv:
	python -m venv .venv && . .venv/bin/activate && pip install -r requirements.txt

train-venv:
	python -m venv .train_venv && . .train_venv/bin/activate && pip install -r training_requirements.txt

test: venv
	source .venv/bin/activate && pytest -q --cov=app && deactivate

train-model: train-venv
	source .train_venv/bin/activate && python mle-project-challenge-2/create_model.py && deactivate

build-blue:
	docker build -t $(IMAGE):$(BLUE_TAG) --build-arg APP_VERSION=$(BLUE_TAG) .

build-green:
	docker build -t $(IMAGE):$(GREEN_TAG) --build-arg APP_VERSION=$(GREEN_TAG) .

up-blue: build-blue build-green
	IMAGE=$(IMAGE) BLUE_TAG=$(BLUE_TAG) GREEN_TAG=$(GREEN_TAG) $(COMPOSE) -f docker-compose.yml -f compose.live-blue.yml up -d

up-green: build-green build-blue
	IMAGE=$(IMAGE) BLUE_TAG=$(BLUE_TAG) GREEN_TAG=$(GREEN_TAG) $(COMPOSE) -f docker-compose.yml -f compose.live-green.yml up -d

promote-blue: up-blue

promote-green: up-green

scale-blue:
	@if [ -z "$$N" ]; then echo "Usage: make scale-blue N=3"; exit 1; fi
	IMAGE=$(IMAGE) BLUE_TAG=$(BLUE_TAG) GREEN_TAG=$(GREEN_TAG) $(COMPOSE) -f docker-compose.yml -f compose.live-blue.yml up -d --scale api_blue=$$N

scale-green:
	@if [ -z "$$N" ]; then echo "Usage: make scale-green N=3"; exit 1; fi
	IMAGE=$(IMAGE) BLUE_TAG=$(BLUE_TAG) GREEN_TAG=$(GREEN_TAG) $(COMPOSE) -f docker-compose.yml -f compose.live-green.yml up -d --scale api_green=$$N

down:
	$(COMPOSE) down

