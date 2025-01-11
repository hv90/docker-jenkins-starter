# Variables
DOCKER_COMPOSE = docker-compose
CONTAINER_NAME = jenkins

JENKINS_SERVICE=jenkins
PIPELINE_NAME=my-job

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


jenkins-commands-list:
	$(DOCKER_COMPOSE) exec -u jenkins $(JENKINS_SERVICE) bash -c "java -jar /usr/share/jenkins/jenkins-cli.jar -s ${JENKINS_URL} -auth ${JENKINS_USERNAME}:${JENKINS_PASSWORD} help"

jenkins-initial-admin-password:
	$(DOCKER_COMPOSE) exec $(CONTAINER_NAME) cat /var/jenkins_home/secrets/initialAdminPassword

jenkins-connect-agent-node:
	$(DOCKER_COMPOSE) exec $(CONTAINER_NAME) \
		sh -c "cd /var/jenkins_home/agent/ \
		&& curl -O ${JENKINS_URL}/jnlpJars/agent.jar \
		&& java -jar agent.jar -url ${JENKINS_URL}/ \
		-secret ${JENKINS_AGENT_SECRET} \
		-name 'agent node' -workDir '/var/jenkins_home/agent'"


wait-for-jenkins:
	@echo "Awaiting Jenkins get ready..."
	@until curl -s ${JENKINS_URL}/login > /dev/null; do echo "awaiting Jenkins..."; sleep 10; done
	@echo "Jenkins is ready now!"

get-jenkins-cli:
	@echo "Getting jenkins-cli"
	$(DOCKER_COMPOSE) exec $(JENKINS_SERVICE) bash -c "curl -sSL http://localhost:8080/jnlpJars/jenkins-cli.jar -o /usr/share/jenkins/jenkins-cli.jar"

jenkins-start-service:
	@make wait-for-jenkins
	@make get-jenkins-cli
	@make jenkins-connect-agent-node

jenkins-delete-pipeline:
	$(DOCKER_COMPOSE) exec -u jenkins $(JENKINS_SERVICE) bash -c "java -jar /usr/share/jenkins/jenkins-cli.jar -s ${JENKINS_URL} -auth ${JENKINS_USERNAME}:${JENKINS_PASSWORD} delete-job ${PIPELINE_NAME}"
	@echo "Pipeline ${PIPELINE_NAME} deleted!"

jenkins-list-jobs:
	$(DOCKER_COMPOSE) exec -u jenkins $(JENKINS_SERVICE) bash -c "java -jar /usr/share/jenkins/jenkins-cli.jar -s ${JENKINS_URL} -auth ${JENKINS_USERNAME}:${JENKINS_PASSWORD} list-jobs"

jenkins-create-pipeline:
	@echo "Creating pipeline ${PIPELINE_NAME}..."

	$(DOCKER_COMPOSE) exec -u jenkins $(JENKINS_SERVICE) bash -c "java -jar /usr/share/jenkins/jenkins-cli.jar -s ${JENKINS_URL} -auth ${JENKINS_USERNAME}:${JENKINS_PASSWORD} groovy = < /var/jenkins_home/workspace/project/jenkinsPipeline.groovy"

	@echo "Pipeline created!"


jenkins-run-pipeline:
	@if [ -z "$(COMMIT_MESSAGE)" ] || [ -z "$(DEPLOY_TO_NETLIFY)" ] || [ -z "$(IS_FIRST_COMMIT)" ]; then \
		echo "Try \`make jenkins-run-pipeline COMMIT_MESSAGE='message' DEPLOY_TO_NETLIFY=true IS_FIRST_COMMIT=false\`"; \
		exit 1; \
	fi

	@echo "Running pipeline ${PIPELINE_NAME}..."
	$(DOCKER_COMPOSE) exec -u jenkins $(JENKINS_SERVICE) bash -c "java -jar /usr/share/jenkins/jenkins-cli.jar -s ${JENKINS_URL} -auth ${JENKINS_USERNAME}:${JENKINS_PASSWORD} build ${PIPELINE_NAME} -p COMMIT_MESSAGE='$(COMMIT_MESSAGE)' -p DEPLOY_TO_NETLIFY=$(DEPLOY_TO_NETLIFY) -p IS_FIRST_COMMIT='$(IS_FIRST_COMMIT)'"
	@echo "Pipeline fired!"
	

jenkins-console:
	$(DOCKER_COMPOSE) exec -u jenkins $(JENKINS_SERVICE) bash -c "java -jar /usr/share/jenkins/jenkins-cli.jar -s ${JENKINS_URL} -auth ${JENKINS_USERNAME}:${JENKINS_PASSWORD} console ${PIPELINE_NAME}"; \
