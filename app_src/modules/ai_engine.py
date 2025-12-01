class AIEngine:
    def __init__(self):
        self.is_ready = True

    def generate_response(self, prompt):
        return f"You said: {prompt}"
