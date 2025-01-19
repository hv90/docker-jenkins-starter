# docker-jenkins-starter
### Prerequisites:
- have a local .env file at the root of the project. It must have the following structure:
  ```
  PROJECT_ROOT_DIR=the/absolute/path/to/your/project
  
  GITHUB_TOKEN=
  GITHUB_USER_EMAIL=
  GITHUB_USER_NAME=
  GITHUB_REPO=
  
  JENKINS_AGENT_SECRET=
  JENKINS_URL=
  JENKINS_USERNAME=admin
  JENKINS_PASSWORD=admin
  
  NETLIFY_AUTH_TOKEN=
  ```
\* *Make sure to have fields filled in*

- you will need 2 terminals to run pipelines with this project

### Steps (Run the following steps in each terminal)
*These steps must be run at the root of this project*
#### Terminal #1:
1. `make up-and-build`
*(await like 10 seconds before next step)*
2. `make jenkins-start-service`

#### Terminal #2:
1. `make jenkins-create-and-run-pipeline COMMIT_MESSAGE="your commit message here" DEPLOY_TO_NETLIFY=false`
2. `make jenkins-console` *(optional. It retrieves the build current status)*

### make jenkins-create-and-run-pipeline common params

| Param             | Mandatory | Default Value |
|-------------------|-----------|---------------|
| COMMIT_MESSAGE    |    Yes    |        -      |
| DEPLOY_TO_NETLIFY |    No     |      false    |