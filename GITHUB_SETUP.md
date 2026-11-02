# GitHub Actions ile iOS Dylib Derleme

Bu repo Windows'tan macOS olmadan iOS dylib derlemek için GitHub Actions kullanır.

## 🚀 Hızlı Başlangıç

### 1. GitHub Reposu Oluştur

1. GitHub hesabınızda yeni bir repo oluşturun
2. Repo adı: `oxide-ios-dylib` (veya istediğiniz ad)
3. Public veya Private (her ikisi de çalışır)
4. README oluşturma seçeneğini işaretleyebilirsiniz

### 2. Dosyaları Repo'ya Push Et

Bu dizinden GitHub repo'ya dosyaları push edin:

```bash
# Dizine git
cd "C:\Users\emiro\Desktop\Oxide_Yedek\iOS_DYLIB_SKELETON"

# Git init (ilk kez yapıyorsanız)
git init

# Remote ekle
git remote add origin https://github.com/KULLANICI_ADINIZ/oxide-ios-dylib.git

# Tüm dosyaları ekle
git add .

# Commit
git commit -m "Initial commit: iOS dylib skeleton with GitHub Actions"

# Push
git push -u origin main
```

**Not:** `KULLANICI_ADINIZ` kısmını kendi GitHub kullanıcı adınızla değiştirin.

### 3. GitHub Actions Build Tetikle

Push işleminden sonra GitHub otomatik olarak build başlatır.

1. GitHub repo sayfasına gidin
2. "Actions" sekmesine tıklayın
3. "Build iOS Dylib" workflow'unu göreceksiniz
4. Build'in çalıştığını ve tamamlandığını izleyin

### 4. Derlenmiş Dylib'i İndir

Build tamamlandıktan sonra:

1. GitHub repo sayfasında "Actions" sekmesine gidin
2. En son workflow run'a tıklayın
3. En altta "Artifacts" bölümünü göreceksiniz
4. "libOxCryptoWrapper-dylib" artifact'ını indirin
5. Zip dosyasını açın, `libOxCryptoWrapper.dylib` dosyasını alın

## 📊 Workflow Detayları

### Workflow: build-dylib.yml

Bu workflow şu adımları yapar:

1. **Checkout**: Kodu alır
2. **Xcode Setup**: En son Xcode sürümünü kurar
3. **Build**: `build_dylib.sh` script'ini çalıştırır
4. **Verify**: Dylib'i doğrular (architecture, symbols)
5. **Upload**: Dylib'i artifact olarak yükler

### Build Süresi

- Ortalama: 2-3 dakika
- GitHub Actions ücretsiz tier'ında çalışır

## 🔧 Manuel Build Tetikleme

Push yapmadan da build tetikleyebilirsiniz:

1. GitHub repo sayfasına gidin
2. "Actions" sekmesine tıklayın
3. "Build iOS Dylib" workflow'una tıklayın
4. Sağ üstte "Run workflow" butonuna tıklayın
5. Branch seçin ve "Run workflow" butonuna tıklayın

## 📝 Dosya Yapısı

```
iOS_DYLIB_SKELETON/
├── .github/
│   └── workflows/
│       └── build-dylib.yml          # GitHub Actions workflow
├── OxCryptoWrapper.h                # Header dosyası
├── OxCryptoWrapper.m                # Implementation
├── build_dylib.sh                   # Derleme script'i
├── integrate_dylib.sh               # IPA entegrasyon script'i
├── frida_hook.js                    # Frida hook script
├── README.md                        # Genel dokümantasyon
├── MACOS_BUILD_INSTRUCTIONS.md      # macOS derleme talimatları
└── GITHUB_SETUP.md                  # Bu dosya
```

## 🎯 Sonraki Adımlar

Dylib'i indirdikten sonra:

1. **IPA Entegrasyonu** (opsiyonel)
   - macOS'ta `integrate_dylib.sh` ile IPA patch et
   - Veya iOS-sandbox-explorer ile Windows'ta patch et

2. **Dinamik Test**
   - Frida ile hook testi yap
   - iOS cihazda test et

3. **Windows'a Transfer**
   - Dylib'i Windows'a geri al
   - Diğer projelerde kullan

## 💡 İpuçları

### Build Hataları

Eğer build başarısız olursa:

1. GitHub Actions log'larını kontrol edin
2. `build_dylib.sh` script'ini kontrol edin
3. Workflow dosyasını güncelleyin ve yeniden push edin

### Artifact Süresi

Artifacts 30 gün saklanır. Daha uzun saklamak için workflow dosyasında `retention-days` değerini artırın.

### Private Repo

Private repo kullanıyorsanız GitHub Actions hala çalışır (ücretsiz tier dahilinde).

## 📞 Destek

Sorun yaşarsanız:

1. GitHub Actions log'larını kontrol edin
2. Workflow dosyasını kontrol edin
3. build_dylib.sh script'ini kontrol edin

---

**Önemli:** Bu yöntem macOS olmadan iOS dylib derlemek için en pratik çözümdür. GitHub Actions ücretsiz olarak çalışır ve 2-3 dakikada build tamamlanır.
