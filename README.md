# oxide cry4me - iOS Dynamic Library Skeleton

## 📦 Paket İçeriği

```
iOS_DYLIB_SKELETON/
├── OxCryptoWrapper.h              # Header dosyası (tüm fonksiyon tanımları)
├── OxCryptoWrapper.m              # Implementation (crypto, hash, hmac, base64)
├── build_dylib.sh                 # Derleme script'i (macOS)
├── integrate_dylib.sh             # IPA entegrasyon script'i (macOS)
├── frida_hook.js                  # Frida hook script (dinamik analiz)
├── README.md                      # Bu dosya
└── MACOS_BUILD_INSTRUCTIONS.md    # Detaylı derleme talimatları
```

## 🎯 Kapsam

Bu paket Android için geliştirilen "oxide cry4me" hilesinin iOS platformuna uyarlanması için oluşturulmuş iOS dynamic library (.dylib) iskeletidir.

## ✅ Özellikler

### Kriptografik Fonksiyonlar
- ✅ AES-256-CBC encrypt/decrypt
- ✅ MD5, SHA-1, SHA-256 hash
- ✅ PBKDF2 key derivation
- ✅ HMAC-SHA256, HMAC-MD5
- ✅ Base64 encode/decode
- ✅ Random IV generation
- ✅ Secure memory zeroing (anti-debugging)

### Platformlar
- ✅ iOS (ARM64)
- ⏳ Android (zaten mevcut)

### Bridge Fonksiyonları
- ✅ C-style function exports (native interop için)
- ✅ Objective-C methods
- ✅ Memory management bridge

## 🚀 Hızlı Başlangıç (macOS)

### Gereksinimler
- macOS 10.15+ (Catalina veya üzeri)
- Xcode Command Line Tools

### Kurulum

```bash
# Xcode Command Line Tools kurulumu
xcode-select --install

# Kurulumu test et
clang --version
xcode-select -p
```

### Derleme

```bash
# iOS_DYLIB_SKELETON dizinine git
cd iOS_DYLIB_SKELETON

# Script'i çalıştırılabilir yap
chmod +x build_dylib.sh

# Derle
./build_dylib.sh
```

**Beklenen Çıktı:**
```
=== oxide cry4me - iOS Dylib Build Script ===

Derleyici ayarları:
  CC: clang
  SDK: iphoneos
  Architecture: arm64
  Min Version: 12.0

Derleniyor...
✓ Derleme başarılı

Çıktı: libOxCryptoWrapper.dylib

Binary bilgileri:
libOxCryptoWrapper.dylib: Mach-O 64-bit dynamically linked shared library arm64

Exported semboller (Crypto):
T _oxide_encrypt_c
T _oxide_decrypt_c
T -[OxCryptoWrapper encryptData:withKey:iv:]
T -[OxCryptoWrapper decryptData:withKey:iv:]

Exported semboller (Hash):
T -[OxCryptoWrapper md5Hash:]
T -[OxCryptoWrapper sha256Hash:]
T -[OxCryptoWrapper sha1Hash:]

Exported semboller (HMAC):
T -[OxCryptoWrapper hmacSHA256:data:key:]
T -[OxCryptoWrapper hmacMD5:data:key:]
T _oxide_hmac_sha256_c
T _oxide_hmac_md5_c

Exported semboller (Base64):
T -[OxCryptoWrapper base64Encode:]
T -[OxCryptoWrapper base64Decode:]
T _oxide_base64_encode_c
T _oxide_base64_decode_c

=== Build tamamlandı ===

Dylib boyutu:
-rwxr-xr-x  1 user  staff   45K Nov  2 13:42 libOxCryptoWrapper.dylib
```

### IPA Entegrasyonu (İsteğe Bağlı)

Eğer `oxide_cry4me.ipa` dosyanız varsa:

```bash
# Script'i çalıştırılabilir yap
chmod +x integrate_dylib.sh

# IPA'yı patch et
./integrate_dylib.sh oxide_cry4me.ipa
```

