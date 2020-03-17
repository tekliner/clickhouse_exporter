node {
    checkout scm
    def branch = env.BRANCH_NAME.toLowerCase()
    def registry = "716309063777.dkr.ecr.us-east-1.amazonaws.com"
    def build = env.BUILD_NUMBER
    def image

    stage("Build image") {
        sh 'docker build -t clickhouse-exporter .'
        image = docker.image("clickhouse-exporter")
    }

    stage("Push image") {
        docker.withRegistry("https://"+registry+"/", 'ecr:us-east-1:3c5c323b-afed-4bf0-ae1a-3b19d1c904fe') {
            image.push("${branch}-${build}")
        }
    }

 if (branch == 'master') {
      // deploy to production
        stage ('Wait for confirmation of build promotion') {
	          input message: 'Is this build ready for production?', submitter: 'tekliner'
        }
	      stage ('Deploy to production') {
            writeFile file: 'deploy.yaml', text: """
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: clickhouse-exporter
  namespace: clickhouse
spec:
  replicas: 1
  selector:
    matchLabels:
      app: clickhouse-exporter
  template:
    metadata:
      labels:
        app: clickhouse-exporter
    spec:
      containers:
        - name: clickhouse-exporter
          # Replace this with the built image name
          image: 716309063777.dkr.ecr.us-east-1.amazonaws.com/clickhouse-exporter:${branch}-${build}
          ports:
          - containerPort: 9116
            name: exporter
          env:
          - name: CLICKHOUSE_USER
            valueFrom:
              secretKeyRef:
                name: exporter-creds
                key: CLICKHOUSE_USER
          - name: CLICKHOUSE_PASSWORD
            valueFrom:
              secretKeyRef:
                name: exporter-creds
                key: CLICKHOUSE_PASSWORD
          resources:
              limits:
                memory: "128Mi"
                cpu: "100m"
"""
            archiveArtifacts: 'deploy.yaml'
            sh "kubectl apply -f deploy.yaml -n clickhouse"
            sh "kubectl apply -f deploy/service.yaml -n clickhouse"
            sh "kubectl apply -f deploy/servicemonitor.yaml -n clickhouse"
        }
    }
}