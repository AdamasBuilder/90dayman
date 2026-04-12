"""
Punto di avvio unificato — lancia Bot Telegram + FastAPI nella stessa
event loop asyncio. Un solo processo, un solo server.
"""
import asyncio
import logging
import uvicorn
from telegram.ext import Application, CommandHandler, CallbackQueryHandler, MessageHandler, filters

# Import moduli interni
from config import TELEGRAM_BOT_TOKEN, validate
from brain import Brain
from adaptive_scheduler import setup_scheduler
import api as api_module  # FastAPI app

# Import handler dal bot
from bot import (
    start_command,
    challenge_command,
    stats_command,
    percento_command,
    handle_message,
    button_callback,
)

logging.basicConfig(
    format="%(asctime)s [%(levelname)s] %(name)s: %(message)s",
    level=logging.INFO,
)
logger = logging.getLogger(__name__)


async def run_bot(tg_app: Application):
    """Avvia il polling Telegram in modo asincrono."""
    await tg_app.initialize()
    await tg_app.start()
    logger.info("🤖 Bot Telegram avviato (polling)")
    await tg_app.updater.start_polling(drop_pending_updates=True)


async def run_api():
    """Avvia FastAPI/uvicorn in modo asincrono."""
    config = uvicorn.Config(
        app=api_module.app,
        host="0.0.0.0",
        port=8000,
        log_level="warning",  # Riduce rumore nei log
    )
    server = uvicorn.Server(config)
    logger.info("🌐 FastAPI avviato su http://0.0.0.0:8000")
    await server.serve()


async def main():
    # 1. Valida configurazione e connessioni
    validate()
    brain = Brain()
    brain.test_connection()
    logger.info("✅ Neo4j connesso")

    # 2. Costruisci app Telegram
    tg_app = Application.builder().token(TELEGRAM_BOT_TOKEN).build()
    tg_app.add_handler(CommandHandler("start", start_command))
    tg_app.add_handler(CommandHandler("sfida", challenge_command))
    tg_app.add_handler(CommandHandler("stats", stats_command))
    tg_app.add_handler(CommandHandler("oggi", start_command))
    tg_app.add_handler(CommandHandler("percento", percento_command))
    tg_app.add_handler(CallbackQueryHandler(button_callback))
    tg_app.add_handler(MessageHandler(filters.TEXT & ~filters.COMMAND, handle_message))

    # 3. Scheduler adattivo (usa lo stesso bot_app)
    setup_scheduler(tg_app)

    # 4. Avvia tutto in parallelo nella stessa event loop
    logger.info("🚀 Mental Coach Stoico — avvio sistema completo")
    await asyncio.gather(
        run_bot(tg_app),
        run_api(),
    )


if __name__ == "__main__":
    asyncio.run(main())
