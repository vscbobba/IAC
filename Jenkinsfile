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
                sh 'cd Ansible'
                sh 'ansible-playbook playbook.yml -e anshost=jenkins -e "role_name=frontend"'
            }
        }   
    }
}