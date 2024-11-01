# Sample Application

## How to run

```bash
poetry env use python3
poetry install
poetry run python main.py
```

## How to test

```bash
poetry run pytest -s
```

# Deployment CI CD pipeline with Sample Application

This wiki provides configurations for deploying and validating a Docker application using Ansible, GitHub Actions, and Docker Hub.

# Before you begin:

Ansible: You should have Ansible installed and configured on your system. Refer to Ansible documentation for installation instructions.

Docker Hub: Create an account on [Docker Hub](https://www.google.com/url?sa=E&source=gmail&q=https://hub.docker.com/) if you don't have one already.

GitHub Actions (Optional): Set up GitHub Actions workflow if you plan to automate deployments within your GitHub repository.
Installation

## Ansible:
There's no installation required for this repository on the target system where you want to deploy the application. It can be used with an Ansible control machine. And This package will be installed via GitHub Actions workflow file

## Docker Hub:
Create a Docker Hub repository for your application image.
Obtain your Docker Hub username and access token (refer to Docker Hub documentation for retrieval).

## GitHub Actions:
Create a GitHub Actions workflow file (.github/workflows/aws.yml) to trigger deployments on specific events (e.g., push to a branch).
Configure the workflow with the necessary steps and secrets for authentication and deployment.

## Usage
This repository provides the following configurations for deployment:

Ansible Playbook: These playbooks define building tasks, pushing, validating, and deploying the Docker application.

### Using Ansible:
To build, push, validate and deploy a Docker image with some sensitive data we need to update some secret environment variables required in this repository for authentication

Docker Hub credentials (username and access token) in the appropriate variables.

### Run the Ansible playbook in GitHub workflow file: 

In install.yml we have three tasks which are setup ci/ci node, build and deploy, to be able to run ansible-playbook without any problem, we should first run setup ci/cd node

_Setup CI/CD node_

```bash
ansible-playbook deploy-docker/install.yml --skip-tags "build_stage,deployment_stage"
```

_Build_

```bash
echo ${{ secrets.DOCKERHUB_TOKEN }} > token.txt 2>/dev/null
```

```bash
ansible-playbook deploy-docker/install.yml --skip-tags "pre_setup_stage,deployment_stage" --extra-vars "dockerhub_username=${{ secrets.DOCKERHUB_USERNAME }}"
```

_Test_

```bash
ansible-playbook deploy-docker/test.yml
```

_Deploy_

```bash
ansible-playbook deploy-docker/install.yml --skip-tags "pre_setup_stage,build_stage"
```

_Note_: Use **extra-vars** if you want to deploy your application to a public server

```bash
--extra-vars "REMOTE_HOSTNAME=${{ secrets.REMOTE_HOSTNAME }} REMOTE_IP=${{ secrets.REMOTE_HOSTNAME }}  REMOTE_USERNAME=${{ secrets.REMOTE_USERNAME }} REMOTE_SSH_PORT=22 REMOTE_PASSWORD=${{ secrets.REMOTE_PASSWORD }}"
```

REMOTE_HOSTNAME: Hostname of the server

REMOTE_IP: Public Interface address

REMOTE_USERNAME: The username for ssh connection

REMOTE_PASSWORD: Password for ssh connection (Not recommended, use shared private key instead)

## We also have a pipeline setup on our Jenkins server for CI/CD, Please refer to the link below

[Devops-test Pipeline](https://phongnghia.io.vn/job/devops-test-pipeline)

### Below is the GitHub Action file process that was used

_Build_

      - name: Install Ansible
        run: |
          python -m pip install --upgrade pip
          pip install ansible boto3

      - name: Run pre-setup for CI/CD node
        run: |
          ansible-playbook deploy-docker/install.yml --skip-tags "build_stage,deployment_stage"

      - name: Run Build Stage
        run: |
          echo ${{ secrets.DOCKERHUB_TOKEN }} > token.txt 2>/dev/null
          ansible-playbook deploy-docker/install.yml --skip-tags "pre_setup_stage,deployment_stage" \
          --extra-vars "dockerhub_username=${{ secrets.DOCKERHUB_USERNAME }}"
_Test_

      - name: Install Ansible
        run: |
          python -m pip install --upgrade pip
          pip install ansible boto3

      - name: Run pre-setup for CI/CD node
        run: |
          ansible-playbook deploy-docker/install.yml --skip-tags "build_stage,deployment_stage"

      - name: Run Test Stage
        run: ansible-playbook deploy-docker/test.yml
 
_Deploy_

      - name: Install Ansible
        run: |
          python -m pip install --upgrade pip
          pip install ansible boto3

      - name: Run pre-setup for CI/CD node
        run: |
          ansible-playbook deploy-docker/install.yml --skip-tags "build_stage,deployment_stage"

      - name: Run Deploy Stage
        run: |
          ansible-playbook deploy-docker/install.yml \
          --skip-tags "pre_setup_stage,build_stage"
