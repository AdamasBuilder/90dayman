#!/bin/bash
# Avvio rapido del bot

source venv/bin/activate
export TELEGRAM_BOT_TOKEN="${TELEGRAM_BOT_TOKEN}"
export WEB_APP_URL="${WEB_APP_URL}"
python bot.py
