pipeline {
    agent any

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
        stage('shell commands') {
            steps{
                sh 'cd Ansible'
                sh 'ansible-playbook playbook.yml -e anshost=jenkins -e "role_name=frontend"'
            }
        }   
    }
}