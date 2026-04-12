"""
FastAPI REST — espone il backend Neo4j alla Web App Google Apps Script.
Gira sulla stessa macchina del bot Telegram.
"""
import logging
import uuid
from typing import List, Optional
from fastapi import FastAPI, HTTPException, Header, Depends
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from brain import Brain
from gemini_service import (
    generate_morning_question,
    generate_one_percent_suggestion,
    generate_conversation_reply,
)
from config import API_SECRET, YOUR_TELEGRAM_ID

logger = logging.getLogger(__name__)

app = FastAPI(
    title="90dayman API",
    description="Backend API for 90dayman Mental Coach",
    version="1.0.0"
)

# CORS — permetti richieste da Google Apps Script
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Restringe a script.googleusercontent.com in produzione
    allow_methods=["GET", "POST", "PUT"],
    allow_headers=["*"],
)

brain = Brain()


# ─────────────────────────────────────────────
# AUTH
# ─────────────────────────────────────────────

def verify_secret(x_api_secret: str = Header(...)):
    if x_api_secret != API_SECRET:
        raise HTTPException(status_code=401, detail="Non autorizzato")
    return True


# ─────────────────────────────────────────────
# MODELLI REQUEST/RESPONSE
# ─────────────────────────────────────────────

class EventCreate(BaseModel):
    description: str
    feeling_level: int  # 1-6
    reaction_level: int  # 1-6
    tags: List[str] = []

class QuestionAnswer(BaseModel):
    question_id: str
    answer: str

class MoodUpdate(BaseModel):
    level: int  # 1-5
    message: str = ""

class ProfileUpdate(BaseModel):
    field: str
    value: str


# ─────────────────────────────────────────────
# HEALTH CHECK
# ─────────────────────────────────────────────

@app.get("/health")
def health():
    try:
        brain.test_connection()
        return {"status": "ok", "neo4j": "connected"}
    except Exception as e:
        raise HTTPException(status_code=503, detail=f"Neo4j non raggiungibile: {e}")


# ─────────────────────────────────────────────
# UTENTE
# ─────────────────────────────────────────────

@app.get("/api/user")
def get_user(_: bool = Depends(verify_secret)):
    """Ritorna il profilo completo dell'utente."""
    user = brain.get_user(YOUR_TELEGRAM_ID)
    if not user:
        raise HTTPException(status_code=404, detail="Utente non trovato")
    return user

@app.put("/api/user/profile")
def update_profile(body: ProfileUpdate, _: bool = Depends(verify_secret)):
    """Aggiorna un campo del profilo."""
    brain.update_user_field(YOUR_TELEGRAM_ID, body.field, body.value)
    return {"ok": True}

@app.get("/api/user/context")
def get_context(_: bool = Depends(verify_secret)):
    """Contesto completo per l'AI (debug/dashboard avanzata)."""
    return brain.get_full_context(YOUR_TELEGRAM_ID)

@app.get("/api/user/stats")
def get_stats(_: bool = Depends(verify_secret)):
    """Statistiche per la dashboard."""
    user = brain.get_user(YOUR_TELEGRAM_ID) or {}
    moods = brain.get_recent_moods(YOUR_TELEGRAM_ID, days=30)
    events = brain.get_recent_events(YOUR_TELEGRAM_ID, days=30)
    patterns = brain.get_stress_patterns(YOUR_TELEGRAM_ID)

    mood_levels = [m.get("level", 3) for m in moods]
    feeling_levels = [e.get("feeling_level", 3) for e in events]

    return {
        "current_day": user.get("current_day", 1),
        "streak": user.get("streak", 0),
        "total_events": len(events),
        "total_moods": len(moods),
        "avg_mood_30d": round(sum(mood_levels) / len(mood_levels), 1) if mood_levels else 3.0,
        "avg_feeling_30d": round(sum(feeling_levels) / len(feeling_levels), 1) if feeling_levels else 3.0,
        "patterns": patterns,
    }


# ─────────────────────────────────────────────
# EVENTI
# ─────────────────────────────────────────────

