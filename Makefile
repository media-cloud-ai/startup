PROJECT_NAME=mediacloudai

include .env
include .env.backend
include .env.workers

export	# This will make all variables defined in envfile to becomes environment variables.

include scripts/colors.make

docker-compose-backend = docker-compose -f backbone/docker-compose.yml -f backend/docker-compose.yml -p $(PROJECT_NAME)_backend
docker-compose-workers = docker-compose -f backbone/docker-compose.yml -f workers/docker-compose.yml -p $(PROJECT_NAME)_workers

##############
### COMMON ###
##############

clean: backend-clean workers-clean

init:
	@docker network create global

ps: backend-ps workers-ps

up: backend-up workers-up ps

stop: backend-stop workers-stop

###############
### BACKEND ###
###############

backend-clean:
	@$(call displayheader,$(CYAN_COLOR),"BACKEND CLEANING")
	@${docker-compose-backend} down -v --remove-orphans --rmi local
	@echo

backend-ps:
	@$(call displayheader,$(CYAN_COLOR),"BACKEND SHOWING CONTAINERS")
	@$(docker-compose-backend) ps
	@echo

backend-stop: ## [container=] ## (Re-)Stop containers
	@$(call displayheader,$(CYAN_COLOR),"BACKEND STOPING")
	@$(docker-compose-backend) stop
	@echo

backend-up: ## [container=] ## (Re-)Create and start containers
	@$(call displayheader,$(CYAN_COLOR),"BACKEND STARTING")
	@$(docker-compose-backend) up -d --remove-orphans
	@echo

backend-pg_dump: ## [container=] ## (Re-)Create and start containers
	@$(docker-compose-backend) exec -T database pg_dump -U${DATABASE_USERNAME} ${DATABASE_NAME} > ${DATABASE_NAME}.sql

###############
### WORKERS ###
###############

workers-clean:
	@$(call displayheader,$(CYAN_COLOR),"WORKERS CLEANING")
	@${docker-compose-workers} down -v --remove-orphans --rmi local
	@echo

workers-ps:
	@$(call displayheader,$(CYAN_COLOR),"WORKERS SHOWING CONTAINERS")
	@$(docker-compose-workers) ps
	@echo

workers-stop: ## [container=] ## (Re-)Create and start containers
	@$(call displayheader,$(CYAN_COLOR),"WORKERS STOPING")
	@$(docker-compose-workers) stop
	@echo

workers-up: ## [container=] ## (Re-)Create and start containers
	@$(call displayheader,$(CYAN_COLOR),"WORKERS STARTING")
	@$(docker-compose-workers) up -d --remove-orphans
	@echo
