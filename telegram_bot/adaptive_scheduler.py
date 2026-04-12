"""
Scheduler adattivo — non manda messaggi fissi a orari fissi.
Valuta il contesto reale dell'utente e decide quando e cosa inviare.
"""
import logging
import random
from apscheduler.schedulers.asyncio import AsyncIOScheduler
from telegram import InlineKeyboardButton, InlineKeyboardMarkup
from brain import Brain
from gemini_service import (
    generate_morning_question,
    generate_evening_reflection,
    generate_one_percent_suggestion,
    generate_adaptive_nudge,
)
from config import YOUR_TELEGRAM_ID, WEB_APP_URL

logger = logging.getLogger(__name__)

brain = Brain()
bot_app = None  # Impostato all'avvio


def _keyboard(include_app_link: bool = True) -> InlineKeyboardMarkup:
    buttons = [
        [InlineKeyboardButton("😊 Sto bene", callback_data="quick_mood_4")],
        [InlineKeyboardButton("😐 Così così", callback_data="quick_mood_3")],
        [InlineKeyboardButton("😔 Non bene", callback_data="quick_mood_1")],
    ]
    if include_app_link:
        buttons.append([InlineKeyboardButton("📊 Apri Dashboard", url=WEB_APP_URL)])
    return InlineKeyboardMarkup(buttons)


async def _send(text: str, reply_markup=None, parse_mode="HTML"):
    if not bot_app or not YOUR_TELEGRAM_ID:
        return
    try:
        await bot_app.bot.send_message(
            chat_id=YOUR_TELEGRAM_ID,
            text=text,
            parse_mode=parse_mode,
            reply_markup=reply_markup,
        )
    except Exception as e:
        logger.error(f"Errore invio messaggio: {e}")


# ─────────────────────────────────────────────
# JOB: MATTINA (ore 8:30)
# ─────────────────────────────────────────────

async def job_morning_checkin():
    """Check-in mattutino con domanda AI personalizzata."""
    logger.info("⏰ Job mattina avviato")
    try:
        context = brain.get_full_context(YOUR_TELEGRAM_ID)
        user = context["user"]
        question = generate_morning_question(context)

        # Salva la domanda nel graph
        brain.save_question(YOUR_TELEGRAM_ID, question, "morning")

        # Incrementa il giorno
        brain.increment_day(YOUR_TELEGRAM_ID)

        text = (
            f"☀️ <b>Giorno {user['current_day']} di 90</b>\n"
            f"Streak: {user['streak']} giorni 🔥\n\n"
            f"<i>{question}</i>\n\n"
            f"Rispondimi qui, o registra nella dashboard."
        )

        keyboard = InlineKeyboardMarkup([
            [InlineKeyboardButton("📝 Rispondi", callback_data="answer_morning")],
            [InlineKeyboardButton("📊 Dashboard", url=WEB_APP_URL)],
        ])

        await _send(text, reply_markup=keyboard)
    except Exception as e:
        logger.error(f"Errore job mattina: {e}")


# ─────────────────────────────────────────────
# JOB: SERA (ore 21:00)
# ─────────────────────────────────────────────

async def job_evening_reflection():
    """Riflessione serale + suggerimento 1%."""
    logger.info("⏰ Job sera avviato")
    try:
        context = brain.get_full_context(YOUR_TELEGRAM_ID)
        reflection = generate_evening_reflection(context)
        one_percent = generate_one_percent_suggestion(context)

        text = (
            f"🌙 <b>Riflessione della sera</b>\n\n"
            f"<i>{reflection}</i>\n\n"
            f"─────────────────\n\n"
            f"{one_percent}"
        )

        keyboard = InlineKeyboardMarkup([
            [InlineKeyboardButton("✍️ Scrivi riflessione", callback_data="answer_evening")],
            [InlineKeyboardButton("📊 Dashboard", url=WEB_APP_URL)],
        ])

        await _send(text, reply_markup=keyboard)
    except Exception as e:
        logger.error(f"Errore job sera: {e}")


