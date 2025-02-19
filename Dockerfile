FROM jenkins/jenkins:lts

USER root

RUN apt-get update \
    && apt-get install curl -y \
    && curl -sL https://deb.nodesource.com/setup_16.x | bash - \
    && apt-get install -y nodejs \
    && npm install -g netlify-cli \
    && apt-get clean

RUN chown -R jenkins:jenkins /var/jenkins_home \
    && chown jenkins:jenkins /usr/share/jenkins \
    && mkdir -p /var/jenkins_home/agent \
    && chown -R jenkins:jenkins /var/jenkins_home/agent \
    && mkdir -p /var/jenkins_home/workspace/project \
    && chown -R jenkins:jenkins /var/jenkins_home/workspace 
    
USER jenkins

RUN jenkins-plugin-cli --plugins blueocean workflow-aggregator git docker-workflow
