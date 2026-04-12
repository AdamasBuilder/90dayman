# Uomo in 90 Giorni - Telegram Bot Coach

Bot Telegram che funge da coach stoico personale, inviando sfide, citazioni e promemoria quotidiani.

## Funzionalità

- 🤖 Coach stoico automatico
- 🌅 Notifiche mattutine con sfide
- 🌙 Riflessioni serali
- 💭 Citazioni di Marco Aurelio, Seneca, Epitteto
- 📊 Tracking progressi (90 giorni)
- 🔗 Link diretto all'app web per azioni complete

## Setup

### 1. Crea un bot Telegram

1. Apri Telegram e cerca @BotFather
2. Invia `/newbot`
3. Segui le istruzioni e copia il token

### 2. Configura su Hostinger

1. Carica i file nella cartella `telegram_bot/`
2. Crea un ambiente virtuale:
   ```bash
   python3 -m venv venv
   source venv/bin/activate  # Linux
   venv\Scripts\activate     # Windows
   ```
3. Installa dipendenze:
   ```bash
   pip install -r requirements.txt
   ```
4. Imposta le variabili d'ambiente:
   ```bash
   export TELEGRAM_BOT_TOKEN="il_tuo_token"
   export WEB_APP_URL="https://tuodominio.com"
   ```
5. Avvia il bot:
   ```bash
   python bot.py
   ```

### 3. Configura il bot come servizio systemd (Linux)

Crea `/etc/systemd/system/stoic-bot.service`:

```ini
[Unit]
Description=Stoic Coach Bot
After=network.target

[Service]
Type=simple
User=tuo_user
WorkingDirectory=/path/to/telegram_bot
Environment=TELEGRAM_BOT_TOKEN=il_tuo_token
Environment=WEB_APP_URL=https://tuodominio.com
ExecStart=/path/to/telegram_bot/venv/bin/python bot.py
Restart=always

[Install]
WantedBy=multi-user.target
```

Attiva:
```bash
sudo systemctl enable stoic-bot
sudo systemctl start stoic-bot
```

## Comandi del Bot

| Comando | Descrizione |
|---------|-------------|
| `/start` | Benvenuto e overview |
| `/sfida` | Nuova sfida quotidiana |
| `/cita` | Citazione stoica random |
| `/mattina` | Domanda del mattino |
| `/sera` | Riflessione della sera |
| `/progresso` | I tuoi progressi |
| `/aiuto` | Guida completa |

## Architettura

```
telegram_bot/
├── bot.py           # Codice principale del bot
├── requirements.txt # Dipendenze Python
├── stoic_coach.db   # Database SQLite (generato automaticamente)
└── README.md        # Questa guida
```

## Notifiche Automatiche

- **08:00** - Buongiorno + citazione + sfida
- **21:00** - Riflessione serale

## Personalizzazione

Puoi modificare:
- `QUOTES` - Aggiungere citazioni
- `CHALLENGES` - Aggiungere sfide
- `MORNING_QUESTIONS` / `EVENING_QUESTIONS` - Domande
- Orari delle notifiche in `setup_scheduler()`
