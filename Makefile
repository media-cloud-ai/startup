PROJECT_NAME=mediacloudai

include .env
include .env.backend
include .env.workers

export	# This will make all variables defined in envfile to becomes environment variables.

include scripts/colors.make

docker-compose-backbone = docker-compose -f backbone/docker-compose.yml -p $(PROJECT_NAME)_backbone
docker-compose-backend = docker-compose -f backend/docker-compose.yml -p $(PROJECT_NAME)_backend
docker-compose-workers = docker-compose -f workers/docker-compose.yml -p $(PROJECT_NAME)_workers

##############
### COMMON ###
##############

clean: backend-clean workers-clean backbone-clean
	@docker network rm mediacloudai_global

init:
	@$(eval NETWORK=$(shell docker network list --filter name=^mediacloudai_global$$ --no-trunc --format '{{.Name}}'))	
	@[ "${NETWORK}" ] || docker network create mediacloudai_global 1>/dev/null

ip:
	@$(call cecho,$(GREEN_COLOR),"GATEWAY mediacloudai_global: $(shell docker network inspect -f '{{range .IPAM.Config}}{{.Gateway}}{{end}}' mediacloudai_global)")
	@for CONTAINER in $(shell docker ps -a --format '{{.Names}}' -f NAME=${PROJECT_NAME}); do \
	  echo "$$CONTAINER"; \
	  echo "\t$$(docker inspect -f '{{range $$n, $$conf := .NetworkSettings.Networks}} {{$$conf.IPAddress}}#{{$$n}}\n\t{{end}}' $$CONTAINER)" | column -t -s "#"; \
	  echo " "; \
	done

ps: backend-ps workers-ps backbone-ps

up: backend-up workers-up ip

stop: backend-stop workers-stop backbone-stop

################
### BACKBONE ###
################

backbone-clean:
	@$(call displayheader,$(CYAN_COLOR),"BACKBONE CLEANING")
	@${docker-compose-backbone} down -v --remove-orphans --rmi local
	@echo

backbone-ps:
	@$(call displayheader,$(CYAN_COLOR),"BACKBONE SHOWING CONTAINERS")
	@$(docker-compose-backbone) ps
	@echo

backbone-stop: ## [container=] ## (Re-)Stop containers
	@$(call displayheader,$(CYAN_COLOR),"BACKBONE STOPING")
	@$(docker-compose-backbone) stop
	@echo

backbone-up: init ## [container=] ## (Re-)Create and start containers
	@$(call displayheader,$(CYAN_COLOR),"BACKBONE STARTING")
	@$(docker-compose-backbone) up -d --remove-orphans
	@echo

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

backend-up: backbone-up ## [container=] ## (Re-)Create and start containers
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

workers-up: init backbone-up ## [container=] ## (Re-)Create and start containers
	@$(call displayheader,$(CYAN_COLOR),"WORKERS STARTING")
	@$(docker-compose-workers) up -d --remove-orphans
	@echo
