pipeline {
    agent any

    parameters {
        string(name: 'COMMIT_MESSAGE', defaultValue: 'Atualizações automáticas pelo Jenkins', description: 'Mensagem de commit para o Git')
        booleanParam(name: 'DEPLOY_TO_NETLIFY', defaultValue: false, description: 'Fazer deploy para o netlify?')
    }

    // environment {
    //     // Definindo variáveis de ambiente diretamente no Jenkinsfile
    //     NETLIFY_AUTH_TOKEN = credentials('NETLIFY_AUTH_TOKEN')
    //     GITHUB_TOKEN = credentials('GITHUB_TOKEN')
    //     GITHUB_USER_NAME = credentials('GITHUB_USER_NAME')
    //     GITHUB_REPO = credentials('GITHUB_REPO')
    //     GITHUB_USER_EMAIL = credentials('GITHUB_USER_EMAIL')
    // }

    stages {
        stage('Load Env') {
            steps {
                script {
                    // Carregar variáveis de ambiente do arquivo .env
                    def envFile = readFile '/var/jenkins_home/workspace/project/.env'
                    envFile.split('\n').each { line ->
                        if (line.trim() && !line.startsWith('#')) { 
                            def (key, value) = line.split('=')
                            env.setProperty(key.trim(), value.trim())
                        }
                    }
                }
            }
        }

        stage('Install Dependencies') {
            when {
                expression { params.DEPLOY_TO_NETLIFY }
            }
            steps {
                script {
                    sh 'npm install'
                }
            }
        }

        stage('Build') {
            when {
                expression { params.DEPLOY_TO_NETLIFY }
            }
            steps {
                script {
                    sh 'npm run build'
                }
            }
        }

        stage('Deploy to Netlify') {
            when {
                expression { params.DEPLOY_TO_NETLIFY }
            }
            steps {
                script {
                    sh 'netlify deploy --prod --dir=dist --auth=$env.NETLIFY_AUTH_TOKEN'
                }
            }
        }

        stage('Commit and Push') {
            when {
                expression { !params.DEPLOY_TO_NETLIFY }
            }
            steps {
                script {
                    def checkoutOrCreateMainBranch = { ->
                        def branchExists = sh(script: 'git show-ref --quiet refs/heads/main', returnStatus: true) == 0
                        
                        if (branchExists) {
                            // Se a branch 'main' já existir, faz o checkout
                            sh 'git checkout main'
                        } else {
                            // Se a branch 'main' não existir localmente
                            def remoteBranchExists = sh(script: 'git show-ref --quiet refs/remotes/origin/main', returnStatus: true) == 0
                            
                            if (remoteBranchExists) {
                                // Se a branch 'main' existir remotamente, cria localmente e faz checkout
                                // sh 'git checkout -b main origin/main'
                                sh 'git checkout -b main'
                            } else {
                                // Se a branch 'main' não existir nem localmente, nem remotamente
                                sh 'git checkout -b main'
                            }
                        }
                    }

                    dir('/var/jenkins_home/workspace/project') {
                        // Configurar o Git
                        sh "git init"
                        sh "git config user.name '${env.GITHUB_USER_NAME}'"
                        sh "git config user.email '${env.GITHUB_USER_EMAIL}'"
                        sh "git remote set-url origin https://'${env.GITHUB_TOKEN}'@'${env.GITHUB_REPO}'"
                        
                        // Realizar commit e push
                        checkoutOrCreateMainBranch()
                        sh "git add ."
                        sh "git commit -m '${params.COMMIT_MESSAGE}' --allow-empty"
                        sh "git branch -M main"
                        // sh "git pull origin main --rebase"
                        sh "git push 'https://${env.GITHUB_TOKEN}@${env.GITHUB_REPO}'"
                    }
                }
            }
        }
    }
}
