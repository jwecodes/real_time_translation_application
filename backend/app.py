from flask import Flask, request
from flask_socketio import SocketIO, emit
import azure.cognitiveservices.speech as speechsdk
import threading

app = Flask(__name__)
socketio = SocketIO(app, cors_allowed_origins='*')

subscription_key = "466e87e9-1afb-4aa8-a219-595ecb6abbea"
region = "centralindia"
source_language = "hi-IN"
target_languages = ["en-US"]

@app.route('/')
def home():
    return "Translation server is running."

def start_translation(sid):
    translation_config = speechsdk.translation.SpeechTranslationConfig(
        subscription=subscription_key,
        region=region,
        speech_recognition_language=source_language
    )
    for lang in target_languages:
        translation_config.add_target_language(lang)

    audio_config = speechsdk.audio.AudioConfig(use_default_microphone=True)
    recognizer = speechsdk.translation.TranslationRecognizer(
        translation_config=translation_config,
        audio_config=audio_config
    )

    def recognized(evt):
        if evt.result.reason == speechsdk.ResultReason.TranslatedSpeech:
            for lang, translation in evt.result.translations.items():
                socketio.emit('translation', {'lang': lang, 'translation': translation}, to=sid)

    recognizer.recognized.connect(recognized)
    recognizer.start_continuous_recognition()
    print("Started continuous recognition")

@socketio.on('start_translation')
def handle_start_translation():
    sid = request.sid
    thread = threading.Thread(target=start_translation, args=(sid,))
    thread.start()
    emit('started', {'status': 'Listening started...'})

if __name__ == '__main__':
    socketio.run(app, port=5000)
