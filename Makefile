# Variáveis
DOCKER_COMPOSE = docker-compose
CONTAINER_NAME = jenkins

# Regras do Makefile
all: build up

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

docker-bash:
	$(DOCKER_COMPOSE) exec $(CONTAINER_NAME) bash

# Comando para acessar a senha inicial de admin no Jenkins
initial-admin-password:
	$(DOCKER_COMPOSE) exec $(CONTAINER_NAME) cat /var/jenkins_home/secrets/initialAdminPassword

# Comando para visualizar status do Jenkins
status:
	$(DOCKER_COMPOSE) ps

# Variáveis
CONTAINER_NAME="jenkins" # give a make status to get container info
JOB_NAME=commit%20and%20push%20to%20github
COMMIT_MESSAGE?=Atualizações automáticas pelo Jenkins
AGENT_NAME="agent node"
WORK_DIR="/var/jenkins_home/agent"


# Carregar variáveis do arquivo .env
ifneq ("$(wildcard .env)","")
include .env
endif

run-jenkins:
	docker-compose up -d jenkins
	sleep 20  # Espera o Jenkins iniciar
	curl -X POST "${JENKINS_URL}/job/${JOB_NAME}/buildWithParameters?COMMIT_MESSAGE=${COMMIT_MESSAGE}" --user "seu-usuario:seu-token" 

connect-agent:
	$(DOCKER_COMPOSE) exec $(CONTAINER_NAME) \
		sh -c "cd /var/jenkins_home/agent/ \
		&& curl -O http://192.168.0.108:8080/jnlpJars/agent.jar \
		&& java -jar agent.jar -url http://192.168.0.108:8080/ \
		-secret ${JENKINS_AGENT_SECRET} \
		-name 'agent node' -workDir '/var/jenkins_home/agent'"