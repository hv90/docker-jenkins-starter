import jenkins.model.*
import hudson.model.*
import org.jenkinsci.plugins.workflow.job.*
import org.jenkinsci.plugins.workflow.cps.*

def jobName = "my-job"

// List files in directory
// def dir = new File("./var/jenkins_home/workspace/project/") // 
// if (dir.exists() && dir.isDirectory()) {
//     dir.eachFile { file ->
//         println file.name
//     }
// } else {
//     println "Invalid or missing directory."
// }

def pipelineDefinition = new File('/var/jenkins_home/workspace/project/Jenkinsfile').text

def jenkins = Jenkins.instance
def job = jenkins.getItem(jobName)

if (job == null) {
    println("Creating new pipeline job: ${jobName}")
    // job = new WorkflowJob(jenkins, jobName)
    job = jenkins.createProject(org.jenkinsci.plugins.workflow.job.WorkflowJob, jobName)
} else {
    println("Job already exists: ${jobName}")
}

job.definition = new CpsFlowDefinition(pipelineDefinition, true)
job.save()

println("Pipeline job ${jobName} created/updated successfully")
