# macOS Derleme Talimatları - oxide cry4me

Bu paket Windows'ta hazırlanmış, ancak macOS'ta derlenmesi gereken iOS dynamic library iskeletidir.

## 📦 Paket İçeriği

```
iOS_DYLIB_SKELETON/
├── OxCryptoWrapper.h          # Header dosyası
├── OxCryptoWrapper.m          # Implementation
├── build_dylib.sh             # Derleme script'i
├── integrate_dylib.sh          # IPA entegrasyon script'i
├── frida_hook.js              # Frida hook script
├── README.md                  # Genel dokümantasyon
└── MACOS_BUILD_INSTRUCTIONS.md # Bu dosya
```

## ⚙️ Ön Koşullar (macOS)

### Gerekli Araçlar
- **Xcode Command Line Tools** (Zorunlu)
- **bash** (macOS varsayılan)
- **zip/unzip** (varsayılan)

### Xcode Command Line Tools Kurulumu
```bash
# Terminal'de çalıştırın
xcode-select --install
```

Kurulum tamamlandığında şu komut test edin:
```bash
clang --version
xcode-select -p
```

## 🚀 Adım Adım Derleme

### Adım 1: Paketi macOS'a Upload Edin

#### Seçenek A: SCP ile (Eğer SSH erişiminiz varsa)
```bash
# Windows'ta (Git Bash/PowerShell)
scp -r iOS_DYLIB_SKELETON user@macos-server-ip:~/
```

#### Seçenek B: Manuel Transfer
- `iOS_DYLIB_SKELETON` dizinini zipleyin
- macOS'a AirDrop, Google Drive, veya USB ile taşıyın
- macOS'ta unzip edin

### Adım 2: Derleme Script'ini Çalıştırın

```bash
# macOS terminal'de
cd ~/iOS_DYLIB_SKELETON

# Script'i çalıştırılabilir yapın
chmod +x build_dylib.sh

# Derleyin
./build_dylib.sh
```

**Beklenen Çıktı:**
```
=== oxide cry4me - iOS Dylib Build Script ===

Derleyici ayarları:
  CC: clang
  CFLAGS: -arch arm64 -isysroot ...

Derleniyor...
✓ Derleme başarılı

Çıktı: libOxCryptoWrapper.dylib

Binary bilgileri:
libOxCryptoWrapper.dylib: Mach-O 64-bit dynamically linked shared library arm64

Exported semboller:
000000000001a4c T _oxide_encrypt_c
000000000001b20 T _oxide_decrypt_c
000000000001c08 T _[OxCryptoWrapper encryptData:withKey:iv:]
...

=== Build tamamlandı ===
```

### Adım 3: IPA Entegrasyonu (İsteğe Bağlı)

Eğer `oxide_cry4me.ipa` dosyanız varsa:

```bash
# Script'i çalıştırılabilir yapın
chmod +x integrate_dylib.sh

# IPA'yı patch edin
./integrate_dylib.sh oxide_cry4me.ipa
```

**Beklenen Çıktı:**
```
=== oxide cry4me - iOS Dylib Entegrasyon ===

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
```

### Adım 4: Codesign (Gerekirse)

Eğer IPA'yı cihaza yükleyecekseniz, codesign gerekebilir:

```bash
# Ad-hoc signing (test için)
codesign --force --deep --sign - integrated_app/oxide_cry4me_patched.ipa
```

**Not:** Production için gerçek Apple Developer sertifikası gerekir.

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

## 📊 Çıktı Dosyaları

Derleme sonrası şunlar oluşur:

1. **libOxCryptoWrapper.dylib** - Derlenmiş dynamic library
2. **integrated_app/oxide_cry4me_patched.ipa** - Patch edilmiş IPA (entegrasyon yapıldıysa)

Bu dosyaları Windows'a geri transfer edebilirsiniz.

## 🎯 Özet

1. ✅ Paketi macOS'a upload et
2. ✅ `./build_dylib.sh` ile derle
3. ✅ İsteğe bağlı: `./integrate_dylib.sh` ile IPA patch et
4. ✅ İsteğe bağlı: Frida ile dinamik analiz yap
5. ✅ Çıktıları Windows'a geri transfer et

## 📞 Destek

Sorun yaşarsanız:
- Xcode Command Line Tools kurulu mu kontrol edin
- macOS versiyonu en az 10.15 (Catalina) olmalı
- Script'lerin çalıştırılabilir olduğundan emin olun

---

**Not:** Bu paket Windows (C:\Users\emiro\mobile_binary_analysis\iOS_DYLIB_SKELETON) üzerinde oluşturulmuştur. macOS'ta derlenmesi gerekir.
