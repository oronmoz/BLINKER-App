from googletrans import Translator
import logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

translator = Translator()


def is_hebrew(text):
    hebrew_letters = set('\u0590\u05D0\u05D1\u05D2\u05D3\u05D4\u05D5\u05D6\u05D7\u05D8'
                         '\u05D9\u05DB\u05DC\u05DE\u05E0\u05E1\u05E2\u05E4\u05E6\u05E7'
                         '\u05E8\u05E9\u05EA\u05DF\u05DD\u05E3')  # Hebrew Unicode range
    return any(char in hebrew_letters for char in text)

def translate_text(text, target_language='en'):
    try:
        if is_hebrew(text):
            translation = translator.translate(text, dest=target_language)
            logging.info(f"Translated text from Hebrew to English: {text} -&gt; {translation.text}")
            return translation.text
        return text
    except Exception as e:
        logging.error(f"Error translating text: {e}")
        return text
