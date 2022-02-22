# Startup with Media Cloud AI

## Requirements

To install the MediaCloudAI stack, you will need to first install several third party components.
The versions indicated in the documentation are the version tested to be compatible. Older versions might be compatible but have not been tested.

If you want to use storage services, you will need to install `openssl` too.

### Docker

- [Docker](https://www.docker.com) 20.10+

### Docker Compose

- [Docker Compose](https://docs.docker.com/compose/) 1.24+

### yq

- [yq](https://github.com/mikefarah/yq) 4.20+


## Quick start

First launch the setup script:
```bash
./setup.sh
```

To quickly start locally the plateform this is very easy:
```bash
make up
```

This command will launch all needed containers.
With default values, the backend UI could be accessed with the url: [http://localhost:8080](http://localhost:8080)

To stop the plateform without removing containers:
```bash
make stop
```

If you want to stop the plateform and remove containers:
```bash
make clean
```

## Adding new workers

The workers can be specified in two files : `opensource.workers.yml` and `private.workers.yml`.
The structure is depicted as an example in `opensource.workers.yml`.
The available keywords are (`*` if mandatory):
- `name*` for the worker name. The job queue in RabbitMQ will be constructed after this name, namely by `job_${NAME}`.
- `image*` for the image name or `build*` for a path containing a Dockerfile.
- `count*` for the number of workers to be created.
- `environment` to specify custom environment variables.
- `vault` to specify whether the worker needs to retrieve secrets for secret backend (Backend or Vault).
- `gpu` to specify whether the container needs to change runtime to `nvidia`. 

### Start Workers On-Demand

By default, all workers are started. But there's a way to start only wanted workers.
In `.env.workers` file there's an environment variable which list all workers to start: `WORKERS_TO_START`.

**WARNING: If all workers are already started, you must stop them before regenerate the docker-compose file using `make workers-stop`.**

### EFK stack for monitoring

In order to perform an applicative monitoring (viz. save and access the logs of the docker containers), an EFK (Elasticsearch-Fluentd-Kibana) stack is used. A complete description on it is placed in [monitoring](monitoring/README.md) folder.
A [Grafana](https://grafana.com/products/) instance is also instanciated as well as a [Prometheus](https://prometheus.io) server.

### Vault for keeping your secrets safe

In order to centralise your secrets, a Vault instance is used. A complete description of Vault and its usage is placed in [vault](vault/README.md) folder.

### Enabling/Disabling of features

It is possible to enable or disable features via the `.env.*` files :
  - The EFK stack for monitoring is bound to the `EFK=true|false` environment variable in `.env`.
  - The logging level of the workers is bound to the `LOG_LEVEL=info|warn|error|debug` environment variable in `.env.workers`.

## Domains

### Configuration

Now, you must update your `/etc/hosts` file by adding the following domains with their respectives docker's IP (`make ip` to show containers's IPs):

* local.backend.media-cloud.ai
* local.minio.media-cloud.ai
* local.rabbitmq.media-cloud.ai
* local.kibana.media-cloud.ai
* local.grafana.media-cloud.ai
* local.prometheus.media-cloud.ai
* local.vault.media-cloud.ai

### URLs

| Namespace | Service   | URL |
|-----------|-----------|-----|
| Backbone  | RabbitMQ  | [http://local.rabbitmq.media-cloud.ai:15672](http://local.rabbitmq.media-cloud.ai:15672) |
| Backend   | Backend   | [http://local.backend.media-cloud.ai](http://local.backend.media-cloud.ai) |
| Storage   | Minio     | [https://local.minio.media-cloud.ai:9000](https://local.minio.media-cloud.ai:9000) |
| Storage   | Nginx VOD | [http://local.nginx-vod-module.media-cloud.ai](http://local.nginx-vod-module.media-cloud.ai) |
| EFK       | Kibana    | [http://local.kibana.media-cloud.ai:5601](http://local.kibana.media-cloud.ai:5601) |
| Grafana   | Grafana   | [http://local.grafana.media-cloud.ai:3000](http://local.grafana.media-cloud.ai:3000) |
| Prometheus| Prometheus| [http://local.prometheus.media-cloud.ai:9090](http://local.prometheus.media-cloud.ai:9090) |
| Vault     | Vault     | [http://local.vault.media-cloud.ai:8200](http://local.vault.media-cloud.ai:8200) |

### Common commands

Commands below will be used for both stacks (backend & workers):

| Command | Description |
|---------------|----------------|
| `make clean` | stop & remove all containers |
| `make up` | start containers |
| `make ps` | show all containers and there status |
| `make stop` | stop containers |
| `generate-certs` | generate self-signed TLS certificate for *.media-cloud.ai domain. |

### Backbone commands

Commands below will be used for only for the backend stack:

| Command | Description |
|---------------|----------------|
| `make backbone-clean` | stop & remove all containers |
| `make backbone-up` | start containers |
| `make backbone-ps` | show all containers and there status |
| `make backbone-stop` | stop containers |

### Backend commands

Commands below will be used for only for the backend stack:

| Command | Description |
|---------------|----------------|
| `make backend-clean` | stop & remove all containers |
| `make backend-up` | start containers |
| `make backend-ps` | show all containers and their status |
| `make backend-stop` | stop containers |

### Workers commands

Commands below will be used for only for the workers stack:

| Command | Description |
|---------------|----------------|
| `make workers-clean` | stop & remove all containers |
| `make workers-up` | start containers |
| `make workers-ps` | show all containers and their status |
| `make workers-stop` | stop containers |

### Storage commands

Commands below will be used for only for the storage stack:

| Command | Description |
|---------------|----------------|
| `make storage-clean` | stop & remove all containers |
| `make storage-up` | start containers |
| `make storage-ps` | show all containers and their status |
| `make storage-stop` | stop containers |

## Credentials

### Storage

In order to allow the workers to access the storage endpoints, here are the default credential values that should be set into the backend interface (see the `.env.storage` file content to get the `MINIO_ACCESS_KEY`, `MINIO_SECRET_KEY`, `FTP_ACCESS_USER` and `FTP_ACCESS_PASSWORD` values to set):

 * `S3_SECRET`: `{"type":"s3","hostname":"http://minio:9000","access_key_id":"mediacloudai","secret_access_key":"mediacloudai","bucket":"bucket","region":"us-east-1"}`
 * `HTTP_SECRET`: `{"type":"http","endpoint":"http://http_nginx"}`
 * `FTP_SECRET`: `{"type":"ftp","hostname":"ftp_vsftpd","port":21,"secure":false,"username":"mediacloudai","password":"mEd1aCl0uda1","prefix":"/data"}`

### Vault commands

Commands below will be used for only for the vault stack:

| Command | Description |
|---------------|----------------|
| `make vault-clean` | stop & remove all containers |
| `make vault-up` | start containers |
| `make vault-ps` | show all containers and their status |
| `make vault-stop` | stop containers |

## Troubleshooting

### IP address conflict

In case of IP address conflict, you need to add ipam configuration to three `docker-compose`:
- In `backbone/docker-compose.yml` in `networks.backbone`:
```yaml
ipam:
  config:
  - subnet: 192.168.202.0/24
```
- In `backend/docker-compose.yml.tpl` in `networks.backend`:
```yaml
ipam:
  config:
  - subnet: 192.168.201.0/24
```
- In `workers/docker-compose.yml.tpl` in `networks.workers`:
```yaml
ipam:
  config:
  - subnet: 192.168.203.0/24
```
