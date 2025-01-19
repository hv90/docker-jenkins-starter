# docker-jenkins-starter

## Aim:
This automation intends to simplify github push pipeline by using jenkins and docker 

### Prerequisites:

- be able to run makefile (have make and some gcc-like compiler installed)
- have [jenkins](https://www.jenkins.io/) and [docker](https://www.docker.com/) installed and configured
- have a local .env file at the root of this cloned/downloaded project. It must have the following structure:

  ```
  PROJECT_ROOT_DIR=the/absolute/path/to/your/project

  GITHUB_TOKEN=github_pat_goes_in_here
  GITHUB_USER_EMAIL=user@email.com
  GITHUB_USER_NAME=user
  GITHUB_REPO=github.com/user/remote-repo.git

  JENKINS_AGENT_SECRET=your-agent-secret
  JENKINS_URL=http://localhost:1234
  JENKINS_USERNAME=admin
  JENKINS_PASSWORD=admin

  NETLIFY_AUTH_TOKEN=
  ```

\* _Make sure to have fields filled in_

- you will need 2 terminals to run pipelines with this project

### Steps

#### At the root of the project you want to push to git
1. clone/download this repo at the root of the project you want to push to git
2. create a .env file at the root of this cloned/downloaded repo, copy and paste inside it the .env template previously provided, make sure to fill in this .env of yours

#### Terminal #1:
1. `make up-and-build`
   _(await like 10 seconds before next step)_
2. `make jenkins-start-service`

#### Terminal #2:
1. `make jenkins-create-and-run-pipeline COMMIT_MESSAGE="your commit message here" DEPLOY_TO_NETLIFY=false`
2. `make jenkins-console` _(optional. It retrieves the build current status)_

### make jenkins-create-and-run-pipeline common params

| Param             | Mandatory | Default Value |
| ----------------- | --------- | ------------- |
| COMMIT_MESSAGE    | Yes       | -             |
| DEPLOY_TO_NETLIFY | No        | false         |
