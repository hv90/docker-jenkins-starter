# Variables
DOCKER_COMPOSE = docker-compose
CONTAINER_NAME = jenkins

JOB_NAME=commit%20and%20push%20to%20github
COMMIT_MESSAGE?=Atualizações automáticas pelo Jenkins
AGENT_NAME="agent node"
WORK_DIR= /var/jenkins_home/agent


# get environment variables from .env file
ifneq ("$(wildcard .env)","")
include .env
endif

# Makefile rules
build:
	$(DOCKER_COMPOSE) build

up:
	$(DOCKER_COMPOSE) up -d

up-and-build:	
	$(DOCKER_COMPOSE) up -d --build

down:
	$(DOCKER_COMPOSE) down

logs:
	$(DOCKER_COMPOSE) logs -f $(CONTAINER_NAME)

clean:
	$(DOCKER_COMPOSE) down -v  # Remove volumes

restart: down up

status:
	$(DOCKER_COMPOSE) ps

docker-bash:
	$(DOCKER_COMPOSE) exec $(CONTAINER_NAME) bash


jenkins-initial-admin-password:
	$(DOCKER_COMPOSE) exec $(CONTAINER_NAME) cat /var/jenkins_home/secrets/initialAdminPassword

jenkins-connect-agent-node:
	$(DOCKER_COMPOSE) exec $(CONTAINER_NAME) \
		sh -c "cd /var/jenkins_home/agent/ \
		&& curl -O ${JENKINS_URL}/jnlpJars/agent.jar \
		&& java -jar agent.jar -url ${JENKINS_URL}/ \
		-secret ${JENKINS_AGENT_SECRET} \
		-name 'agent node' -workDir '/var/jenkins_home/agent'"