# ─────────────────────────────────────────────
# JOB: NUDGE ADATTIVO (ogni 2 ore, 10:00-20:00)
# ─────────────────────────────────────────────

async def job_adaptive_nudge():
    """
    Valuta la situazione e decide SE e COSA inviare.
    Non manda sempre un messaggio — solo quando ha senso.
    """
    try:
        status = brain.get_engagement_status(YOUR_TELEGRAM_ID)
        context = brain.get_full_context(YOUR_TELEGRAM_ID)

        # Milestone streak → celebra
        if status["streak_milestone"]:
            streak = status["streak"]
            text = (
                f"🏆 <b>{streak} giorni consecutivi!</b>\n\n"
                f"Questa non è fortuna. È disciplina.\n"
                f"Marco Aurelio avrebbe approvato. Vai avanti."
            )
            await _send(text)
            return

        # Umore basso → supporto + domanda
        if status["needs_support"]:
            message = generate_adaptive_nudge(context, "low_mood")
            await _send(message, reply_markup=_keyboard())
            return

        # Silenzioso da troppo → rompi le scatole
        if status["needs_nudge"]:
            message = generate_adaptive_nudge(context, "silent_too_long")
            await _send(message, reply_markup=_keyboard())
            return

        # Altrimenti: niente messaggio (non spammare)
        logger.info(f"⏭ Nudge saltato — utente attivo ({status['hours_silent']}h fa)")

    except Exception as e:
        logger.error(f"Errore adaptive nudge: {e}")


# ─────────────────────────────────────────────
# JOB: POMERIGGIO (ore 14:00 — check veloce)
# ─────────────────────────────────────────────

async def job_afternoon_check():
    """Domanda veloce di metà giornata."""
    try:
        status = brain.get_engagement_status(YOUR_TELEGRAM_ID)

        # Manda solo se non si è fatto vivo da stamattina
        if status["hours_silent"] < 4:
            logger.info("⏭ Check pomeridiano saltato — già attivo oggi")
            return

        questions = [
            "Come sta andando oggi?",
            "Metà giornata: sei dove volevi essere?",
            "Una cosa buona successa stamattina?",
            "Stai avanzando verso il tuo obiettivo?",
        ]

        text = f"⚡ <b>{random.choice(questions)}</b>"
        await _send(text, reply_markup=_keyboard(include_app_link=False))

    except Exception as e:
        logger.error(f"Errore check pomeridiano: {e}")


# ─────────────────────────────────────────────
# SETUP SCHEDULER
# ─────────────────────────────────────────────

def setup_scheduler(application) -> AsyncIOScheduler:
    """
    Configura e avvia lo scheduler.
    Chiama questa funzione passando l'app Telegram.
    """
    global bot_app
    bot_app = application

    scheduler = AsyncIOScheduler(timezone="Europe/Rome")

    # Mattina: 8:30
    scheduler.add_job(job_morning_checkin, "cron", hour=8, minute=30, id="morning")

    # Pomeriggio: 14:00
    scheduler.add_job(job_afternoon_check, "cron", hour=14, minute=0, id="afternoon")

    # Sera: 21:00
    scheduler.add_job(job_evening_reflection, "cron", hour=21, minute=0, id="evening")

    # Nudge adattivo: 11:00, 16:00, 18:30
    scheduler.add_job(job_adaptive_nudge, "cron", hour=11, minute=0, id="nudge_11")
    scheduler.add_job(job_adaptive_nudge, "cron", hour=16, minute=0, id="nudge_16")
    scheduler.add_job(job_adaptive_nudge, "cron", hour=18, minute=30, id="nudge_18")

    scheduler.start()
    logger.info("✅ Scheduler adattivo avviato (fuso orario: Europe/Rome)")
    return scheduler
