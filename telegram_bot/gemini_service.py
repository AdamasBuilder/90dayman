"""
Servizio Gemini AI — genera domande personalizzate, riflessioni,
suggerimenti 1% basati sul contesto completo dell'utente.
"""
import json
import logging
import urllib.request
import urllib.error
from config import GEMINI_API_KEY, GEMINI_ENDPOINT

logger = logging.getLogger(__name__)


def _call_gemini(prompt: str, temperature: float = 0.8) -> str:
    """Chiamata HTTP diretta a Gemini API (nessuna dipendenza esterna)."""
    url = f"{GEMINI_ENDPOINT}?key={GEMINI_API_KEY}"
    payload = {
        "contents": [{"parts": [{"text": prompt}]}],
        "generationConfig": {
            "temperature": temperature,
            "maxOutputTokens": 300,
            "topP": 0.9,
        }
    }
    data = json.dumps(payload).encode("utf-8")
    req = urllib.request.Request(
        url,
        data=data,
        headers={"Content-Type": "application/json"},
        method="POST"
    )
    try:
        with urllib.request.urlopen(req, timeout=15) as resp:
            result = json.loads(resp.read().decode("utf-8"))
            return result["candidates"][0]["content"]["parts"][0]["text"].strip()
    except urllib.error.HTTPError as e:
        body = e.read().decode("utf-8")
        logger.error(f"Gemini HTTP error {e.code}: {body}")
        raise
    except Exception as e:
        logger.error(f"Gemini error: {e}")
        raise


def generate_morning_question(context: dict) -> str:
    """
    Domanda mattutina personalizzata basata sul profilo completo.
    È scomoda, stoica, contestuale.
    """
    user = context.get("user", {})
    mood = context.get("mood", {})
    events = context.get("events", {})
    patterns = context.get("patterns", {})

    name = user.get('name', "l'utente")
    prompt = f"""Sei Marco Aurelio che parla direttamente a {name}.

CONTESTO UTENTE:
- Giorno {user.get('current_day', 1)} di 90
- Streak: {user.get('streak', 0)} giorni consecutivi
- Obiettivo dichiarato: {user.get('goal', 'non specificato')}
- Sfida principale: {user.get('biggest_challenge', 'non specificata')}
- Sé ideale in 90gg: {user.get('ideal_self_90', 'non specificato')}
- Umore medio ultimi 7 giorni: {mood.get('avg_7d', 3)}/5
- Trend: {mood.get('trend', 'stabile')}
- Evento recente più significativo: {events.get('recent_descriptions', ['nessuno'])[0] if events.get('recent_descriptions') else 'nessuno'}
- Pattern stress: {patterns.get('stress_triggers', [])}

Genera UNA SOLA domanda scomoda per questa mattina.
La domanda deve:
1. Essere diretta, quasi brutale nella sua onestà
2. Riferirsi al contesto reale della persona (non generica)
3. Spingere a riflettere su UN'azione concreta oggi
4. Stile stoico: essenziale, senza fronzoli

Rispondi con SOLO la domanda, nessun'altra parola."""

    return _call_gemini(prompt, temperature=0.85)


def generate_evening_reflection(context: dict) -> str:
    """
    Riflessione serale basata sugli eventi del giorno.
    """
    user = context.get("user", {})
    events = context.get("events", {})
    mood = context.get("mood", {})

    today_text = "\n".join(f"- {e}" for e in events.get("today", [])) or "Nessun evento registrato"

    prompt = f"""Sei Seneca. Stai scrivendo a {user.get('name', 'un discepolo')} alla fine del giorno {user.get('current_day', 1)}.

Oggi ha vissuto:
{today_text}

Umore di oggi: {mood.get('current', 3)}/5

Scrivi UNA domanda di riflessione serale che:
1. Faccia i conti con ciò che è successo oggi (non ignorarlo)
2. Colleghi la giornata all'obiettivo dei 90 giorni
3. Prepari mentalmente a domani migliore

Solo la domanda. Nessuna introduzione."""

    return _call_gemini(prompt, temperature=0.75)


