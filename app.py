import os
import time
from flask import Flask, request, jsonify
from flask_cors import CORS
from openai import OpenAI

# =========================
# APP SETUP
# =========================
app = Flask(__name__)
CORS(app)

# =========================
# LOAD API KEY (SAFE)
# =========================
OPENROUTER_API_KEY = os.environ.get("OPENROUTER_API_KEY")

if not OPENROUTER_API_KEY:
    print("❌ ERROR: OPENROUTER_API_KEY not set")
    # Do NOT crash app, return controlled error instead

client = OpenAI(
    api_key=OPENROUTER_API_KEY,
    base_url="https://openrouter.ai/api/v1",
)

# =========================
# CHAT MEMORY
# =========================
chat_history = []
MAX_HISTORY = 6

# =========================
# CRISIS DETECTION
# =========================
CRISIS_KEYWORDS = [
    "suicide", "kill myself", "end my life",
    "self harm", "self-harm", "die",
    "hopeless", "no reason to live",
    "can't go on", "give up"
]

def is_crisis_message(message: str) -> bool:
    message = message.lower()
    return any(keyword in message for keyword in CRISIS_KEYWORDS)

# =========================
# AI CALL WITH RETRY
# =========================
def call_ai_with_retry(messages, retries=2, delay=1):
    if not OPENROUTER_API_KEY:
        return "AI service is not configured properly."

    for attempt in range(retries + 1):
        try:
            print(f"🤖 AI attempt {attempt + 1}")

            response = client.chat.completions.create(
                model="openrouter/auto",  # ✅ most stable choice
                temperature=0.7,
                messages=messages,
                timeout=20,
            )

            reply = response.choices[0].message.content
            if reply:
                return reply.strip()

        except Exception as e:
            print(f"⚠️ AI error (attempt {attempt + 1}): {e}")
            time.sleep(delay)

    return (
        "I'm here with you, but I'm having trouble responding right now. "
        "Please try again in a moment."
    )

# =========================
# HEALTH CHECK ENDPOINT
# =========================
@app.route("/health", methods=["GET"])
def health():
    return jsonify({
        "status": "ok",
        "backend": "running",
        "ai_configured": bool(OPENROUTER_API_KEY)
    }), 200

# =========================
# CHAT ENDPOINT
# =========================
@app.route("/chat", methods=["POST"])
def chat():
    global chat_history

    data = request.get_json(force=True)
    user_message = data.get("message", "").strip()

    print("🔥 CHAT HIT:", user_message)

    if not user_message:
        return jsonify({"reply": "Please say something."})

    # 🚨 Crisis handling
    if is_crisis_message(user_message):
        return jsonify({
            "reply": (
                "I'm really sorry you're feeling this way. You are not alone.\n\n"
                "📞 Kiran Mental Health Helpline (India): 1800-599-0019\n"
                "📞 AASRA: +91-9820466726\n\n"
                "Talking to someone trained can really help."
            )
        })

    try:
        # Save user message
        chat_history.append({"role": "user", "content": user_message})
        chat_history = chat_history[-MAX_HISTORY:]

        messages = [
            {
                "role": "system",
                "content": (
                    "You are a compassionate and empathetic mental health support chatbot for students. "
                    "Respond warmly and naturally. "
                    "Do NOT give medical diagnoses. "
                    "Encourage healthy coping strategies gently."
                )
            }
        ] + chat_history

        ai_reply = call_ai_with_retry(messages)

        # Save AI reply
        chat_history.append({"role": "assistant", "content": ai_reply})
        chat_history = chat_history[-MAX_HISTORY:]

        print("✅ AI REPLY:", ai_reply[:100])
        return jsonify({"reply": ai_reply})

    except Exception as e:
        print("❌ BACKEND ERROR:", e)
        return jsonify({
            "reply": "I'm here with you. Something went wrong, but you can keep talking."
        }), 500

# =========================
# RESET ENDPOINT
# =========================
@app.route("/reset", methods=["POST"])
def reset_chat():
    global chat_history
    chat_history = []
    print("🧹 Chat history cleared")
    return jsonify({"status": "success"})

# =========================
# RUN SERVER (RENDER SAFE)
# =========================
if __name__ == "__main__":
    port = int(os.environ.get("PORT", 5000))
    print(f"🚀 MindEaseAI backend running on port {port}")
    app.run(host="0.0.0.0", port=port, debug=True)


