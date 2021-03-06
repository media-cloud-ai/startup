# Startup with Media Cloud AI

## Requirements

To start the platform locally you've to install [docker](https://www.docker.com) & [docker-compose](https://docs.docker.com/compose/).
If you want to use storage services, you will need to install `openssl` too.


## Quick start

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

### Start Workers On-Demand

By default, all workers are started. But there's a way to start only wanted workers.
In `.env.workers` file there's an environment variable which list all workers to start: `WORKERS_TO_START`.
In the variable, you can list all workers that you want to start and you must generate the new worker `docker-compose.yml` using:

```bash
make workers-generate-cfg
```

**WARNING: If all workers are already started, you must stop them before regenerate the docker-compose file using `make workers-stop`.**

### EFK stack for monitoring

In order to perform an applicative monitoring (viz. save and access the logs of the docker containers), an EFK (Elasticsearch-Fluentd-Kibana) stack is used. A complete description on it is placed in [monitoring](monitoring/README.md) folder.

### Enabling/Disabling of features

It is possible to enable or disable features via the `.env` file :
  - The EFK stack for monitoring is bind to the `EFK=true|false` environment variable.
  - Environment setup for launching the Backend from startup or from the [ex_backend](https://github.com/media-cloud-ai/ex_backend) repo is bind to the `BACKEND_TYPE=startup|dev` environment variable.

## Domains

### Configuration

Now, you must update your `/etc/hosts` file by adding the following domains with their respectives docker's IP (`make ip` to show containers's IPs):

* local.backend.media-cloud.ai
* local.minio.media-cloud.ai
* local.rabbitmq.media-cloud.ai
* local.kibana.media-cloud.ai

### URLs

| Namespace | Service   | URL |
|-----------|-----------|-----|
| Backbone  | RabbitMQ  | [http://local.rabbitmq.media-cloud.ai:15672](http://local.rabbitmq.media-cloud.ai:15672) |
| Backend   | Backend   | [http://local.backend.media-cloud.ai](http://local.backend.media-cloud.ai) |
| Storage   | Minio     | [https://local.minio.media-cloud.ai:9000](https://local.minio.media-cloud.ai:9000) |
| Storage   | Nginx VOD | [http://local.nginx-vod-module.media-cloud.ai](http://local.nginx-vod-module.media-cloud.ai) |
| EFK       | Kibana    | [http://local.kibana.media-cloud.ai:5601](http://local.kibana.media-cloud.ai:5601) |

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
| `make backend-ps` | show all containers and there status |
| `make backend-stop` | stop containers |

### Workers commands

Commands below will be used for only for the workers stack:

| Command | Description |
|---------------|----------------|
| `make workers-clean` | stop & remove all containers |
| `make workers-up` | start containers |
| `make workers-ps` | show all containers and there status |
| `make workers-stop` | stop containers |

### Storage commands

Commands below will be used for only for the workers stack:

| Command | Description |
|---------------|----------------|
| `make storage-clean` | stop & remove all containers |
| `make storage-up` | start containers |
| `make storage-ps` | show all containers and there status |
| `make storage-stop` | stop containers |


## Credentials

### Storage

In order to allow the workers to access the storage endpoints, here are the default credential values that should be set into the backend interface (see the `.env.storage` file content to get the `MINIO_ACCESS_KEY`, `MINIO_SECRET_KEY`, `FTP_ACCESS_USER` and `FTP_ACCESS_PASSWORD` values to set):

 * `S3_SECRET`: `{"type":"s3","hostname":"http://minio:9000","access_key_id":"mediacloudai","secret_access_key":"mediacloudai","bucket":"bucket","region":"us-east-1"}`
 * `HTTP_SECRET`: `{"type":"http","endpoint":"http://http_nginx"}`
 * `FTP_SECRET`: `{"type":"ftp","hostname":"ftp_vsftpd","port":21,"secure":false,"username":"mediacloudai","password":"mEd1aCl0uda1","prefix":"/data"}`
