"""
Bot Telegram principale — Mental Coach Stoico.
Usa i moduli separati: brain.py, gemini_service.py, adaptive_scheduler.py
"""
import logging
import random
from telegram import Update, InlineKeyboardButton, InlineKeyboardMarkup
from telegram.ext import (
    Application,
    CommandHandler,
    CallbackQueryHandler,
    MessageHandler,
    ContextTypes,
    filters,
)
from brain import Brain
from gemini_service import generate_conversation_reply, generate_one_percent_suggestion
from adaptive_scheduler import setup_scheduler
from config import TELEGRAM_BOT_TOKEN, YOUR_TELEGRAM_ID, WEB_APP_URL, validate

logging.basicConfig(
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s",
    level=logging.INFO,
)
logger = logging.getLogger(__name__)

brain = Brain()

# ─────────────────────────────────────────────
# CITAZIONI STOICHE
# ─────────────────────────────────────────────

QUOTES = [
    ("La vita dell'uomo è ciò che i suoi pensieri fanno di lui.", "Marco Aurelio"),
    ("Hai potere sulla tua mente, non sugli eventi esterni.", "Marco Aurelio"),
    ("Memento mori. Ricorda che morirai; questo è il pensiero che libera.", "Marco Aurelio"),
    ("Non è perché le cose sono difficili che non osiamo.", "Seneca"),
    ("La vita breve se la usiamo bene, è sufficientemente lunga.", "Seneca"),
    ("Gli uomini non sono disturbati dalle cose, ma dai loro giudizi.", "Epitteto"),
    ("Non chiedere che le cose accadano come vuoi, ma vuoi le cose come accadono.", "Epitteto"),
]

# ─────────────────────────────────────────────
# ANALISI UMORE DAL TESTO
# ─────────────────────────────────────────────

MOOD_KEYWORDS = {
    1: ["pessima", "schifo", "merda", "catastrofe", "distrutto", "fallito", "odia"],
    2: ["male", "triste", "deluso", "frustrato", "stanco", "demotivato", "solo", "piangere"],
    3: ["così così", "meh", "normale", "non male", "potrebbe andare"],
    4: ["bene", "contento", "buono", "soddisfatto", "ok"],
    5: ["benissimo", "fantastico", "top", "euforico", "incredibile", "felice"],
}

def detect_mood(text: str) -> int:
    text_lower = text.lower()
    for level, keywords in MOOD_KEYWORDS.items():
        if any(k in text_lower for k in keywords):
            return level
    return 3


# ─────────────────────────────────────────────
# HANDLER: /start
# ─────────────────────────────────────────────

async def start_command(update: Update, context: ContextTypes.DEFAULT_TYPE):
    user = update.effective_user
    brain.init_user(user.id, user.first_name)
    profile = brain.get_user(user.id) or {}

    day = profile.get("current_day", 1)
    streak = profile.get("streak", 0)

    text = (
        f"🏛️ <b>Ciao {user.first_name}!</b>\n\n"
        f"Giorno <b>{day}/90</b> — Streak: {streak} giorni\n\n"
        f"Sono il tuo coach stoico. Non sono qui per compiaccerti.\n"
        f"Sono qui per aiutarti a diventare chi hai detto di voler essere.\n\n"
        f"<b>Comandi:</b>\n"
        f"/sfida — Sfida del giorno\n"
        f"/stats — I tuoi progressi\n"
        f"/oggi — Come stai oggi?\n"
        f"/percento — Il tuo 1% per domani\n\n"
        f"<i>Oppure scrivimi direttamente.</i>"
    )

    keyboard = InlineKeyboardMarkup([
        [InlineKeyboardButton("🎯 Sfida ora", callback_data="challenge")],
        [InlineKeyboardButton("📊 Dashboard", url=WEB_APP_URL)],
    ])

    await update.message.reply_text(text, parse_mode="HTML", reply_markup=keyboard)


# ─────────────────────────────────────────────
# HANDLER: /sfida
# ─────────────────────────────────────────────

async def challenge_command(update: Update, context: ContextTypes.DEFAULT_TYPE):
    challenges = [
        "Chiama qualcuno a cui non parli da troppo tempo. Non rimandare.",
        "Scrivi 3 cose che puoi controllare in questa situazione. Solo quelle.",
        "Fai UNA cosa che eviti da giorni. Solo quella. Poi fermati.",
        "Identifica la tua emozione dominante di oggi. Dàlle un nome preciso.",
        "Muoviti per 15 minuti. Adesso. Non dopo.",
        "Di' no a qualcosa che non vuoi fare oggi.",
        "Scrivi: cosa hai fatto oggi che il 'te ideale in 90gg' avrebbe fatto?",
    ]

    text = (
        f"🎯 <b>LA TUA SFIDA</b>\n\n"
        f"<i>{random.choice(challenges)}</i>\n\n"
        f"Non deve essere perfetta. Deve essere fatta."
    )

    keyboard = InlineKeyboardMarkup([
        [InlineKeyboardButton("✅ Fatta!", callback_data="challenge_done")],
        [InlineKeyboardButton("🔄 Un'altra", callback_data="challenge")],
    ])

    target = update.message or update.callback_query.message
    await target.reply_text(text, parse_mode="HTML", reply_markup=keyboard)


# ─────────────────────────────────────────────
# HANDLER: /stats
# ─────────────────────────────────────────────

