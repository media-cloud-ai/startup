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

## Traefik

If you don't want be worried about update `/etc/hosts` file each time containers IP changed, you can use Traefik.
Traefik can be used as container discovery and it allows to link an host to the container.

Here the list of configured hosts:

* backend.media-cloud-ai
* minio.media-cloud.ai

Now, you must update your `/etc/hosts` file by adding:
```
127.0.0.1	backend.media-cloud.ai minio.media-cloud.ai
```
### Installation

The simpliest way to install Traefik in local station is to use Docker.

```
docker run --name traefik -d -p 8080:8080 -p 80:80 -v $PWD/traefik.toml:/etc/traefik/traefik.toml -v /var/run/docker.sock:/var/run/docker.sock traefik:1.7.18-alpine --api --docker
```

## DnsMasq

Now, if you don't want touch you `/etc/hosts` file, you can install `dnsmasq` a light DNS server.

```bash
sudo apt-get install -y dnsmasq
sudo sh -c "echo address=/media-cloud.ai/127.0.0.1 > /etc/dnsmasq.d/media-cloud.ai.conf"
sudo /etc/init.d/dnsmasq restart
```

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
