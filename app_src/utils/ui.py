from kivy.uix.label import Label

def create_title(text):
    return Label(
        text=text,
        font_size="22sp",
        halign="center",
        size_hint_y=None,
        height="40dp"
    )
