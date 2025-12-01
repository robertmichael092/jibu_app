class Analytics:
    def log_event(self, event, data=None):
        print(f"[Analytics] {event} | {data}")
