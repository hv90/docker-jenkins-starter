pipeline {
    agent any

    environment {
        NETLIFY_AUTH_TOKEN = credentials('NETLIFY_AUTH_TOKEN') 

        GITHUB_TOKEN = credentials('GITHUB_TOKEN')
        GITHUB_USER_NAME = credentials('GITHUB_USER_NAME')
        GITHUB_REPO = credentials('GITHUB_REPO')
        GITHUB_USER_EMAIL = credentials('GITHUB_USER_EMAIL')
    }

    parameters {
        string(name: 'COMMIT_MESSAGE', defaultValue: 'Atualizações automáticas pelo Jenkins', description: 'Mensagem de commit para o Git')
        booleanParam(name: 'RUN_COMMIT_PUSH', defaultValue: false, description: 'Executar o commit e push?')
    }

    stages {
        stage('Install Dependencies') {
            when {
              expression {!params.RUN_COMMIT_PUSH}
            }

            steps {
                script {
                    // Instala as dependências do projeto
                    sh 'npm install'
                }
            }
        }
        
        stage('Build') {
            when {
              expression {!params.RUN_COMMIT_PUSH}
            }

            steps {
                script {
                    // Realiza o build do projeto
                    sh 'npm run build'
                }
            }
        }

        stage('Deploy to Netlify') {
            when {
              expression {!params.RUN_COMMIT_PUSH}
            }

            steps {
                script {
                    // Faz o deploy para o Netlify usando o Netlify CLI
                    sh '''
                        netlify deploy --prod --dir=dist --auth=$NETLIFY_AUTH_TOKEN
                    '''
                }
            }
        }

        stage('Commit and Push') {
            when {
              expression {params.RUN_COMMIT_PUSH}
            }

            steps {
                script {            
                    dir('/var/jenkins_home/workspace/project') {                        
                        sh "git config user.name '${GITHUB_USER_NAME}'"
                        sh "git config user.email '${GITHUB_USER_EMAIL}'"
    
                        sh "git checkout main"
                        sh "git add ."                    
                        sh "git commit -m '${params.COMMIT_MESSAGE}' --allow-empty"  
                        sh "git status"
                        sh "ls -la"

                        sh "git pull origin main --rebase"
                        sh "git push 'https://${GITHUB_TOKEN}@${GITHUB_REPO}'"
                    }
                }
            }
        }
    }
}
