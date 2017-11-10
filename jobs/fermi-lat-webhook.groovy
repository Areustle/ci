import hudson.model.*

properties([
     parameters([
       stringParam(
         description: 'Github Payload',
         name: 'payload'
       )
     ])
   ])


def projects = ["ScienceTools", "GlastRelease"]
def projectsToBuild = []

stage('Parse Webhook') {
    def ref = ""
    node("glast"){
        def payloadObject = readJSON text: payload
        def eventType = ""
        // Only trigger on pull requests that are opened, edited, or reopened
        if( "pull_request" in payloadObject && payloadObject.action in ["opened", "edited", "reopened"]) {
            eventType = "pull_request"
            echo "${payloadObject.pull_request.head}"
            ref = payloadObject.pull_request.head.ref
        } else if ("pusher" in payloadObject){
            eventType = "push"
        } else {
            currentBuild.result = 'SUCCESS'
            return
        }
        def login = payloadObject.sender.login
        def pkg = payloadObject.repository.name
        
        if (pkg in projects){
            projectsToBuild.add(pkg)
        } else {
            for (project in projects){
                sh "git clone git@github.com:fermi-lat/${project}.git"
                def statusCode = sh "cat ${project}/packageList.txt | grep '${pkg}'"
                if (statusCode == 0){
                    projectsToBuild.add(project)
                }
		    sh "rm -rf ${project}"
            }
        }
    }
    for (project in projectsToBuild){
        def job = "${project}-CI"
        build job: job, parameters: [[$class: 'StringParameterValue', name: 'repoman_ref', value: ref]]
    }
}

stage('Trigger Builds') {
    echo "hello world 1"
    // sh 'make'
}

@NonCPS
def slurpJson(String data) {
  def slurper = new groovy.json.JsonSlurper()
  slurper.parseText(data)
}

