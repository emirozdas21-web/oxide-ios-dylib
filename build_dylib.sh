#!/bin/bash
#
# build_dylib.sh
# oxide cry4me - iOS Dynamic Library Build Script
#
# Bu script OxCryptoWrapper'i dynamic library (.dylib) olarak derler
#

set -e

# Yapılandırma
PROJECT_NAME="OxCryptoWrapper"
DYLIB_NAME="libOxCryptoWrapper.dylib"
FRAMEWORKS="Foundation Security"
SDK="iphoneos"
ARCH="arm64"
MIN_VERSION="12.0"

# Renkler
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== oxide cry4me - iOS Dylib Build Script ===${NC}"
echo ""

# Kontrol: dosyalar var mı?
if [ ! -f "${PROJECT_NAME}.h" ]; then
    echo -e "${RED}Hata: ${PROJECT_NAME}.h bulunamadı${NC}"
    exit 1
fi

if [ ! -f "${PROJECT_NAME}.m" ]; then
    echo -e "${RED}Hata: ${PROJECT_NAME}.m bulunamadı${NC}"
    exit 1
fi

# Derleyici ayarları
CC="clang"
CFLAGS="-arch ${ARCH} -isysroot $(xcrun --sdk ${SDK} --show-sdk-path)"
CFLAGS+=" -miphoneos-version-min=${MIN_VERSION}"
CFLAGS+=" -fPIC -dynamiclib"
CFLAGS+=" -install_name @rpath/${DYLIB_NAME}"

# Framework'ler
for fw in ${FRAMEWORKS}; do
    CFLAGS+=" -framework ${fw}"
done

# Uyarı ayarları
CFLAGS+=" -Wall -Wextra"

echo -e "${YELLOW}Derleyici ayarları:${NC}"
echo "  CC: ${CC}"
echo "  SDK: ${SDK}"
echo "  Architecture: ${ARCH}"
echo "  Min Version: ${MIN_VERSION}"
echo ""

# Derleme
echo -e "${GREEN}Derleniyor...${NC}"
${CC} ${CFLAGS} \
    -o ${DYLIB_NAME} \
    ${PROJECT_NAME}.m \
    -ObjC

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Derleme başarılı${NC}"
    echo ""
    echo -e "${YELLOW}Çıktı: ${DYLIB_NAME}${NC}"

    # Binary bilgileri
    echo ""
    echo -e "${YELLOW}Binary bilgileri:${NC}"
    file ${DYLIB_NAME}
    otool -L ${DYLIB_NAME}

    # Sembol kontrolü
    echo ""
    echo -e "${YELLOW}Exported semboller (Crypto):${NC}"
    nm -gU ${DYLIB_NAME} | grep -E "(encrypt|decrypt|oxide)"

    echo ""
    echo -e "${YELLOW}Exported semboller (Hash):${NC}"
    nm -gU ${DYLIB_NAME} | grep -E "(md5|sha|hash)"

    echo ""
    echo -e "${YELLOW}Exported semboller (HMAC):${NC}"
    nm -gU ${DYLIB_NAME} | grep -E "(hmac)"

    echo ""
    echo -e "${YELLOW}Exported semboller (Base64):${NC}"
    nm -gU ${DYLIB_NAME} | grep -E "(base64)"

    echo ""
    echo -e "${YELLOW}Exported semboller (Key Generation):${NC}"
    nm -gU ${DYLIB_NAME} | grep -E "(key|iv|salt)"

    echo ""
    echo -e "${YELLOW}Exported semboller (Memory):${NC}"
    nm -gU ${DYLIB_NAME} | grep -E "(buffer|zero|alloc|free)"

    echo ""
    echo -e "${GREEN}=== Build tamamlandı ===${NC}"
    echo ""
    echo -e "${BLUE}Dylib boyutu:${NC}"
    ls -lh ${DYLIB_NAME}
    echo ""
else
    echo -e "${RED}✗ Derleme başarısız${NC}"
    exit 1
fi
