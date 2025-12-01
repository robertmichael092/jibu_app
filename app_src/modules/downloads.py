class DownloadsManager:
    def __init__(self):
        self.available_languages = ["en", "sw", "fr"]

    def download_language_pack(self, lang_code):
        print(f"Downloading pack for {lang_code}...")
        return True