@app.post("/api/events")
def create_event(body: EventCreate, _: bool = Depends(verify_secret)):
    """Salva un nuovo evento nel diario."""
    if not (1 <= body.feeling_level <= 6) or not (1 <= body.reaction_level <= 6):
        raise HTTPException(status_code=400, detail="Livelli devono essere 1-6")

    event_id = brain.save_event(
        telegram_id=YOUR_TELEGRAM_ID,
        description=body.description,
        feeling_level=body.feeling_level,
        reaction_level=body.reaction_level,
        tags=body.tags,
    )
    return {"event_id": event_id, "ok": True}

@app.get("/api/events")
def list_events(days: int = 7, _: bool = Depends(verify_secret)):
    """Lista eventi recenti."""
    return brain.get_recent_events(YOUR_TELEGRAM_ID, days=days)

@app.get("/api/events/today")
def today_events(_: bool = Depends(verify_secret)):
    return brain.get_today_events(YOUR_TELEGRAM_ID)


# ─────────────────────────────────────────────
# MOOD
# ─────────────────────────────────────────────

@app.post("/api/mood")
def record_mood(body: MoodUpdate, _: bool = Depends(verify_secret)):
    if not (1 <= body.level <= 5):
        raise HTTPException(status_code=400, detail="Livello deve essere 1-5")
    brain.record_mood(YOUR_TELEGRAM_ID, body.level, body.message, source="webapp")
    return {"ok": True}

@app.get("/api/mood/recent")
def recent_moods(days: int = 7, _: bool = Depends(verify_secret)):
    return brain.get_recent_moods(YOUR_TELEGRAM_ID, days=days)


# ─────────────────────────────────────────────
# DOMANDE AI
# ─────────────────────────────────────────────

@app.get("/api/question/today")
def get_today_question(_: bool = Depends(verify_secret)):
    """Ritorna la domanda AI di oggi (o ne genera una se non esiste)."""
    question = brain.get_today_question(YOUR_TELEGRAM_ID)
    if question:
        return question

    # Genera nuova domanda — fallback se Gemini non risponde
    try:
        context = brain.get_full_context(YOUR_TELEGRAM_ID)
        text = generate_morning_question(context)
        question_id = brain.save_question(YOUR_TELEGRAM_ID, text, "ondemand")
        return {"question_id": question_id, "text": text, "type": "ondemand", "answer": None}
    except Exception as e:
        logger.error(f"Gemini question error: {e}")
        return {
            "question_id": None,
            "text": "Cosa hai rimandato oggi che potevi fare adesso?",
            "type": "fallback",
            "answer": None,
        }

@app.post("/api/question/answer")
def answer_question(body: QuestionAnswer, _: bool = Depends(verify_secret)):
    """Salva la risposta alla domanda di oggi."""
    brain.answer_question(YOUR_TELEGRAM_ID, body.question_id, body.answer)
    return {"ok": True}


# ─────────────────────────────────────────────
# AI ON-DEMAND
# ─────────────────────────────────────────────

@app.get("/api/ai/one-percent")
def one_percent(_: bool = Depends(verify_secret)):
    """Genera il suggerimento 1% del giorno."""
    try:
        context = brain.get_full_context(YOUR_TELEGRAM_ID)
        suggestion = generate_one_percent_suggestion(context)
        return {"suggestion": suggestion}
    except Exception as e:
        logger.error(f"Gemini one-percent error: {e}")
        return {"suggestion": "🎯 Fai una cosa che hai rimandato da più di 3 giorni.\n💡 L'azione piccola rompe il blocco."}

@app.post("/api/ai/chat")
def ai_chat(body: dict, _: bool = Depends(verify_secret)):
    """Chat conversazionale con l'AI coach."""
    message = body.get("message", "")
    if not message:
        raise HTTPException(status_code=400, detail="Messaggio vuoto")
    try:
        context = brain.get_full_context(YOUR_TELEGRAM_ID)
        reply = generate_conversation_reply(message, context)
        return {"reply": reply}
    except Exception as e:
        logger.error(f"Gemini chat error: {e}")
        return {"reply": "Il coach è momentaneamente offline. Riprova tra qualche minuto."}
