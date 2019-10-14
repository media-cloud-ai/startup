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

## Domains

### Configuration

Now, you must update your `/etc/hosts` file by adding the following domains with their respectives docker's IP (`make ip` to show containers's IPs):

* local.backend.media-cloud.ai 
* local.minio.media-cloud.ai
* local.rabbitmq.media-cloud.ai

### URLs

| Namespace | Service   | URL |
|-----------|-----------|-----|
| Backbone  | RabbitMQ  | [http://local.rabbitmq.media-cloud.ai:15672](http://local.rabbitmq.media-cloud.ai:15672) |
| Backend   | Backend   | [http://local.backend.media-cloud.ai](http://local.backend.media-cloud.ai) |
| Storage   | Minio     | [https://local.minio.media-cloud.ai:9000](https://local.minio.media-cloud.ai:9000) |
| Storage   | Nginx VOD | [http://local.nginx-vod-module.media-cloud.ai](http://local.nginx-vod-module.media-cloud.ai) |

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
