from passlib.context import CryptContext
from cryptography.hazmat.primitives.ciphers import Cipher, algorithms, modes
from cryptography.hazmat.backends import default_backend
import base64
import os

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

# Decrypt messages from chat:
ENCRYPTION_KEY = os.environ.get('ENCRYPTION_KEY', 'N3V3rGoNnAg1vEy0uUPneV3rG0nNALeT').encode()


def encrypt(text):
    iv = os.urandom(16)
    cipher = Cipher(algorithms.AES(ENCRYPTION_KEY), modes.CBC(iv), backend=default_backend())
    encryptor = cipher.encryptor()
    padded_text = text.encode() + b"\0" * (16 - len(text) % 16)
    encrypted_text = encryptor.update(padded_text) + encryptor.finalize()
    return base64.b64encode(iv + encrypted_text).decode('utf-8')


def decrypt(encrypted_text):
    decoded = base64.b64decode(encrypted_text.encode('utf-8'))
    iv = decoded[:16]
    encrypted_text = decoded[16:]
    cipher = Cipher(algorithms.AES(ENCRYPTION_KEY), modes.CBC(iv), backend=default_backend())
    decryptor = cipher.decryptor()
    decrypted_padded = decryptor.update(encrypted_text) + decryptor.finalize()
    return decrypted_padded.rstrip(b"\0").decode()
