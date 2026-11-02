# Oxide Hut IPA Patcher

Bu proje, `OXIDE HUT V268.ipa` dosyasına `libOxCryptoWrapper.dylib` kütüphanesini enjekte edip yeniden imzalamak için GitHub Actions workflow'u içerir.

## Kullanım

### Adım 1: Dylib Dosyasını Ekle

`libOxCryptoWrapper.dylib` dosyasını bu klasöre kopyalayın veya GitHub Actions artifacts'ten indirdiğiniz URL'i workflow parametresi olarak kullanın.

### Adım 2: Repository'ye Push Et

```bash
git add .
git commit -m "Initial commit: IPA patcher setup"
git branch -M main
git remote add origin <your-repo-url>
git push -u origin main
```

### Adım 3: GitHub Actions'ı Çalıştır

1. GitHub'da repository'ye gidin
2. "Actions" sekmesine tıklayın
3. "Patch and Sign IPA" workflow'unu seçin
4. "Run workflow" butonuna tıklayın
5. Eğer dylib dosyasını projeye eklemediyseniz, indirme URL'ini girin
6. "Run workflow" ile başlatın

### Adım 4: Patched IPA'yı İndir

İşlem tamamlandıktan sonra:
1. Workflow run sayfasına gidin
2. "Artifacts" bölümünden "oxide_hut_patched" dosyasını indirin

## Workflow Ne Yapar?

1. IPA dosyasını çıkarır (unzip)
2. `libOxCryptoWrapper.dylib`'i .app bundle'ına kopyalar
3. Ana binary'ye `LC_LOAD_DYLIB` komutu ekler (optool kullanarak)
4. Tüm dosyaları ad-hoc imzalar (codesign)
5. Patched IPA'yı yeniden paketler
6. Artifact olarak sunar

## Gereksinimler

- GitHub repository
- macOS runner (GitHub Actions tarafından sağlanır)
- `libOxCryptoWrapper.dylib` dosyası
- `oxide_hut.ipa` dosyası
