# Project Report: DevOps Resume Analyzer

## 1. Project Overview
The **DevOps Resume Analyzer** is a full-stack, AI-powered web application designed to evaluate user resumes. It extracts text, calculates an ATS (Applicant Tracking System) score, and provides actionable improvement suggestions.

Beyond the application itself, the core objective of this project was to implement a robust, automated DevOps lifecycle demonstrating Continuous Integration and Continuous Deployment (CI/CD), Infrastructure as Code (IaC), and automated testing.

## 2. System Architecture & Tech Stack

### Application Layer
- **Frontend**: Built with Next.js 16, React 19, and Tailwind CSS. Provides the user interface for uploading resumes and displaying the AI-generated report.
- **Backend**: Built with FastAPI (Python). Handles the API requests, uses `pdfplumber` to extract text from PDF files, and interfaces with the Groq API.
- **AI Integration**: Groq API is utilized as the LLM engine to perform lightning-fast analysis of the resume text.

### DevOps Layer
- **Infrastructure as Code (IaC)**: Terraform is used to provision local Docker networks and persistent storage volumes, ensuring reproducible infrastructure for the CI/CD servers.
- **Continuous Integration (CI)**: Jenkins automates the build pipeline, triggered by GitHub pushes.
- **Static Code Analysis**: SonarQube inspects the code for bugs, vulnerabilities, and code smells. A Quality Gate ensures poor code fails the build.
- **Containerization**: Docker and Docker Compose package the frontend and backend into isolated, reproducible environments.
- **Automated UI Testing**: Pytest and Selenium WebDriver run automated End-to-End (E2E) tests against the Next.js frontend using a Headless Chrome browser.

## 3. The CI/CD Pipeline Workflow

The automated Jenkins pipeline (`Jenkinsfile`) executes the following stages sequentially:

1. **Checkout Code**: Pulls the latest commit from the `master` branch.
2. **Code Quality (SonarQube)**: Scans the codebase. The pipeline pauses at the **Quality Gate**; if the code fails the security/quality thresholds, the pipeline aborts.
3. **Build & Start App (Docker)**: Uses `docker compose` to build fresh images for the frontend and backend, and starts them in detached mode.
4. **Automated UI Testing (Selenium)**: Spins up a temporary, isolated Python container to execute Selenium tests against the running application to verify UI integrity.
5. **Clean Up**: Tears down the application containers to prepare the server for the next build (or leaves them running if configured for Continuous Deployment).

## 4. Challenges Encountered & Resolutions

During the pipeline development, several complex DevOps challenges were encountered and successfully resolved:

### Issue 1: Docker Daemon Permission Denied
* **Error**: `permission denied while trying to connect to the docker API at unix:///var/run/docker.sock`
* **Root Cause**: The Jenkins container, running as the default `jenkins` user (UID 1000), lacked administrative permissions to access the host's Docker socket.
* **Resolution**: Modified the Terraform configuration (`main.tf`) to force the Jenkins container to run as the `root` user, granting it full access to orchestrate Docker containers.

### Issue 2: Git "Unsafe Repository" Error
* **Error**: `fatal: not in a git directory` during the Checkout stage.
* **Root Cause**: After switching the Jenkins container to run as `root`, Git detected a user ownership mismatch (the existing workspace files were owned by UID 1000). Git blocked operations for security reasons.
* **Resolution**: Executed `git config --global --add safe.directory '*'` inside the Jenkins container to establish trust, and wiped the stale workspace to force a clean clone.

### Issue 3: Missing Docker CLI in Jenkins
* **Error**: `docker: not found` during the Build stage.
* **Root Cause**: The fresh `jenkins/jenkins:lts` image deployed via Terraform does not include the Docker CLI natively.
* **Resolution**: Ran the official Docker installation script (`curl -fsSL https://get.docker.com | sh`) inside the Jenkins container to install the required CLI and Docker Compose plugins.

### Issue 4: Container Name Conflicts
* **Error**: `Conflict. The container name "/resume-backend" is already in use...`
* **Root Cause**: Stale containers from previous failed pipeline runs were left orphaned because the cleanup stage (`docker compose down`) did not execute successfully.
* **Resolution**: Manually pruned the orphaned containers. To prevent future issues in a Continuous Deployment scenario, the pipeline strategy was adapted to run `docker compose down || true` *before* the build phase, ensuring a clean slate for every deployment.

## 5. Conclusion
The project successfully demonstrates a modern, end-to-end DevOps workflow. It bridges the gap between software engineering and IT operations by automating the entire lifecycle—from code push to quality inspection, containerized building, and automated UI testing.
