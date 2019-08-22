PROJECT_NAME=mediacloudai

docker-compose-backend = docker-compose -f backend/docker-compose.yml -p $(PROJECT_NAME)_backend
docker-compose-workers = docker-compose -f workers/docker-compose.yml -p $(PROJECT_NAME)_workers

backend-up: ## [container=] ## (Re-)Create and start containers
	@$(docker-compose-backend) up -d --remove-orphans

backend-stop: ## [container=] ## (Re-)Stop containers
	@$(docker-compose-backend) stop

backend-ps:
	@$(docker-compose-backend) ps

workers-up: ## [container=] ## (Re-)Create and start containers
	@$(docker-compose-workers) up -d --remove-orphans

workers-stop: ## [container=] ## (Re-)Create and start containers
	@$(docker-compose-workers) stop

workers-ps:
	@$(docker-compose-workers) ps
