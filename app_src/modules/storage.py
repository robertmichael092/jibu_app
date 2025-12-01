import json
import os

class Storage:
    def save(self, path, data):
        directory = os.path.dirname(path)
        if directory and not os.path.exists(directory):
            os.makedirs(directory)

        with open(path, "w") as f:
            json.dump(data, f)

    def load(self, path, default={}):
        if not os.path.exists(path):
            return default
        with open(path, "r") as f:
            return json.load(f)
