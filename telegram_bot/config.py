"""
Configurazione centralizzata — legge da variabili d'ambiente.
Crea un file .env nella stessa cartella con le tue credenziali.
"""
import os
from dotenv import load_dotenv

load_dotenv()

# Telegram
TELEGRAM_BOT_TOKEN = os.getenv("TELEGRAM_BOT_TOKEN", "")
YOUR_TELEGRAM_ID = int(os.getenv("YOUR_TELEGRAM_ID", "0"))

# Neo4j
NEO4J_URI = os.getenv("NEO4J_URI", "")
NEO4J_USER = os.getenv("NEO4J_USER", "")
NEO4J_PASSWORD = os.getenv("NEO4J_PASSWORD", "")
NEO4J_DATABASE = os.getenv("NEO4J_DATABASE", "")

# Gemini
GEMINI_API_KEY = os.getenv("GEMINI_API_KEY", "")
GEMINI_MODEL = "gemini-1.5-flash"
GEMINI_ENDPOINT = f"https://generativelanguage.googleapis.com/v1beta/models/{GEMINI_MODEL}:generateContent"

# Web App (Google Apps Script URL — da aggiornare dopo deploy GAS)
WEB_APP_URL = os.getenv("WEB_APP_URL", "https://script.google.com/macros/s/YOUR_DEPLOYMENT_ID/exec")

# API interna (FastAPI)
API_HOST = os.getenv("API_HOST", "0.0.0.0")
API_PORT = int(os.getenv("API_PORT", "8000"))
API_SECRET = os.getenv("API_SECRET", "change-this-secret-key")

# Validazione avvio
def validate():
    errors = []
    if not TELEGRAM_BOT_TOKEN:
        errors.append("TELEGRAM_BOT_TOKEN mancante")
    if not NEO4J_PASSWORD:
        errors.append("NEO4J_PASSWORD mancante")
    if not GEMINI_API_KEY:
        errors.append("GEMINI_API_KEY mancante")
    if not YOUR_TELEGRAM_ID:
        errors.append("YOUR_TELEGRAM_ID mancante")
    if errors:
        raise ValueError(f"Configurazione incompleta:\n" + "\n".join(f"  - {e}" for e in errors))
