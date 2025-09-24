# Sound Realty ML APIs
API serving Proof-of-Concept for Sound Realty

## Description

Sound Realty, of the Seattle area, has developed a basic machine learning (ML) model to estimate the value of propeties.  The folks at Sound are impressed with the proof of concept and would now like to use this model to streamline their business.

Our job is to create a REST endpoint that serves up model predictions for new data, and to provide guidance on how they could improve the model.



## Key Features

A lightweight Flask API served by Gunicorn, containerized with Docker, fronted by Traefik for:
- Sound Realty Housing Price Predictor served as a REST API
- Option to re-train new price predicion model
- Horizontal scaling (multiple replicas)
- Nearly-zero-downtime blue/green deployments
- Health and readiness endpoints
- Traefik dashboard
- Unit tests for API endpoints (pytest)


## Requirements

* python >= 3.9
* pip
* make
* docker
* curl


## Quickstart

```bash
# 1) Train and install model
make train-venv
make train-model
make load-model

# 2) Run tests
make venv
make tests

# 3) Build images
make build-blue BLUE_TAG=0.1.0
make build-green GREEN_TAG=0.2.0

# 4) Bring up stack with BLUE live
make up-blue BLUE_TAG=0.1.0 GREEN_TAG=0.2.0

# 5) Check endpoints
curl http://localhost/healthz
curl http://localhost/api/hello
curl http://localhost/version

# 5b) Shadow endpoints for validation
curl http://localhost/shadow/green/healthz
curl http://localhost/shadow/green/version

# 6) Test prediction endpoint with unseen data
python api_usage_example.py
# (Control-C to quit)
```

## Training a new model

Training is done in a separate environment than that used by the API server.

First, create and start the environment with:
```
make train-venv
source .train_venv/bin/activate
```
Then, run the script which creates the model:
```
python mle-project-challenge-2/create_model.py
```
Deactivate with:
```
deactivate
```
See [Sound Realty README](mle-project-challenge-2/README.md) for model creation details.

## Install the new model into Docker for deployment

Newly trained models are saved within the `mle-project-challenge-2/model` directory.

Move them into place for deployment in Docker containers with:
```
mkdir -p app/model
cp mle-project-challenge-2/model/model.pkl app/model/model.pkl
cp mle-project-challenge-2/model/model_features.json app/model/model_features.json
cp mle-project-challenge-2/data/zipcode_demographics.csv app/model/zipcode_demographics.csv
```

Increment the model version number for use in the next deployment.  To see all versions of the deployment image currently on your system, use docker and read the "TAG" column:
```
docker image ls
```



## Serving the model as an API via Docker Compose

### Design  (Traefik + Blue/Green):

We use Traefik as a reverse proxy & load balancer in order to implement nearly-zero downtime for new deployments as well as horizontal scaling:

* Traefik runs in one Docker container and discovers other containers via Docker labels.

* This sytem uses two app services:

    * `api_blue` and `api_green` both contain Gunicorn, Flask, and the ML model.
    * These could contain different versions of the ML model, or different endpoints.
    * They will have different Docker image tags, if they contain different code.

* Only one is live at a time. The other is reachable at a shadow path for validation:

    * When blue is live: `/` → blue, `/shadow/green` → green
    * When green is live: `/` → green, `/shadow/blue` → blue

* Docker compose enables us to scale a live service horizontally without downtime.

* We can promote green to live (or rollback) with a single override file: Traefik hot-reloads and swaps routes instantly.


### How zero downtime works here

Traefik continuously serves traffic to the container with the api router.
To promote green: bring up the stack with `make promote-green`. Traefik swaps routing to green as soon as the green container is healthy. Blue continues running (and is reachable at /shadow/blue) until you remove it.


### Scaling

Scale the live service without downtime:

```
# If BLUE is live:
make scale-blue N=3

# If GREEN is live:
make scale-green N=3
```

### Zero-Downtime Promotion

1. Build or pull the new image into GREEN, being sure to increment the TAG number:

```
make build-green GREEN_TAG=0.2.0
```

2. Bring the stack up (blue live, green shadow) if not already:

```
make up-blue BLUE_TAG=0.1.0 GREEN_TAG=0.2.0
```

3. Validate GREEN at:
```
curl http://localhost/shadow/green/healthz
curl http://localhost/shadow/green/version
```

4. Promote GREEN to live (zero downtime):
```
make promote-green BLUE_TAG=0.1.0 GREEN_TAG=0.2.0
```

5. (Optional) Scale GREEN:
```
make scale-green N=4
```

Rollback is symmetric: `make promote-blue`.

### Notes

* Traefik watches Docker events—router updates are applied instantly.
* Health checks use `/readyz` for load balancer health and `/healthz` for liveness.
* You can keep both blue and green running after promotion for fast rollback, or `docker compose rm` the old one.
* For canary percentages, we can add a Traefik weighted service config on request.


## Monitoring with Traefik dashboard

The traefik load balancer has a dashboard visualization which can be used for monitoring the services and routers.  Access the dashboard from a browser on the host machine at:
```
http://localhost:8080/dashboard/
```

## Acknowledgement regarding AI Usage:

The initial version of code for this project was generated using Microsoft Copilot / GPT-5.

I used two prompts for the initial code.

### First prompt:

Help me design a lightweight flask-based API server in a Docker container.  The service that we design must be able to be scaled up or down without stopping the service.  New versions of the service must be able to be deployed without stopping the service.  Include unit testing for the important components.

### Second prompt:

Let's use the Docker Compose option, and leave out Kubernetes.  Show me the whole project structure in this case.

## Version History

Initial release: v.0.1.0 2025.09.24

## Copyright

Copyright (2025) - Robert Knight - All Rights Reserved

