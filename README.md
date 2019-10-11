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

### Common commands

Commands below will be used for both stacks (backend & workers):

| Command | Description |
|---------------|----------------|
| `make clean` | stop & remove all containers |
| `make up` | start containers |
| `make ps` | show all containers and there status |
| `make stop` | stop containers |

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
