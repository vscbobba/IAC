@Library('my-shared-library') _
pipeline {
    agent any     // label "slave"//

    stages {
        stage('Hello') {
            steps {
                echo 'Hello World'
            }
        }
        stage('git chekcout')  {
            steps {
                git branch: 'jenkins', credentialsId: 'slave', url: 'https://github.com/vscbobba/IAC.git'
            }
        }
        stage('test shared library'){
            steps {
                sample()
            }
        }
        stage('shell commands') {
            steps{
                sh 'ansible-playbook Ansible/playbook.yml -e anshost=workstation -e role_name=frontend'
            }
        }   
    }
}