def generate_one_percent_suggestion(context: dict) -> str:
    """
    La regola dell'1%: UN miglioramento piccolo e fattibile per domani.
    Basato su pattern reali, non consigli generici.
    """
    user = context.get("user", {})
    mood = context.get("mood", {})
    patterns = context.get("patterns", {})
    events = context.get("events", {})

    stress_triggers = patterns.get("stress_triggers", [])
    triggers_text = ", ".join([t["tag"] for t in stress_triggers[:3]]) if stress_triggers else "non identificati"

    prompt = f"""Sei un coach stoico che applica la regola dell'1%.

PROFILO {user.get('name', '')}:
- Giorno {user.get('current_day', 1)}/90
- Streak: {user.get('streak', 0)} giorni
- Obiettivo: {user.get('goal', '')}
- Principali trigger di stress: {triggers_text}
- Umore medio: {mood.get('avg_7d', 3)}/5
- Trend: {mood.get('trend', 'stabile')}
- Valori core: {user.get('core_values', '')}

Identifica UN SOLO micro-miglioramento per domani.
Regole:
- Deve richiedere massimo 5 minuti
- Deve essere misurabile (si o no, fatto o non fatto)
- Deve colpire direttamente uno dei punti deboli identificati
- NON deve essere vago (no "sii più positivo", sì "chiama X per risolvere Y")

Formato risposta:
🎯 [L'azione specifica in una frase]
💡 [Perché questo cambierà qualcosa - MAX 1 frase]"""

    return _call_gemini(prompt, temperature=0.7)


def generate_adaptive_nudge(context: dict, reason: str) -> str:
    """
    Messaggio proattivo quando il bot vuole 'rompere le scatole'.
    Reason: 'silent_too_long' | 'low_mood' | 'streak_milestone' | 'pattern_detected'
    """
    user = context.get("user", {})
    mood = context.get("mood", {})

    reason_context = {
        "silent_too_long": f"Non si fa vivo da {mood.get('hours_since_last_interaction', '?')} ore",
        "low_mood": f"Umore basso ({mood.get('current', 2)}/5) da un po'",
        "streak_milestone": f"Ha raggiunto {user.get('streak', 0)} giorni di streak",
        "pattern_detected": "È stato identificato un pattern comportamentale ripetuto",
    }.get(reason, "")

    prompt = f"""Sei il coach stoico personale di {user.get('name', 'un utente')}.

Situazione: {reason_context}
Giorno: {user.get('current_day', 1)}/90

Scrivi UN messaggio breve (massimo 3 righe) che:
- Sia diretto e personale (non generico)
- Rompa il silenzio o la situazione in modo costruttivo
- Includa UNA domanda o UNA sfida specifica

Stile: amico che si preoccupa, non un bot. Usa il nome."""

    return _call_gemini(prompt, temperature=0.9)


def generate_conversation_reply(user_message: str, context: dict) -> str:
    """
    Risposta conversazionale intelligente a un messaggio libero.
    """
    user = context.get("user", {})
    mood = context.get("mood", {})

    name = user.get('name', "l'utente")
    prompt = f"""Sei il coach stoico di {name}.

Ha scritto: "{user_message}"

Contesto:
- Giorno {user.get('current_day', 1)}/90
- Umore recente: {mood.get('avg_7d', 3)}/5
- Obiettivo: {user.get('goal', '')}

Rispondi in modo:
1. Umano e diretto (2-4 righe max)
2. Stoico ma non freddo
3. Fai UNA domanda di approfondimento alla fine
4. Se c'è un problema concreto, suggerisci UN'azione

Non iniziare con "Capisco" o "Certo". Vai dritto al punto."""

    return _call_gemini(prompt, temperature=0.85)
