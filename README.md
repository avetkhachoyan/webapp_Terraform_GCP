# Infrastructure as a Code with Terraform and GitHub Actions for Google Cloud Platform (GCP)

Repository contains Terraform code, GitHub Actions rules and monitoring dashboard template to set up infrastructure on Google Cloud Platform (GCP) for automated deployment pipeline, database management using Google Cloud SQL, and basic monitoring using Google Cloud Monitoring.

## Contents

- [Infrastructure Components](#infrastructure-components)
- [Features](#features)
- [Prerequisites](#prerequisites)
- [Usage](#usage)
- [Monitoring Details](#monitoring-details)
- [GitHub Deployment Automation](#github-deployment-automation)
- [Dashboard Template](#dashboard-template)
- [Notes](#notes)
- [License](#license)
- [Summary](#summary)

## Infrastructure Components

1. **Automated Deployment Pipeline in GitHub**: Utilizes a modularized GitHub repository module for automated deployment pipeline setup.
2. **Database Management (Google Cloud SQL)**: Utilizes a modularized Google Cloud SQL module for managing MySQL database instance. Instnace is encripted.
3. **Basic Monitoring Setup (Google Cloud Monitoring)**: Utilizes a modularized monitoring module for setting up basic monitoring using Google Cloud Monitoring.

These components are representing the following set of features

## Features

- **Cloud Function Deployment**: Automatically deploy a Python Cloud Function to handle HTTP requests.
- **Cloud SQL Database Setup**: Provision a MySQL database instance on Google Cloud SQL to store application data.
- **Monitoring Configuration**: Set up basic monitoring for the Cloud Function and Cloud SQL database to track health and performance metrics.
- **GitHub Deployment Automation**: Implement GitHub Actions to automate the deployment of the Cloud Function upon each commit to specified branches.

## Prerequisites

Before using this Terraform code, ensure you have the following prerequisites:

- [Terraform](https://www.terraform.io/downloads.html) installed on your local machine.
- [Google Cloud Platform](https://cloud.google.com/) account with appropriate permissions and billing enabled.
- [GitHub](https://github.com/) account for setting up automated deployment pipeline.

## Usage

1. Clone this repository to your local machine:

    ```bash
    git clone <repository-url>
    ```

2. Navigate to the repository directory:

    ```bash
    cd <repository-directory>
    ```

3. Modify the Terraform configuration files (`provider.tf`, `main.tf`, `variables.tf`, etc.) to specify your project ID, region, Cloud Function details, Cloud SQL database details, and any other configuration options as needed.

4. Set up Terraform authentication with Google Cloud Platform:

    ```bash
    gcloud auth application-default login
    ```
NB. In case of leveraging Terraform Cloud or other communicative approach the step above might vari

5. Initialize the Terraform configuration:

    ```bash
    terraform init
    ```

6. Review the Terraform execution plan:

    ```bash
    terraform plan
    ```
    Leveraging Output file is a matter of chioce, it can be done as below:
    
    ```bash
    terraform plan -out=tf.plan
    terraform show  tf.plan > tfplan.ansi
    ```

7. Apply the Terraform configuration to deploy the Cloud Function, set up the Cloud SQL database, and configure monitoring:

    ```bash
    terraform apply
    ```
    
    Applying output file generated at plan step per below:

    ```bash
    terraform apply tf.plan
    ```

8. After the Terraform apply completes, navigate to the Google Cloud Console > Monitoring to view the created dashboards, uptime checks, and alerting policies.

## Monitoring Details

### Cloud Function Monitoring

- **Uptime Check**: Monitors the availability of the Cloud Function by sending HTTP requests to its URL.
- **Dashboard**: Custom dashboard to visualize metrics such as invocation count and execution duration of the Cloud Function.
- **Alerting Policy**: Alerts configured to notify when the function's latency or invocation count exceeds specified thresholds.

Dashboards templates should be defined per requirements and put into dashboards folder. Cloud Function is the serverless representatoin of the webapp.

### Cloud SQL Monitoring

- **Uptime Check**: Monitors the availability of the Cloud SQL database.
- **Dashboard**: Custom dashboard to visualize metrics such as CPU utilization and disk usage of the database.
- **Alerting Policy**: Alerts configured to notify when the database's CPU utilization exceeds a specified threshold.

Dashboards templates should be defined per requirements and put into dashboards folder, same as for Cloud Function.

## GitHub Deployment Automation

- **GitHub Actions**: Implement continuous deployment using GitHub Actions to automatically deploy the Cloud Function upon each commit to specified branches.
Make sure that the necessary environment variables, secrets, etc. are configured and set. 

## Dashboard Template

A basic dashboard template JSON file (`dashboard-template.json`) is provided to create custom dashboards for both Cloud Function and Cloud SQL monitoring. You can customize this template further to meet your specific monitoring requirements.

## Notes

- Ensure that appropriate notification channels are set up in Cloud Monitoring to receive alerts.
- Regularly review and update the monitoring setup to adapt to changes in your application and database.

## License
[MIT](https://mit-license.org/)

## Summary
This repo guide shows Python webapp deployment, maintenance and monitoring in Google Cloud Platform (GCP) leveraging Terraform and GitHub Actions.
Happy Terraforming!

[Ա](https://khachoyan.com) -
