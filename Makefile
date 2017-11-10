# which service (from docker-compose.yml:services) to run commands agains
SERVICE ?=

BIND_ADDRESS ?= 127.0.0.1
PROJECT_NAME ?= monitoring_services

SUDO ?= sudo

EXEC_ARGS ?=
RUN_ARGS ?=
DOWN_ARGS ?= --remove-orphans
BUILD_ARGS ?=

COMPOSE_ENV = BIND_ADDRESS=$(BIND_ADDRESS)
COMPOSE_FILE_ARGS ?= -f $(CURDIR)/docker-compose.yml

ifeq ($(shell uname -s),Darwin)
XARGS_OPTS =
else
XARGS_OPTS = -r
endif

run: env-check
	$(COMPOSE_ENV) $(SUDO) docker-compose $(COMPOSE_FILE_ARGS) -p $(PROJECT_NAME) up -d $(RUN_ARGS)

logs: env-check
	$(COMPOSE_ENV) $(SUDO) docker-compose $(COMPOSE_FILE_ARGS) -p $(PROJECT_NAME) logs --tail=100 -f

stop: env-check
	$(COMPOSE_ENV) $(SUDO) docker-compose $(COMPOSE_FILE_ARGS) -p $(PROJECT_NAME) stop $(SERVICE)

restart: env-check
	$(COMPOSE_ENV) $(SUDO) docker-compose $(COMPOSE_FILE_ARGS) -p $(PROJECT_NAME) restart $(SERVICE)

clean: env-check
	- $(COMPOSE_ENV) $(SUDO) docker-compose $(COMPOSE_FILE_ARGS) -p $(PROJECT_NAME) down $(DOWN_ARGS)

influxdb: run
	$(COMPOSE_ENV) $(SUDO) docker-compose $(COMPOSE_FILE_ARGS) -p $(PROJECT_NAME) exec influxdb influx

mongo: run
	$(COMPOSE_ENV) $(SUDO) docker-compose $(COMPOSE_FILE_ARGS) -p $(PROJECT_NAME) exec mongo mongo

elasticsearch: run
	$(COMPOSE_ENV) $(SUDO) docker-compose $(COMPOSE_FILE_ARGS) -p $(PROJECT_NAME) exec elasticsearch bash

telegraf: run
	$(COMPOSE_ENV) $(SUDO) docker-compose $(COMPOSE_FILE_ARGS) -p $(PROJECT_NAME) exec telegraf bash

grafana: run
	$(COMPOSE_ENV) $(SUDO) docker-compose $(COMPOSE_FILE_ARGS) -p $(PROJECT_NAME) exec grafana bash

graylog: run
	$(COMPOSE_ENV) $(SUDO) docker-compose $(COMPOSE_FILE_ARGS) -p $(PROJECT_NAME) exec graylog bash

ps:
	$(COMPOSE_ENV) $(SUDO) docker-compose $(COMPOSE_FILE_ARGS) -p $(PROJECT_NAME) ps

env-check:
ifeq ($(shell uname -s),Darwin)
	ifconfig lo0 | grep -qF '$(BIND_ADDRESS)' || sudo ifconfig lo0 alias $(BIND_ADDRESS)
endif

# compatibility to pre docker-compose rules & aliases
$(RUN_IMAGE): run
$(BUILD_IMAGE): image
start: run
cli: bash
update: image clean run

# all is phony...
.PHONY: %
.DEFAULT: run
