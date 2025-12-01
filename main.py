from kivy.app import App
from kivy.lang import Builder
from kivy.uix.screenmanager import ScreenManager, Screen


class LoginScreen(Screen):
    pass

class RegisterScreen(Screen):
    pass

class EmailVerifyScreen(Screen):
    pass

class ForgotPasswordScreen(Screen):
    pass

class ResetPasswordScreen(Screen):
    pass

class HomeScreen(Screen):
    pass

class ChatScreen(Screen):
    pass

class ProfileScreen(Screen):
    pass

class SettingsScreen(Screen):
    pass

class HistoryScreen(Screen):
    pass

class LanguageScreen(Screen):
    pass


class JibuScreenManager(ScreenManager):
    pass


class JibuApp(App):
    def build(self):
        return Builder.load_file("jibu.kv")


if __name__ == "__main__":
    JibuApp().run()
