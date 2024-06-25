from cryptography.hazmat.primitives.ciphers import Cipher, algorithms, modes
from cryptography.hazmat.backends import default_backend
import base64
from cryptography.hazmat.primitives import hashes, padding
from cryptography.hazmat.primitives.kdf.pbkdf2 import PBKDF2HMAC

from app.core.security import ENCRYPTION_KEY


class EncryptionService:
    def __init__(self, key):
        self._key = key
        self._iv = b'\x00' * 16  # IV.fromLength(16) in Dart is equivalent to 16 null bytes

    def decrypt(self, encrypted_text):
        if encrypted_text is None:
            return ''

        try:
            encrypted = base64.b64decode(encrypted_text)
            cipher = Cipher(algorithms.AES(self._key), modes.CBC(self._iv), backend=default_backend())
            decryptor = cipher.decryptor()
            decrypted_padded = decryptor.update(encrypted) + decryptor.finalize()

            # Try PKCS7 unpadding first
            try:
                unpadder = padding.PKCS7(128).unpadder()
                unpadded = unpadder.update(decrypted_padded) + unpadder.finalize()
            except ValueError:
                # If PKCS7 fails, try to remove null byte padding
                unpadded = decrypted_padded.rstrip(b'\x00')

            return unpadded.decode('utf-8')
        except Exception as e:
            print(f"Decryption error: {e}")
            return ''

    def encrypt(self, text):
        if text is None:
            return ''

        # Add PKCS7 padding
        padder = padding.PKCS7(128).padder()
        padded = padder.update(text.encode('utf-8')) + padder.finalize()

        cipher = Cipher(algorithms.AES(self._key), modes.CBC(self._iv), backend=default_backend())
        encryptor = cipher.encryptor()
        encrypted = encryptor.update(padded) + encryptor.finalize()
        return base64.b64encode(encrypted).decode('utf-8')
