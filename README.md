# Sound Realty ML APIs
API serving Proof-of-Concept for Sound Realty

# Flask API (Docker Compose + Traefik, Blue/Green & Scaling)

A lightweight Flask API served by Gunicorn, containerized with Docker, fronted by Traefik for:
- Horizontal scaling (multiple replicas)
- Zero-downtime blue/green deployments
- Health and readiness endpoints
- Unit tests (pytest)

## Quickstart

```bash
# 1) Run tests
python -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt
pytest -q --cov=app
# 2) Build images
make build-blue BLUE_TAG=0.1.0
make build-green GREEN_TAG=0.2.0

# 3) Bring up stack with BLUE live
make up-blue BLUE_TAG=0.1.0 GREEN_TAG=0.2.0

# 4) Check endpoints
curl http://localhost/healthz
curl http://localhost/api/hello
curl http://localhost/version

# Shadow endpoints for validation
curl http://localhost/shadow/green/healthz
curl http://localhost/shadow/green/version
```

## Transparency regarding AI Usage:

The initial version of code for this project was generated using Microsoft Copilot / GPT-5.

I used two prompts for the initial code.

### First prompt:

Help me design a lightweight flask-based API server in a Docker container.  The service that we design must be able to be scaled up or down without stopping the service.  New versions of the service must be able to be deployed without stopping the service.  Include unit testing for the important components.

### Second prompt:

Let's use the Docker Compose option, and leave out Kubernetes.  Show me the whole project structure in this case.

## Notes provided by Copilot:

### Docker Compose (Traefik + Blue/Green)
Design:

* Traefik (reverse proxy & load balancer) discovers containers via Docker labels.

* Two app services:

    * `api_blue` and `api_green`

* Only one is live at / at a time. The other is reachable at a shadow path for validation:

    * When blue is live: `/` → blue, `/shadow/green` → green
    * When green is live: `/` → green, `/shadow/blue` → blue

* Scale a live service horizontally without downtime.

* Promote green to live (or rollback) with a single override file—Traefik hot-reloads and swaps routes instantly.


### How zero downtime works here

Traefik continuously serves traffic to the container with the api router.
To promote green: bring up the stack with `compose.live-green.yml`. Traefik swaps routing to green as soon as the green container is healthy. Blue continues running (and is reachable at /shadow/blue) until you remove it.


### Scaling

Scale the live service without downtime:

```
# If BLUE is live:
make scale-blue N=3

# If GREEN is live:
make scale-green N=3
```

### Zero-Downtime Promotion

1. Build or pull the new image into GREEN:

```
make build-green GREEN_TAG=0.2.0
```

2. Bring the stack up (blue live, green shadow) if not already:

```
make up-blue BLUE_TAG=0.1.0 GREEN_TAG=0.2.0
```

3. Validate GREEN at:
```
http://localhost/shadow/green/healthz
http://localhost/shadow/green/version
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

### How to Use

1. Install and test locally
```
bash
python -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt
pytest -q --cov=app
```

2. Build Images
```
make build-blue BLUE_TAG=0.1.0
make build-green GREEN_TAG=0.2.0
```

3. Run with blue live
```
make up-blue BLUE_TAG=0.1.0 GREEN_TAG=0.2.0
```

4. Scale live service
```
make scale-blue N=3
```

5. Promote green
```
make promote-green BLUE_TAG=0.1.0 GREEN_TAG=0.2.0
```

## Copyright

Copyright (2025) - Robert Knight - All Rights Reserved

