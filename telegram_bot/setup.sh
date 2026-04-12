#!/bin/bash
# Script di setup per Hostinger

echo "🏛️ Setup Stoic Coach Bot per Hostinger"
echo "========================================"

# Verifica Python
if ! command -v python3 &> /dev/null; then
    echo "❌ Python3 non trovato. Installa Python 3.8+"
    exit 1
fi

echo "✅ Python3 trovato"

# Crea virtual environment
if [ ! -d "venv" ]; then
    echo "📦 Creando virtual environment..."
    python3 -m venv venv
fi

# Attiva venv
echo "🔄 Attivando virtual environment..."
source venv/bin/activate

# Installa dipendenze
echo "📥 Installando dipendenze..."
pip install -r requirements.txt

# Verifica variabili
echo ""
echo "⚙️  Configurazione"
echo "------------------"

if [ -z "$TELEGRAM_BOT_TOKEN" ]; then
    echo -n "Inserisci il Token del Bot Telegram: "
    read -r token
    export TELEGRAM_BOT_TOKEN="$token"
fi

if [ -z "$WEB_APP_URL" ]; then
    echo -n "Inserisci l'URL della Web App: "
    read -r url
    export WEB_APP_URL="$url"
fi

echo ""
echo "✅ Setup completo!"
echo ""
echo "Per avviare il bot:"
echo "  source venv/bin/activate"
echo "  export TELEGRAM_BOT_TOKEN=\"$TELEGRAM_BOT_TOKEN\""
echo "  export WEB_APP_URL=\"$WEB_APP_URL\""
echo "  python bot.py"
echo ""
echo "Oppure usa:"
echo "  ./run.sh"
