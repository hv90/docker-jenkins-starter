import jenkins.model.*
import hudson.model.*
import org.jenkinsci.plugins.workflow.job.*
import org.jenkinsci.plugins.workflow.cps.*

def jobName = "my-job"

def filePathname = '/var/jenkins_home/workspace/project/Jenkinsfile'

def dir = new File("./var/jenkins_home/workspace/project/") 
if (dir.exists() && dir.isDirectory()) {
    dir.eachFile { file ->
        // println file.name
        if (file.name == 'docker-jenkins-starter') {
            filePathname = '/var/jenkins_home/workspace/project/docker-jenkins-starter/Jenkinsfile'
        }
    }
} else {
    println "Invalid or missing directory."
}

def pipelineDefinition = new File(filePathname).text

def jenkins = Jenkins.instance
def job = jenkins.getItem(jobName)

if (job == null) {
    println("Creating new pipeline job: ${jobName}")
    
    job = jenkins.createProject(org.jenkinsci.plugins.workflow.job.WorkflowJob, jobName)

    def parametersDefinition = new ParametersDefinitionProperty(
        new StringParameterDefinition('COMMIT_MESSAGE', 'Atualizações automáticas pelo Jenkins', 'Mensagem de commit para o Git'),
        new BooleanParameterDefinition('DEPLOY_TO_NETLIFY', false, 'Fazer deploy para o netlify?'),
        new BooleanParameterDefinition('IS_FIRST_COMMIT', false, 'É o primeiro commit?'),
        new BooleanParameterDefinition('IS_MAINTENANCE', false, 'Pipeline de manutenção?')
    )
    job.addProperty(parametersDefinition)
} else {
    println("Job already exists: ${jobName}")
}

job.definition = new CpsFlowDefinition(pipelineDefinition, true)
job.save()

println("Pipeline job ${jobName} created/updated successfully")