**Beklenen Çıktı:**
```
=== oxide cry4me - iOS Dylib Entegrasyon ===

[0/5] Dylib doğrulanıyor...
✓ Dylib ARM64 formatında

[1/5] IPA dosyası çıkartılıyor...
✓ Uygulama: oxide_cry4me.app

[2/5] Frameworks dizini oluşturuluyor...
✓ Frameworks dizini oluşturuldu

[3/5] Dylib kopyalanıyor...
✓ Dylib kopyalandı

[4/5] Binary patch ediliyor...
✓ Binary patch edildi

[5/5] Info.plist kontrol ediliyor...
✓ Info.plist kontrol edildi

IPA yeniden paketleniyor...
✓ IPA paketlendi: integrated_app/oxide_cry4me_patched.ipa

=== Entegrasyon tamamlandı ===

Sonraki adımlar:
1. IPA'yı cihaza yükleyin (ideally with jailed/unsigned for testing)
2. Uygulamayı çalıştırın
3. Frida ile hook testi yapın:
   frida -U -f com.oxide.cry4me -l frida_hook.js --no-pause

IPA boyutu:
-rw-r--r--  1 user  staff   12M Nov  2 13:42 integrated_app/oxide_cry4me_patched.ipa
```

## 🧪 Dinamik Analiz (Frida)

### iOS Cihaz Kurulumu

1. **Frida kurulumu**
```bash
# macOS'ta
pip3 install frida-tools

# iOS cihazda (jailbreak gereklidir)
curl -sSf https://frida.teardown.re/frida | sh
```

2. **Hook Script'i Çalıştırın**
```bash
# iOS cihaz bağlandığında
frida -U -f com.oxide.cry4me -l frida_hook.js --no-pause

# Ya da çalışan uygulama
frida -U com.oxide.cry4me -l frida_hook.js
```

3. **Beklenen Çıktı**
```
[*] oxide cry4me - Frida Hook Script Başlatıldı
[+] Objective-C Runtime kullanılabilir
[+] OxCryptoWrapper sınıfı bulundu
[+] Tüm hook'lar kuruldu
[*] Hook script'i aktif, fonksiyon çağrıları bekleniyor...

[+] encryptData:withKey:iv: çağrıldı
    Input length: 11
    Input hex: 48 65 6c 6c 6f 20 57 6f 72 6c 64
    Key length: 32
    IV length: 16
[-] encryptData:withKey:iv: tamamlandı
    Output length: 16
```

## 📊 Fonksiyon Mapping

### iOS Objective-C Methods

```objective-c
// Crypto Operations
+ (NSData *)encryptData:(NSData *)data withKey:(NSData *)key iv:(NSData *)iv;
+ (NSData *)decryptData:(NSData *)data withKey:(NSData *)key iv:(NSData *)iv;

// Hash Operations
+ (NSString *)md5Hash:(NSData *)data;
+ (NSString *)sha256Hash:(NSData *)data;
+ (NSString *)sha1Hash:(NSData *)data;

// Key Generation
+ (NSData *)generateKeyFromPassword:(NSString *)password
                                   salt:(NSData *)salt
                             iterations:(NSUInteger)iterations;
+ (NSData *)generateRandomIV;

// HMAC Operations
+ (NSData *)hmacSHA256:(NSData *)data key:(NSData *)key;
+ (NSData *)hmacMD5:(NSData *)data key:(NSData *)key;

// Base64 Operations
+ (NSString *)base64Encode:(NSData *)data;
+ (NSData *)base64Decode:(NSString *)base64String;

// Memory Management
+ (void *)allocateBuffer:(size_t)size;
+ (void)freeBuffer:(void *)buffer;
+ (void)secureZeroBuffer:(void *)buffer length:(size_t)length;
```

### C Bridge Functions

```c
// Crypto
void* oxide_encrypt_c(const void* input, size_t input_len,
                      const void* key, size_t key_len,
                      const void* iv, size_t iv_len,
                      size_t* output_len);

void* oxide_decrypt_c(const void* input, size_t input_len,
                      const void* key, size_t key_len,
                      const void* iv, size_t iv_len,
                      size_t* output_len);

// HMAC
void* oxide_hmac_sha256_c(const void* input, size_t input_len,
                          const void* key, size_t key_len,
                          size_t* output_len);

void* oxide_hmac_md5_c(const void* input, size_t input_len,
                       const void* key, size_t key_len,
                       size_t* output_len);

// Base64
void* oxide_base64_encode_c(const void* input, size_t input_len,
                            size_t* output_len);

void* oxide_base64_decode_c(const char* base64_str,
                            size_t* output_len);

// Memory
void oxide_free_c(void* buffer);
```

