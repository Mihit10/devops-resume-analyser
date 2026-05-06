# DevOps Resume Analyzer

An AI-powered Resume Analyzer application built with a robust DevOps toolchain. This project utilizes a Next.js frontend, a FastAPI Python backend, and the Groq API to parse and analyze resumes, extracting skills, calculating ATS scores, and providing improvement suggestions. 

It is designed with a strong focus on CI/CD and Infrastructure as Code (IaC), featuring an automated Jenkins pipeline, SonarQube code quality checks, and Selenium E2E testing, all orchestrated via Docker and Terraform.

## 🚀 Features

- **Frontend**: Modern, responsive UI built with Next.js 16, React 19, and Tailwind CSS v4.
- **Backend**: High-performance REST API built with FastAPI.
- **AI Integration**: Leverages Groq API for lightning-fast resume analysis and AI-driven insights.
- **Resume Parsing**: Extracts text from PDF resumes using `pdfplumber`.
- **Infrastructure as Code (IaC)**: Terraform scripts to provision local Docker networks and persistent volumes for Jenkins and SonarQube.
- **Automated CI/CD**: A comprehensive `Jenkinsfile` that automates checkout, SonarQube analysis, building, deploying, and E2E UI testing.
- **E2E Testing**: Automated UI tests using Pytest and Selenium (Headless Chrome) against the Next.js frontend.

## 🛠️ Technology Stack

### Application
- **Frontend**: Next.js 16, React 19, Tailwind CSS v4, TypeScript
- **Backend**: Python 3.10+, FastAPI, Uvicorn, `pdfplumber`
- **AI/LLM**: Groq API

### DevOps & Infrastructure
- **Containerization**: Docker, Docker Compose
- **CI/CD**: Jenkins
- **Code Quality**: SonarQube
- **IaC**: Terraform
- **Testing**: Pytest, Selenium WebDriver

## 📂 Project Structure

```text
devops-resume-analyser/
├── app/                  # Next.js Frontend App Directory
├── backend/              # FastAPI Python Backend
│   ├── app/              # Backend application code (routes, services, utils)
│   ├── Dockerfile        # Backend Docker container definition
│   └── requirements.txt  # Python dependencies
├── terraform/            # Terraform configurations for Jenkins & SonarQube
│   └── main.tf           # Terraform main entrypoint
├── tests/                # Automated Tests
│   └── e2e/              # Selenium E2E tests for the frontend
├── docker-compose.yml    # Orchestrates frontend, backend, Jenkins, and SonarQube
├── Dockerfile            # Frontend Docker container definition
├── Jenkinsfile           # Jenkins Pipeline configuration
└── package.json          # Frontend dependencies
```

## ⚙️ Getting Started

### Prerequisites

Ensure you have the following installed:
- [Docker & Docker Compose](https://www.docker.com/) (Required for running the full stack)
- [Terraform](https://www.terraform.io/) (For setting up Jenkins and SonarQube infrastructure)
- [Node.js 20+](https://nodejs.org/) (If running the frontend locally without Docker)
- [Python 3.10+](https://www.python.org/) (If running the backend locally without Docker)

### 1. Environment Variables

Create a `.env` file in the `backend/` directory using `.env.example` as a template:

```bash
cp backend/.env.example backend/.env
```

Ensure you configure your Groq API key:
```env
GROQ_API_KEY=your_groq_api_key_here
```

### 2. Infrastructure Setup (Optional but recommended for CI/CD)

To set up Jenkins and SonarQube using Terraform:

```bash
cd terraform
terraform init
terraform apply
```

This will create a Docker network (`devops_pipeline_network`), persistent volumes, and spin up Jenkins (Port `8080`) and SonarQube (Port `9000`).

### 3. Running the Application via Docker Compose

To quickly start just the application (Frontend + Backend):

```bash
docker compose up -d frontend backend
```

- **Frontend**: [http://localhost:3000](http://localhost:3000)
- **Backend API Docs (Swagger UI)**: [http://localhost:8000/docs](http://localhost:8000/docs)

### 4. Running Locally (Without Docker)

**Backend:**
```bash
cd backend
pip install -r requirements.txt
uvicorn app.main:app --reload --port 8000
```

**Frontend:**
```bash
npm install
npm run dev
```

## 🔄 CI/CD Pipeline Architecture

The pipeline is defined in the `Jenkinsfile` and is triggered on pushes to the repository. The stages include:

1. **Checkout Code**: Pulls the latest code from the repository.
2. **Code Quality (SonarQube)**: Runs the SonarQube Scanner against the codebase to check for code smells, bugs, and vulnerabilities.
3. **Quality Gate**: Pauses the pipeline to verify the SonarQube analysis passes the required thresholds.
4. **Build & Start App (Docker)**: Uses Docker Compose to build and start the frontend and backend containers in detached mode.
5. **Automated UI Testing (Selenium)**: 
    - Spins up a temporary isolated Python Docker container on the same network.
    - Installs Google Chrome and Selenium requirements.
    - Runs Pytest scripts (`tests/e2e/test_homepage.py`) to verify frontend UI functionality in headless mode.
6. **Deploy**: A placeholder stage representing deployment to a staging or production environment (e.g., AWS ECR/ECS).

The pipeline smartly manages the lifecycle of the application containers:
- Old webapp containers are automatically stopped and destroyed before building a new version.
- If the build and tests succeed, the newly deployed webapp containers are left running so the application remains continuously available.
- If the pipeline fails, the broken containers are gracefully cleaned up.
- Core CI/CD infrastructure (Jenkins and SonarQube) is explicitly isolated and left undisturbed.

## 🧪 Testing

To run the Selenium E2E tests manually locally:

1. Ensure the frontend is running on `http://localhost:3000`.
2. Navigate to the `tests/e2e/` directory.
3. Install test dependencies: `pip install -r ../../backend/requirements.txt` (and make sure `pytest` and `selenium` are installed).
4. Run the tests:
```bash
pytest test_homepage.py -v
```
