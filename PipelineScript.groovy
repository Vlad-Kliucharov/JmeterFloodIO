#!/usr/bin/env groovy

node {

properties([parameters([
  choice(choices: ['SurveyCheck'], description: 'Select jmx file', name: 'TEST_NAME'),
  string(defaultValue: '1', description: 'Enter quantity of test users', name: 'VUSERS'), 
  string(defaultValue: '1', description: 'Enter ramp-up', name: 'RAMP_UP'),
  string(defaultValue: '1', description: 'Enter duration of test', name: 'DURATION'),
  string(defaultValue: '-Xms4g -Xmx4g -Xmx256m', description: 'Enter your args', name: 'JVM_ARGS')])])

    stage("Clean Workspace") {
        cleanWs()
    }
    stage('Checkout external proj') {
        git credentialsId: 'GitCredential', url: 'https://git.epam.com/vladyslav_kliucharov/test-script-flood.io-jmx.git'    
    }
    stage('JMeter Test') {
        sh 'mkdir Reports'
        try {
            sh """docker run --name jcont --env '$JVM_ARGS' -v ${WORKSPACE}:${WORKSPACE} jmeter -n -t ${WORKSPACE}/${TEST_NAME}.jmx -JVUsers=${VUSERS} -JRamp_Up=${RAMP_UP} -JDuration=${DURATION} -l ${WORKSPACE}/Reports/test.jtl -e -o ${WORKSPACE}/Reports"""
        } catch (error) {
            sh "docker rm --force jcont"
            sh """docker run --name jcont --env '$JVM_ARGS' -v ${WORKSPACE}:${WORKSPACE} jmeter -n -t ${WORKSPACE}/${TEST_NAME}.jmx -JVUsers=${VUSERS} -JRamp_Up=${RAMP_UP} -JDuration=${DURATION} -l ${WORKSPACE}/Reports/test.jtl -e -o ${WORKSPACE}/Reports"""
        }
    }
    stage('Reporting'){
        publishHTML([allowMissing: false, alwaysLinkToLastBuild: false, keepAll: false, reportDir: 'Reports', reportFiles: 'index.html', reportName: 'HTML Report', reportTitles: ''])
    }
    stage('Archive'){
		archiveArtifacts artifacts: 'Reports/**/*.*', fingerprint: true, followSymlinks: false
    }
}