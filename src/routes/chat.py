import os
import json
from flask import Blueprint, request, jsonify
from src.services.finbot_agent import FinBotAgent
from src.models.chat import ChatSession, ChatTurn
from src.models.user import db

chat_bp = Blueprint('chat', __name__)
agent = FinBotAgent()

@chat_bp.route('/finbot/chat', methods=['POST'])
def finbot_chat():
    """Chat endpoint for FinBot. Accepts JSON body with 'messages': [{role, content}].
    Example body: {"messages": [{"role": "user", "content": "Find invoice INV-1001 and process it."}]}
    """
    try:
        data = request.get_json(force=True) or {}
        messages = data.get('messages', [])
        session_id = data.get('session_id')
        allow_actions = bool(data.get('allow_actions', True))  # safety toggle

        # Optional bearer token guard
        required_token = os.getenv('CHAT_API_TOKEN')
        auth_header = request.headers.get('Authorization', '')
        if required_token:
            if not auth_header.startswith('Bearer '):
                return jsonify({"error": "Unauthorized"}), 401
            provided = auth_header.split(' ', 1)[1].strip()
            if provided != required_token:
                return jsonify({"error": "Unauthorized"}), 401
        if not isinstance(messages, list) or not messages:
            return jsonify({"error": "messages must be a non-empty list"}), 400

        # Optionally filter out action tools (approve/reject/process) by replacing them with safe responses
        if not allow_actions:
            # Shallow copy messages to add an instruction
            messages = messages + [{
                "role": "system",
                "content": "Important: Do not call any tools that change state (approve_invoice, reject_invoice, request_human_review, process_invoice). You may read details only."
            }]

        # Prepare session
        session = None
        if session_id:
            session = ChatSession.query.get(session_id)
        if not session:
            session = ChatSession()
            db.session.add(session)
            db.session.commit()

        # Append incoming user messages to persistence
        for m in messages:
            if m.get('role') == 'user':
                turn = ChatTurn(session_id=session.id, role='user', content=m.get('content', ''))
                db.session.add(turn)

        db.session.commit()

        result = agent.chat(messages, allow_actions=allow_actions)

        # Persist assistant turn
        try:
            tool_json = json.dumps(result.get('tool_result')) if result.get('tool_result') is not None else None
            db.session.add(ChatTurn(session_id=session.id, role='assistant', content=result.get('reply', ''), tool_result=tool_json))
            db.session.commit()
        except Exception:
            db.session.rollback()

        return jsonify({"success": True, "session_id": session.id, **result})
    except Exception as e:
        return jsonify({"error": str(e)}), 500
