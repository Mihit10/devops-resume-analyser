"""Resume analysis route."""

import logging
from fastapi import APIRouter, File, HTTPException, UploadFile

from app.utils.pdf_parser import extract_text
from app.services.groq_service import analyze_resume

logger = logging.getLogger(__name__)

router = APIRouter()


@router.post("/analyze")
async def analyze(file: UploadFile = File(...)):
    """
    Analyze an uploaded PDF resume.

    Accepts a PDF file, extracts text, sends it to Groq AI for analysis,
    and returns extracted skills, ATS score, and improvement suggestions.
    """
    # Validate file type
    if not file.filename or not file.filename.lower().endswith(".pdf"):
        raise HTTPException(
            status_code=400,
            detail="Only PDF files are accepted. Please upload a .pdf file.",
        )

    if file.content_type and file.content_type != "application/pdf":
        raise HTTPException(
            status_code=400,
            detail="Invalid content type. Expected application/pdf.",
        )

    try:
        # Read file bytes
        file_bytes = await file.read()

        if len(file_bytes) == 0:
            raise HTTPException(
                status_code=400,
                detail="The uploaded file is empty.",
            )

        # Extract text from PDF
        resume_text = extract_text(file_bytes)
        logger.info(
            "Extracted %d characters from %s", len(resume_text), file.filename
        )

        # Analyze with Groq AI
        result = analyze_resume(resume_text)
        logger.info(
            "Analysis complete for %s — ATS score: %d",
            file.filename,
            result["ats_score"],
        )

        return result

    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    except RuntimeError as e:
        logger.error("Analysis failed: %s", str(e))
        raise HTTPException(status_code=502, detail=str(e))
    except HTTPException:
        raise
    except Exception as e:
        logger.exception("Unexpected error during analysis")
        raise HTTPException(
            status_code=500,
            detail="An unexpected error occurred while analyzing the resume.",
        )