## 🔧 Sorun Giderme

### Sorun 1: "clang: command not found"
**Çözüm:** Xcode Command Line Tools kurun
```bash
xcode-select --install
```

### Sorun 2: "No such file or directory"
**Çözüm:** Script'leri çalıştırılabilir yapın
```bash
chmod +x build_dylib.sh
chmod +x integrate_dylib.sh
```

### Sorun 3: "isysroot not found"
**Çözüm:** SDK path'i kontrol edin
```bash
xcode-select -p
# Çıktı: /Applications/Xcode.app/Contents/Developer
```

### Sorun 4: "codesign failed"
**Çözüm:** Ad-hoc signing kullanın (test için)
```bash
codesign --force --deep --sign - <app_path>
```

## 📋 Cross-Platform Mapping

Detaylı cross-platform fonksiyon eşleştirme için üst dizindeki `CROSS_PLATFORM_MAPPING.md` dosyasına bakın.

Android JNI fonksiyonları ile iOS Objective-C metodları arasındaki mapping:

| Android JNI | iOS Objective-C | Kategori |
|-------------|------------------|----------|
| `Java_com_oxide_cry4me_Crypto_encrypt` | `[OxCryptoWrapper encryptData:withKey:iv:]` | crypto |
| `Java_com_oxide_cry4me_Crypto_decrypt` | `[OxCryptoWrapper decryptData:withKey:iv:]` | crypto |
| `Java_com_oxide_cry4me_Hash_md5` | `[OxCryptoWrapper md5Hash:]` | hash |
| `Java_com_oxide_cry4me_Hash_sha256` | `[OxCryptoWrapper sha256Hash:]` | hash |
| `Java_com_oxide_cry4me_Hash_sha1` | `[OxCryptoWrapper sha1Hash:]` | hash |
| `Java_com_oxide_cry4me_KeyGen_generate` | `[OxCryptoWrapper generateKeyFromPassword:salt:iterations:]` | key |
| `Java_com_oxide_cry4me_IV_initVector` | `[OxCryptoWrapper generateRandomIV]` | key |
| `Java_com_oxide_cry4me_HMAC_sha256` | `[OxCryptoWrapper hmacSHA256:data:key:]` | hmac |
| `Java_com_oxide_cry4me_HMAC_md5` | `[OxCryptoWrapper hmacMD5:data:key:]` | hmac |
| `Java_com_oxide_cry4me_Base64_encode` | `[OxCryptoWrapper base64Encode:]` | base64 |
| `Java_com_oxide_cry4me_Base64_decode` | `[OxCryptoWrapper base64Decode:]` | base64 |

## 📝 Proje Durumu

### Windows'ta Tamamlananlar (2026-11-02)
- ✅ Android APK analizi (demo modda)
- ✅ iOS dylib iskeleti oluşturuldu
- ✅ Ek fonksiyonlar eklendi (SHA1, HMAC, Base64, Secure Zero)
- ✅ C bridge fonksiyonları eklendi
- ✅ Frida hook script'i geliştirildi
- ✅ Build script'leri optimize edildi
- ✅ Cross-platform mapping güncellendi

### macOS'ta Yapılacaklar
- ⏳ `./build_dylib.sh` ile derleme
- ⏳ `./integrate_dylib.sh` ile IPA patch etme
- ⏳ Frida ile dinamik test

## 📞 Destek

Sorun yaşarsanız:
- Xcode Command Line Tools kurulu mu kontrol edin
- macOS versiyonu en az 10.15 (Catalina) olmalı
- Script'lerin çalıştırılabilir olduğundan emin olun
- Detaylı talimatlar için `MACOS_BUILD_INSTRUCTIONS.md` dosyasına bakın

---

**Not:** Bu paket Windows (C:\Users\emiro\Desktop\Oxide_Yedek\iOS_DYLIB_SKELETON) üzerinde oluşturulmuş olup, macOS'ta derlenmesi gerekir.
