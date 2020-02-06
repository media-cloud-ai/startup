PROJECT_NAME=mediacloudai

include .env.docker
include .env
include .env.storage
include .env.backend
include .env.workers

export	# This will make all variables defined in envfile to becomes environment variables.

include scripts/colors.make

EFK-COMPOSE=`[ $(EFK) = false ] && echo "" || echo "-f monitoring/docker-compose.yml"`

docker-compose-backbone = docker-compose -f backbone/docker-compose.yml $(EFK-COMPOSE) -p $(PROJECT_NAME)_backbone
docker-compose-backend = docker-compose -f backend/docker-compose.yml -p $(PROJECT_NAME)_backend
docker-compose-workers = docker-compose -f workers/docker-compose.yml -p $(PROJECT_NAME)_workers
docker-compose-storage = docker-compose -f storage/docker-compose.yml -p $(PROJECT_NAME)_storage
docker-compose-vault = docker-compose -f vault/docker-compose.yml -p $(PROJECT_NAME)_vault

##############
### COMMON ###
##############

%-clean:
	$(eval ns := $(shell echo $(*) | tr  '[:lower:]' '[:upper:]'))
	@$(call displayheader,$(CYAN_COLOR),"${ns} CLEANING")
ifneq ($(docker-compose-$*), "")
	$(docker-compose-$*) down -v --remove-orphans --rmi local
else
	echo "Unknown '$*'"
endif
	@echo

%-ps:
	$(eval ns := $(shell echo $(*) | tr  '[:lower:]' '[:upper:]'))
	@$(call displayheader,$(CYAN_COLOR),"${ns} SHOWING CONTAINERS")
ifneq ($(docker-compose-$*), "")
	$(docker-compose-$*) ps
else
	echo "Unknown '$*'"
endif
	@echo

%-stop:
	$(eval ns := $(shell echo $(*) | tr  '[:lower:]' '[:upper:]'))
	@$(call displayheader,$(CYAN_COLOR),"${ns} STOPPING")
ifneq ($(docker-compose-$*), "")
	@$(docker-compose-$*) stop
else
	echo "Unknown '$*'"
endif
	@echo

%-status:
	@if [ "$(docker ps -q -f name=$*)" != ""]; then \
		echo "Known '$*'"; \
	else \
		echo "Unknown '$*'"; \
	fi
	@echo
	

%-up: init
	$(eval ns := $(shell echo $(*) | tr  '[:lower:]' '[:upper:]'))
	@if [ "$*" = "workers" ] || [ "$*" = "vault" ]; then \
		make -s $*-generate-cfg; \
  fi
	@$(call displayheader,$(CYAN_COLOR),"${ns} STARTING")
ifneq ($(docker-compose-$*), "")
	@$(docker-compose-$*) up -d --remove-orphans
else
	@echo "Unknown '$*'"
endif
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

ps: backbone-ps backend-ps workers-ps backbone-ps storage-ps vault-ps

up: init backbone-up backend-up workers-up generate-certs storage-up vault-up ip

stop: backbone-stop backend-stop workers-stop backbone-stop storage-stop vault-stop

status:
	@for CONTAINER in $(shell docker ps --format '{{.Names}}' -f NAME=${PROJECT_NAME}); do \
	  docker exec $$CONTAINER env | grep -oP 'AMQP|DATABASE' | uniq | while read -r SERVICE; do \
	  	docker cp ./scripts/test_container.sh $$CONTAINER:/; \
	  	docker exec $$CONTAINER bash -c "chmod +x /test_container.sh"; \
	  	echo -n "$$CONTAINER \t to $$SERVICE ... " ; \
		status="$$(docker exec $$CONTAINER /test_container.sh $${SERVICE} && echo 0 || echo 1)"; \
		if [ $$status = "0" ]; then \
			echo "\033[32mPass\e[0m"; \
		else \
			echo "\033[31mFail\e[0m"; \
		fi; \
	  done \
	done

# port= $(SERVICE)_PORT \
# echo $$CONTAINER connection to $$SERVICE with $$HOSTNAME; \
# docker exec $$CONTAINER printenv $${SERVICE}_HOSTNAME $${SERVICE}_PORT | xargs | awk '{gsub(/\s+/,":");}1'| xargs -n1 ping -c 1 |  echo $?; \
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
ifeq ($(EFK), false)
	./scripts/generate_workers_cfg.sh $(BACKEND_TYPE)
else
	./scripts/generate_workers_cfg.sh $(BACKEND_TYPE) -EFK
endif

###############
###  VAULT  ###
###############

vault-generate-cfg:
	@$(call displayheader,$(CYAN_COLOR),"${ns} SETUP VAULT")
	@if [ ! -d "vault/vault/data" ]; then mkdir vault/vault/data; fi
	@if [ ! -d "vault/vault/logs" ]; then mkdir vault/vault/logs; fi
	@if [ ! -d "vault/vault/policies" ]; then mkdir vault/vault/policies; fi


###############
### STORAGE ###
###############

check-openssl:
	@$(eval openssl-bin := $(shell which openssl 2>/dev/null))
ifeq ($(openssl-bin), "")
	echo "openssl not found"
	exit -1
endif
	@echo "openssl found in ${openssl-bin}"
	@echo

generate-certs: check-openssl
	@rm -rf certs/
	@mkdir certs/
	@$(call displayheader, $(CYAN_COLOR), "Generate certificate")
	@openssl req -new -newkey rsa:2048 -days 365 -nodes -x509 -keyout certs/private.key -out certs/public.crt -subj "/C=FR/ST=Paris/L=Paris/O=WorldCompany/OU=mediacloudai/CN=*.media-cloud.ai"
