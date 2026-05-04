import os
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from dotenv import load_dotenv

from app.routes.analyze import router as analyze_router

# Load environment variables from .env file
load_dotenv()


def create_app() -> FastAPI:
    """Create and configure the FastAPI application."""
    app = FastAPI(
        title="AI Resume Analyzer",
        description="Analyze resumes using AI to extract skills, calculate ATS scores, and provide improvement suggestions.",
        version="1.0.0",
    )

    # CORS configuration
    cors_origins = os.getenv("CORS_ORIGINS", "*")
    origins = [origin.strip() for origin in cors_origins.split(",")]

    app.add_middleware(
        CORSMiddleware,
        allow_origins=origins,
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
    )

    # Register routes
    app.include_router(analyze_router)

    @app.get("/health")
    async def health_check():
        """Health check endpoint for Kubernetes probes."""
        return {"status": "healthy"}

    return app


app = create_app()
