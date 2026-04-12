#!/bin/bash
# ─────────────────────────────────────────────────────────────
# start.sh — Avvio Mental Coach Stoico su server Linux
# Uso: bash start.sh
# ─────────────────────────────────────────────────────────────

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "═══════════════════════════════════════════"
echo "  🏛️  Mental Coach Stoico — Avvio Sistema  "
echo "═══════════════════════════════════════════"

# Verifica .env
if [ ! -f ".env" ]; then
    echo "❌ File .env non trovato!"
    echo "   Copia .env.example in .env e compila le credenziali."
    exit 1
fi

# Verifica venv
if [ ! -d "venv" ]; then
    echo "📦 Creazione virtual environment..."
    python3 -m venv venv
fi

# Attiva venv e installa dipendenze
echo "📦 Installazione dipendenze..."
source venv/bin/activate
pip install -q -r requirements.txt

echo ""
echo "✅ Dipendenze OK"
echo "🚀 Avvio Bot + API..."
echo ""

# Avvia il processo principale
python start.py
