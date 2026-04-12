"""
Brain potenziato — Neo4j con analisi pattern, correlazioni, contesto completo.
Sostituisce la classe Neo4jBrain in bot.py.
"""
import logging
from datetime import datetime
from typing import Optional, List, Dict, Any
from neo4j import GraphDatabase
from config import NEO4J_URI, NEO4J_USER, NEO4J_PASSWORD, NEO4J_DATABASE

logger = logging.getLogger(__name__)


class Brain:
    def __init__(self):
        self.driver = GraphDatabase.driver(
            NEO4J_URI,
            auth=(NEO4J_USER, NEO4J_PASSWORD),
            database=NEO4J_DATABASE
        )

    def close(self):
        self.driver.close()

    def test_connection(self):
        with self.driver.session() as session:
            session.run("RETURN 1")
        return True

    # ─────────────────────────────────────────────
    # UTENTE
    # ─────────────────────────────────────────────

    def init_user(self, telegram_id: int, name: str):
        with self.driver.session() as session:
            session.run("""
                MERGE (u:User {telegram_id: $tid})
                ON CREATE SET
                    u.name = $name,
                    u.created_at = datetime(),
                    u.current_day = 1,
                    u.streak = 0,
                    u.conversation_count = 0,
                    u.profile_complete = false,
                    u.last_seen = datetime()
                ON MATCH SET
                    u.last_seen = datetime()
            """, tid=telegram_id, name=name)

    def get_user(self, telegram_id: int) -> Optional[Dict]:
        with self.driver.session() as session:
            result = session.run("""
                MATCH (u:User {telegram_id: $tid})
                RETURN u
            """, tid=telegram_id)
            record = result.single()
            return dict(record["u"]) if record else None

    def update_user_field(self, telegram_id: int, field: str, value):
        """Aggiorna un campo del profilo utente in modo sicuro."""
        allowed_fields = {
            "name", "goal", "biggest_challenge", "stress_response",
            "core_values", "avoided_things", "ideal_self_90",
            "profile_complete", "streak", "current_day",
            "notification_email", "pain_points", "self_description"
        }
        if field not in allowed_fields:
            raise ValueError(f"Campo '{field}' non consentito")
        with self.driver.session() as session:
            session.run(f"""
                MATCH (u:User {{telegram_id: $tid}})
                SET u.{field} = $value
            """, tid=telegram_id, value=value)

    def increment_day(self, telegram_id: int):
        with self.driver.session() as session:
            session.run("""
                MATCH (u:User {telegram_id: $tid})
                SET u.current_day = COALESCE(u.current_day, 1) + 1,
                    u.streak = COALESCE(u.streak, 0) + 1
            """, tid=telegram_id)

    # ─────────────────────────────────────────────
    # EVENTI
    # ─────────────────────────────────────────────

    def save_event(self, telegram_id: int, description: str,
                   feeling_level: int, reaction_level: int,
                   tags: List[str] = None, ai_reflection: str = None) -> str:
        event_id = f"evt_{telegram_id}_{int(datetime.now().timestamp())}"
        with self.driver.session() as session:
            session.run("""
                MATCH (u:User {telegram_id: $tid})
                CREATE (e:Event {
                    event_id: $eid,
                    description: $desc,
                    feeling_level: $feeling,
                    reaction_level: $reaction,
                    tags: $tags,
                    ai_reflection: $reflection,
                    day_of_week: $dow,
                    hour_of_day: $hour,
                    timestamp: datetime()
                })
                CREATE (u)-[:HAD_EVENT]->(e)
            """,
            tid=telegram_id,
            eid=event_id,
            desc=description,
            feeling=feeling_level,
            reaction=reaction_level,
            tags=tags or [],
            reflection=ai_reflection,
            dow=datetime.now().strftime("%A"),
            hour=datetime.now().hour
            )
        return event_id

    def get_recent_events(self, telegram_id: int, days: int = 7) -> List[Dict]:
        with self.driver.session() as session:
            result = session.run("""
                MATCH (u:User {telegram_id: $tid})-[:HAD_EVENT]->(e:Event)
                WHERE e.timestamp > datetime() - duration({days: $days})
                RETURN e ORDER BY e.timestamp DESC
            """, tid=telegram_id, days=days)
            return [dict(r["e"]) for r in result]

    def get_today_events(self, telegram_id: int) -> List[Dict]:
        with self.driver.session() as session:
            result = session.run("""
                MATCH (u:User {telegram_id: $tid})-[:HAD_EVENT]->(e:Event)
                WHERE e.timestamp > datetime() - duration({hours: 24})
                RETURN e ORDER BY e.timestamp DESC
            """, tid=telegram_id)
            return [dict(r["e"]) for r in result]

    # ─────────────────────────────────────────────
    # MOOD
    # ─────────────────────────────────────────────

    def record_mood(self, telegram_id: int, level: int, message: str, source: str = "telegram"):
        with self.driver.session() as session:
            session.run("""
                MATCH (u:User {telegram_id: $tid})
                CREATE (m:Mood {
                    level: $level,
                    message: $message,
                    source: $source,
                    timestamp: datetime()
                })
                CREATE (u)-[:EXPRESSED]->(m)
                SET u.conversation_count = COALESCE(u.conversation_count, 0) + 1,
                    u.last_seen = datetime()
            """, tid=telegram_id, level=level, message=message, source=source)

    def get_last_mood(self, telegram_id: int) -> Optional[Dict]:
        with self.driver.session() as session:
            result = session.run("""
                MATCH (u:User {telegram_id: $tid})-[:EXPRESSED]->(m:Mood)
                RETURN m ORDER BY m.timestamp DESC LIMIT 1
            """, tid=telegram_id)
            record = result.single()
            return dict(record["m"]) if record else None

    def get_recent_moods(self, telegram_id: int, days: int = 7) -> List[Dict]:
        with self.driver.session() as session:
            result = session.run("""
                MATCH (u:User {telegram_id: $tid})-[:EXPRESSED]->(m:Mood)
                WHERE m.timestamp > datetime() - duration({days: $days})
                RETURN m ORDER BY m.timestamp DESC
            """, tid=telegram_id, days=days)
            return [dict(r["m"]) for r in result]

    # ─────────────────────────────────────────────
    # DOMANDE AI
    # ─────────────────────────────────────────────

    def save_question(self, telegram_id: int, question: str,
                      q_type: str, answer: str = None) -> str:
        q_id = f"q_{telegram_id}_{int(datetime.now().timestamp())}"
        with self.driver.session() as session:
            session.run("""
                MATCH (u:User {telegram_id: $tid})
                CREATE (q:Question {
                    question_id: $qid,
                    text: $text,
                    type: $type,
                    answer: $answer,
                    date: date(),
                    timestamp: datetime()
                })
                CREATE (u)-[:WAS_ASKED]->(q)
            """, tid=telegram_id, qid=q_id, text=question, type=q_type, answer=answer)
        return q_id

    def answer_question(self, telegram_id: int, question_id: str, answer: str):
        with self.driver.session() as session:
            session.run("""
                MATCH (u:User {telegram_id: $tid})-[:WAS_ASKED]->(q:Question {question_id: $qid})
                SET q.answer = $answer,
                    q.answered_at = datetime()
            """, tid=telegram_id, qid=question_id, answer=answer)

    def get_today_question(self, telegram_id: int) -> Optional[Dict]:
        with self.driver.session() as session:
            result = session.run("""
                MATCH (u:User {telegram_id: $tid})-[:WAS_ASKED]->(q:Question)
                WHERE q.date = date()
                RETURN q ORDER BY q.timestamp DESC LIMIT 1
            """, tid=telegram_id)
            record = result.single()
            return dict(record["q"]) if record else None

    # ─────────────────────────────────────────────
    # ANALISI PATTERN (il vero cervello)
    # ─────────────────────────────────────────────

    def get_stress_patterns(self, telegram_id: int) -> Dict:
        """Quando l'utente è più stressato? Quali tag correlano con livelli bassi?"""
        with self.driver.session() as session:
            # Pattern per giorno della settimana
            dow_result = session.run("""
                MATCH (u:User {telegram_id: $tid})-[:EXPRESSED]->(m:Mood)
                WHERE m.timestamp > datetime() - duration({days: 30})
                RETURN m.timestamp.dayOfWeek as dow, avg(m.level) as avg_level
                ORDER BY dow
            """, tid=telegram_id)
            dow_data = [{"day": r["dow"], "avg": round(r["avg_level"], 2)} for r in dow_result]

            # Tag più correlati con eventi negativi
            tags_result = session.run("""
                MATCH (u:User {telegram_id: $tid})-[:HAD_EVENT]->(e:Event)
                WHERE e.feeling_level <= 2
                UNWIND e.tags as tag
                RETURN tag, count(*) as count
                ORDER BY count DESC LIMIT 5
            """, tid=telegram_id)
            stress_tags = [{"tag": r["tag"], "count": r["count"]} for r in tags_result]

            return {
                "day_of_week_pattern": dow_data,
                "stress_triggers": stress_tags
            }

    def get_full_context(self, telegram_id: int) -> Dict:
        """
        Raccoglie TUTTO il contesto necessario per Gemini.
        Questo è ciò che rende le risposte personalizzate.
        """
        user = self.get_user(telegram_id) or {}
        recent_moods = self.get_recent_moods(telegram_id, days=7)
        recent_events = self.get_recent_events(telegram_id, days=7)
        today_events = self.get_today_events(telegram_id)
        patterns = self.get_stress_patterns(telegram_id)
        last_mood = self.get_last_mood(telegram_id)

        # Calcola metriche
        mood_levels = [m.get("level", 3) for m in recent_moods]
        avg_mood = round(sum(mood_levels) / len(mood_levels), 1) if mood_levels else 3.0
        trend = "miglioramento" if len(mood_levels) >= 3 and mood_levels[0] > mood_levels[-1] \
                else "peggioramento" if len(mood_levels) >= 3 and mood_levels[0] < mood_levels[-1] \
                else "stabile"

        hours_since_last = None
        if last_mood and last_mood.get("timestamp"):
            try:
                last_ts = last_mood["timestamp"]
                if hasattr(last_ts, "to_native"):
                    last_ts = last_ts.to_native()
                delta = datetime.now() - last_ts.replace(tzinfo=None)
                hours_since_last = round(delta.total_seconds() / 3600, 1)
            except Exception:
                pass

        return {
            "user": {
                "name": user.get("name", "amico"),
                "current_day": user.get("current_day", 1),
                "streak": user.get("streak", 0),
                "goal": user.get("goal", ""),
                "biggest_challenge": user.get("biggest_challenge", ""),
                "ideal_self_90": user.get("ideal_self_90", ""),
                "core_values": user.get("core_values", ""),
                "stress_response": user.get("stress_response", ""),
            },
            "mood": {
                "current": last_mood.get("level", 3) if last_mood else 3,
                "avg_7d": avg_mood,
                "trend": trend,
                "hours_since_last_interaction": hours_since_last,
            },
            "events": {
                "today_count": len(today_events),
                "today": [e.get("description", "") for e in today_events[:3]],
                "recent_descriptions": [e.get("description", "") for e in recent_events[:5]],
                "recent_feeling_avg": round(
                    sum(e.get("feeling_level", 3) for e in recent_events) / len(recent_events), 1
                ) if recent_events else 3.0,
            },
            "patterns": patterns,
        }

    def get_engagement_status(self, telegram_id: int) -> Dict:
        """
        Valuta quanto è ingaggiato l'utente. Usato dallo scheduler adattivo
        per decidere quando e come inviare messaggi.
        """
        last_mood = self.get_last_mood(telegram_id)
        user = self.get_user(telegram_id) or {}

        hours_silent = 999
        if last_mood and last_mood.get("timestamp"):
            try:
                last_ts = last_mood["timestamp"]
                if hasattr(last_ts, "to_native"):
                    last_ts = last_ts.to_native()
                delta = datetime.now() - last_ts.replace(tzinfo=None)
                hours_silent = delta.total_seconds() / 3600
            except Exception:
                pass

        streak = user.get("streak", 0)
        last_level = last_mood.get("level", 3) if last_mood else 3

        return {
            "hours_silent": round(hours_silent, 1),
            "streak": streak,
            "last_mood_level": last_level,
            "needs_nudge": hours_silent > 20,
            "needs_support": last_level <= 2,
            "streak_milestone": streak > 0 and streak % 7 == 0,
        }