async def stats_command(update: Update, context: ContextTypes.DEFAULT_TYPE):
    user_id = update.effective_user.id
    profile = brain.get_user(user_id) or {}
    moods = brain.get_recent_moods(user_id, days=7)

    day = profile.get("current_day", 1)
    streak = profile.get("streak", 0)
    progress_pct = round((day / 90) * 100)

    if moods:
        levels = [m.get("level", 3) for m in moods]
        avg = round(sum(levels) / len(levels), 1)
        trend = "↗️ miglioramento" if levels[0] > levels[-1] else "↘️ calo" if levels[0] < levels[-1] else "➡️ stabile"
    else:
        avg, trend = 3.0, "➡️ stabile"

    # Barra progresso visiva
    filled = round(progress_pct / 10)
    bar = "█" * filled + "░" * (10 - filled)

    text = (
        f"📊 <b>I TUOI 90 GIORNI</b>\n\n"
        f"Giorno: <b>{day}/90</b> ({progress_pct}%)\n"
        f"[{bar}]\n\n"
        f"🔥 Streak: {streak} giorni\n"
        f"😊 Umore medio (7gg): {avg}/5\n"
        f"📈 Trend: {trend}\n"
        f"📝 Interazioni settimana: {len(moods)}"
    )

    keyboard = InlineKeyboardMarkup([
        [InlineKeyboardButton("📊 Dashboard completa", url=WEB_APP_URL)],
    ])

    await update.message.reply_text(text, parse_mode="HTML", reply_markup=keyboard)


# ─────────────────────────────────────────────
# HANDLER: /percento
# ─────────────────────────────────────────────

async def percento_command(update: Update, context: ContextTypes.DEFAULT_TYPE):
    user_id = update.effective_user.id
    await update.message.reply_text("⏳ Sto analizzando i tuoi pattern...")

    try:
        ctx = brain.get_full_context(user_id)
        suggestion = generate_one_percent_suggestion(ctx)
        await update.message.reply_text(suggestion, parse_mode="HTML")
    except Exception as e:
        logger.error(f"Errore 1%: {e}")
        await update.message.reply_text("Errore nella generazione. Riprova tra poco.")


# ─────────────────────────────────────────────
# HANDLER: MESSAGGI LIBERI
# ─────────────────────────────────────────────

async def handle_message(update: Update, context: ContextTypes.DEFAULT_TYPE):
    user = update.effective_user
    text = update.message.text

    brain.init_user(user.id, user.first_name)

    # Rileva umore e registra
    mood_level = detect_mood(text)
    brain.record_mood(user.id, mood_level, text)

    # Genera risposta AI contestuale
    try:
        ctx = brain.get_full_context(user.id)
        reply = generate_conversation_reply(text, ctx)
    except Exception as e:
        logger.error(f"Errore reply AI: {e}")
        reply = "Capito. Continua — ti ascolto."

    # Citazione stoica: 25% delle volte
    if random.random() < 0.25:
        quote_text, author = random.choice(QUOTES)
        reply += f'\n\n💭 <i>"{quote_text}"</i>\n— {author}'

    keyboard = InlineKeyboardMarkup([
        [InlineKeyboardButton("📊 Dashboard", url=WEB_APP_URL)],
    ])

    await update.message.reply_text(reply, parse_mode="HTML", reply_markup=keyboard)


# ─────────────────────────────────────────────
# HANDLER: CALLBACK BUTTONS
# ─────────────────────────────────────────────

async def button_callback(update: Update, context: ContextTypes.DEFAULT_TYPE):
    query = update.callback_query
    await query.answer()

    if query.data == "challenge":
        await challenge_command(update, context)
    elif query.data == "challenge_done":
        user_id = query.from_user.id
        brain.record_mood(user_id, 4, "Sfida completata", source="challenge")
        await query.message.reply_text("🏆 Fatto. Ogni azione conta. Domani un'altra.")
    elif query.data.startswith("quick_mood_"):
        level = int(query.data.split("_")[-1])
        brain.record_mood(query.from_user.id, level, f"Quick mood: {level}/5")
        emojis = {1: "😔", 2: "😟", 3: "😐", 4: "😊", 5: "🔥"}
        await query.message.reply_text(f"Registrato {emojis.get(level, '✓')} — continua così.")
    elif query.data == "answer_morning":
        await query.message.reply_text("Scrivi la tua risposta — ti ascolto.")
    elif query.data == "answer_evening":
        await query.message.reply_text("Scrivi la tua riflessione sulla giornata.")
    elif query.data == "dismiss":
        await query.message.reply_text("Ok. Ma ci riparliamo domani. 💪")


# ─────────────────────────────────────────────
# MAIN
# ─────────────────────────────────────────────

def main():
    # Valida configurazione
    validate()

    # Test connessione Neo4j
    try:
        brain.test_connection()
        logger.info("✅ Neo4j connesso")
    except Exception as e:
        logger.error(f"❌ Neo4j errore: {e}")
        return

    # Costruisci app Telegram
    app = Application.builder().token(TELEGRAM_BOT_TOKEN).build()

    # Registra handler
    app.add_handler(CommandHandler("start", start_command))
    app.add_handler(CommandHandler("sfida", challenge_command))
    app.add_handler(CommandHandler("stats", stats_command))
    app.add_handler(CommandHandler("oggi", start_command))
    app.add_handler(CommandHandler("percento", percento_command))
    app.add_handler(CallbackQueryHandler(button_callback))
    app.add_handler(MessageHandler(filters.TEXT & ~filters.COMMAND, handle_message))

    # Avvia scheduler adattivo
    setup_scheduler(app)

    logger.info("🧠 Mental Coach Stoico avviato!")
    app.run_polling(drop_pending_updates=True)


if __name__ == "__main__":
    main()
