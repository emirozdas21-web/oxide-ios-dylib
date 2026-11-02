#!/bin/bash
#
# integrate_dylib.sh
# oxide cry4me - iOS App Entegrasyon Script'i
#
# Bu script oluşturulan dylib'i iOS uygulamasına entegre eder
#

set -e

# Renkler
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

DYLIB_NAME="libOxCryptoWrapper.dylib"
IPA_PATH="$1"
OUTPUT_DIR="integrated_app"

echo -e "${GREEN}=== oxide cry4me - iOS Dylib Entegrasyon ===${NC}"
echo ""

# Kontrol
if [ -z "$IPA_PATH" ]; then
    echo -e "${RED}Kullanım: $0 <oxide_cry4me.ipa>${NC}"
    exit 1
fi

if [ ! -f "$IPA_PATH" ]; then
    echo -e "${RED}Hata: IPA dosyası bulunamadı: $IPA_PATH${NC}"
    exit 1
fi

if [ ! -f "$DYLIB_NAME" ]; then
    echo -e "${RED}Hata: ${DYLIB_NAME} bulunamadı. Önce build_dylib.sh çalıştırın.${NC}"
    exit 1
fi

# Dylib doğrulama
echo -e "${BLUE}[0/5] Dylib doğrulanıyor...${NC}"
file "$DYLIB_NAME" | grep -q "Mach-O 64-bit dynamically linked shared library arm64"
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Dylib ARM64 formatında${NC}"
else
    echo -e "${RED}✗ Dylib ARM64 formatında değil${NC}"
    exit 1
fi
echo ""

# IPA çıkarma
echo -e "${BLUE}[1/5] IPA dosyası çıkartılıyor...${NC}"
rm -rf extracted_ipa
unzip -q "$IPA_PATH" -d extracted_ipa
APP_NAME=$(ls extracted_ipa/Payload/*.app | head -n 1 | xargs basename)
APP_PATH="extracted_ipa/Payload/${APP_NAME}"

echo -e "${GREEN}✓ Uygulama: ${APP_NAME}${NC}"
echo ""

# Frameworks dizini oluştur
echo -e "${BLUE}[2/5] Frameworks dizini oluşturuluyor...${NC}"
FRAMEWORKS_DIR="${APP_PATH}/Frameworks"
mkdir -p "$FRAMEWORKS_DIR"

# Dylib'i kopyala
echo -e "${BLUE}[3/5] Dylib kopyalanıyor...${NC}"
cp "$DYLIB_NAME" "$FRAMEWORKS_DIR/"
chmod +x "${FRAMEWORKS_DIR}/${DYLIB_NAME}"

echo -e "${GREEN}✓ Dylib kopyalandı${NC}"
echo ""

# Mach-O binary'i patch et
echo -e "${BLUE}[4/5] Binary patch ediliyor...${NC}"
BINARY_NAME=$(defaults read "${APP_PATH}/Info.plist" CFBundleExecutable)
BINARY_PATH="${APP_PATH}/${BINARY_NAME}"

# Dylib'in yüklenip yüklenmediğini kontrol et
if otool -L "$BINARY_PATH" | grep -q "$DYLIB_NAME"; then
    echo -e "${YELLOW}Dylib zaten yüklenmiş, tekrar ekleniyor...${NC}"
fi

# Dylib'i LC_LOAD_DYLIB olarak ekle
install_name_tool -change "@rpath/${DYLIB_NAME}" "@executable_path/Frameworks/${DYLIB_NAME}" "${FRAMEWORKS_DIR}/${DYLIB_NAME}" 2>/dev/null || true

# Binary'e dylib'i yükle
install_name_tool -insert "@executable_path/Frameworks/${DYLIB_NAME}" "$BINARY_PATH"

echo -e "${GREEN}✓ Binary patch edildi${NC}"
echo ""

# Info.plist güncelle (gerekirse)
echo -e "${BLUE}[5/5] Info.plist kontrol ediliyor...${NC}"
if ! plutil -extract CFBundleExecutable raw "${APP_PATH}/Info.plist" > /dev/null 2>&1; then
    echo -e "${YELLOW}Info.plist kontrol edildi${NC}"
fi

echo -e "${GREEN}✓ Info.plist kontrol edildi${NC}"
echo ""

# IPA'yı yeniden paketle
echo -e "${BLUE}IPA yeniden paketleniyor...${NC}"
rm -rf "$OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR"
cd extracted_ipa
zip -qr "../${OUTPUT_DIR}/oxide_cry4me_patched.ipa" Payload/
cd ..

echo -e "${GREEN}✓ IPA paketlendi: ${OUTPUT_DIR}/oxide_cry4me_patched.ipa${NC}"
echo ""

# Temizlik
echo -e "${YELLOW}Geçici dosyalar temizleniyor...${NC}"
rm -rf extracted_ipa

echo -e "${GREEN}=== Entegrasyon tamamlandı ===${NC}"
echo ""
echo -e "${BLUE}Sonraki adımlar:${NC}"
echo "1. IPA'yı cihaza yükleyin (ideally with jailed/unsigned for testing)"
echo "2. Uygulamayı çalıştırın"
echo "3. Frida ile hook testi yapın:"
echo "   frida -U -f com.oxide.cry4me -l frida_hook.js --no-pause"
echo ""
echo -e "${BLUE}IPA boyutu:${NC}"
ls -lh "${OUTPUT_DIR}/oxide_cry4me_patched.ipa"
echo ""
