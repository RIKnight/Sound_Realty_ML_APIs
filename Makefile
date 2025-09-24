APP_NAME?=flask-api
IMAGE?=dataknight/$(APP_NAME)
BLUE_TAG?=0.1.0
GREEN_TAG?=0.2.0

COMPOSE=docker compose

.PHONY: help venv train-venv tests load-model clean
help:
	@echo "Targets:"
	@echo "  venv             Create Flask venv and install deps"
	@echo "  train-venv       Create scikit-learn venv and install deps"
	@echo "  tests            Run unit tests in Flask venv"
	@echo "  train-model      Train a new model in training venv"
	@echo "  load-model       Load model into app for serving"
	@echo "  build-blue       Build blue image"
	@echo "  build-green      Build green image"
	@echo "  up-blue          Start Traefik + blue live"
	@echo "  up-green         Start Traefik + green live"
	@echo "  promote-blue     Switch live traffic to blue"
	@echo "  promote-green    Switch live traffic to green"
	@echo "  scale-blue N=?   Scale blue to N replicas (when blue is live)"
	@echo "  scale-green N=?  Scale green to N replicas (when green is live)"
	@echo "  down             Stop all services (keeps images)"
	@echo "  clean            Remove built directories"

venv:
	python -m venv .venv && . .venv/bin/activate && pip install -r requirements.txt

train-venv:
	python -m venv .train_venv && . .train_venv/bin/activate && pip install -r training_requirements.txt

tests: venv
	source .venv/bin/activate && pytest -q --cov=app

train-model: train-venv
	source .train_venv/bin/activate && cd mle-project-challenge-2 && python create_model.py

load-model:
	mkdir -p app/model
	cp mle-project-challenge-2/model/model.pkl app/model/model.pkl
	cp mle-project-challenge-2/model/model_features.json app/model/model_features.json
	cp mle-project-challenge-2/data/zipcode_demographics.csv app/model/zipcode_demographics.csv

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

clean:
	rm -rf .venv .train_venv app/model mle-project-challenge-2/model
