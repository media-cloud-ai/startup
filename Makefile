PROJECT_NAME=mediacloudai

include .env.docker
include .env
include .env.backend
include .env.workers

export	# This will make all variables defined in envfile to becomes environment variables.

include scripts/colors.make

EFK-COMPOSE=`[ $(EFK) = false ] && echo "" || echo "-f monitoring/docker-compose.yml"`

docker-compose-backbone = docker-compose -f backbone/docker-compose.yml $(EFK-COMPOSE) -p $(PROJECT_NAME)_backbone
docker-compose-backend = docker-compose -f backend/docker-compose.yml -p $(PROJECT_NAME)_backend
docker-compose-workers = docker-compose -f workers/docker-compose.yml -p $(PROJECT_NAME)_workers
docker-compose-storage = docker-compose -f storage/docker-compose.yml -p $(PROJECT_NAME)_storage

##############
### COMMON ###
##############

%-clean:
	$(eval ns := $(shell echo $(*) | tr  '[:lower:]' '[:upper:]'))
	@$(call displayheader,$(CYAN_COLOR),"${ns} CLEANING")
	@if [ "$(docker-compose-$*)" != "" ]; then \
		$(docker-compose-$*) down -v --remove-orphans --rmi local; \
	else \
		echo "Unknown '$*'"; \
	fi
	@echo

%-ps:
	$(eval ns := $(shell echo $(*) | tr  '[:lower:]' '[:upper:]'))
	@$(call displayheader,$(CYAN_COLOR),"${ns} SHOWING CONTAINERS")
	@if [ "$(docker-compose-$*)" != "" ]; then \
		$(docker-compose-$*) ps; \
	else \
		echo "Unknown '$*'"; \
	fi
	@echo

%-stop:
	$(eval ns := $(shell echo $(*) | tr  '[:lower:]' '[:upper:]'))
	@$(call displayheader,$(CYAN_COLOR),"${ns} STOPPING")
	@if [ "$(docker-compose-$*)" != "" ]; then \
		$(docker-compose-$*) stop; \
	else \
		echo "Unknown '$*'"; \
	fi
	@echo

%-up:
	@$(eval check_output := `make -n $*-generate-cfg 2>&1 | head -1 | egrep \^make`)
	@if [ "${check_output}" == "" ]; then \
		make -s $*-generate-cfg; \
	fi
	$(eval ns := $(shell echo $(*) | tr  '[:lower:]' '[:upper:]'))
	@$(call displayheader,$(CYAN_COLOR),"${ns} STARTING")
	@if [ "$(docker-compose-$*)" != "" ]; then \
		$(docker-compose-$*) up -d --remove-orphans; \
	else \
		echo "Unknown '$*'"; \
	fi
	@echo

clean: backend-clean workers-clean backbone-clean storage-clean
	@docker network rm mediacloudai_global
	@rm -rf certs/

init:
	@$(call displayheader,$(CYAN_COLOR),"INIT")
	@$(eval NETWORK=$(shell docker network list --filter name=^mediacloudai_global$$ --no-trunc --format '{{.Name}}'))
	@[ "${NETWORK}" ] || docker network create mediacloudai_global 1>/dev/null
	@$(call cecho,$(GREEN_COLOR), "Network mediacloudai_global created....")
	@echo

ip:
	@$(call cecho,$(GREEN_COLOR),"GATEWAY mediacloudai_global: $(shell docker network inspect -f '{{range .IPAM.Config}}{{.Gateway}}{{end}}' mediacloudai_global)")
	@for CONTAINER in $(shell docker ps -a --format '{{.Names}}' -f NAME=${PROJECT_NAME}); do \
		echo "$$CONTAINER"; \
		echo "\t$$(docker inspect -f '{{range $$n, $$conf := .NetworkSettings.Networks}} {{$$conf.IPAddress}}#{{$$n}}\n\t{{end}}' $$CONTAINER)" | column -t -s "#"; \
		echo " "; \
	done

ps: backbone-ps backend-ps workers-ps backbone-ps storage-ps

up: init backbone-up backend-up workers-up generate-certs storage-up ip

stop: backbone-stop backend-stop workers-stop backbone-stop storage-stop

################
### BACKBONE ###
################

###############
### BACKEND ###
###############

backend-pg_dump: ## [container=] ## (Re-)Create and start containers
	@$(docker-compose-backend) exec -T database pg_dump -U${DATABASE_USERNAME} ${DATABASE_NAME} > ${DATABASE_NAME}.sql

###############
### WORKERS ###
###############

workers-generate-cfg:
	@$(call displayheader, $(CYAN_COLOR), "Generate docker-compose.yml for workers")
	@if [ $(EFK) = false ]; then \
		./scripts/generate_workers_cfg.sh $(BACKEND_TYPE); \
	else \
		./scripts/generate_workers_cfg.sh $(BACKEND_TYPE) -EFK; \
	fi

###############
### STORAGE ###
###############

check-openssl:
	@$(eval openssl-bin := $(shell which openssl 2>/dev/null))
	@if [ "${openssl-bin}" = "" ]; then \
		echo "openssl not found"; \
		exit -1; \
	fi
	@echo "openssl found in ${openssl-bin}"
	@echo

generate-certs: check-openssl
	@rm -rf certs/
	@mkdir certs/
	@$(call displayheader, $(CYAN_COLOR), "Generate certificate")
	@openssl req -new -newkey rsa:2048 -days 365 -nodes -x509 -keyout certs/private.key -out certs/public.crt -subj "/C=FR/ST=Paris/L=Paris/O=WorldCompany/OU=mediacloudai/CN=*.media-cloud.ai"
