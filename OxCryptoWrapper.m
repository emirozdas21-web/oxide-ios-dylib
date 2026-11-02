//
//  OxCryptoWrapper.m
//  oxide cry4me - iOS Dynamic Library Implementation
//
//  Cross-platform crypto wrapper implementation
//

#import "OxCryptoWrapper.h"
#import <CommonCrypto/CommonCrypto.h>
#import <CommonCrypto/CommonDigest.h>
#import <Security/Security.h>

@implementation OxCryptoWrapper

#pragma mark - Crypto Operations

+ (NSData *)encryptData:(NSData *)data
                 withKey:(NSData *)key
                      iv:(NSData *)iv {
    if (!data || !key || !iv) {
        return nil;
    }

    // Validate key and IV sizes for AES-256
    if (key.length != kCCKeySizeAES256 || iv.length != kCCBlockSizeAES128) {
        NSLog(@"[OxCryptoWrapper] Invalid key or IV size");
        return nil;
    }

    CCCryptorStatus status = kCCSuccess;
    size_t dataOutMoved = 0;
    size_t dataOutLength = data.length + kCCBlockSizeAES128; // PKCS7 padding

    NSMutableData *encryptedData = [NSMutableData dataWithLength:dataOutLength];

    status = CCCrypt(kCCEncrypt,
                     kCCAlgorithmAES,
                     kCCOptionPKCS7Padding,
                     key.bytes,
                     kCCKeySizeAES256,
                     iv.bytes,
                     data.bytes,
                     data.length,
                     encryptedData.mutableBytes,
                     encryptedData.length,
                     &dataOutMoved);

    if (status != kCCSuccess) {
        NSLog(@"[OxCryptoWrapper] Encryption failed with status: %d", status);
        return nil;
    }

    encryptedData.length = dataOutMoved;
    return encryptedData;
}

+ (NSData *)decryptData:(NSData *)data
                 withKey:(NSData *)key
                      iv:(NSData *)iv {
    if (!data || !key || !iv) {
        return nil;
    }

    // Validate key and IV sizes for AES-256
    if (key.length != kCCKeySizeAES256 || iv.length != kCCBlockSizeAES128) {
        NSLog(@"[OxCryptoWrapper] Invalid key or IV size");
        return nil;
    }

    CCCryptorStatus status = kCCSuccess;
    size_t dataOutMoved = 0;
    size_t dataOutLength = data.length + kCCBlockSizeAES128;

    NSMutableData *decryptedData = [NSMutableData dataWithLength:dataOutLength];

    status = CCCrypt(kCCDecrypt,
                     kCCAlgorithmAES,
                     kCCOptionPKCS7Padding,
                     key.bytes,
                     kCCKeySizeAES256,
                     iv.bytes,
                     data.bytes,
                     data.length,
                     decryptedData.mutableBytes,
                     decryptedData.length,
                     &dataOutMoved);

    if (status != kCCSuccess) {
        NSLog(@"[OxCryptoWrapper] Decryption failed with status: %d", status);
        return nil;
    }

    decryptedData.length = dataOutMoved;
    return decryptedData;
}

#pragma mark - Hash Operations

+ (NSString *)md5Hash:(NSData *)data {
    if (!data) {
        return nil;
    }

    unsigned char hash[CC_MD5_DIGEST_LENGTH];
    CC_MD5(data.bytes, (CC_LONG)data.length, hash);

    NSMutableString *hashString = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [hashString appendFormat:@"%02x", hash[i]];
    }

    return hashString;
}

+ (NSString *)sha256Hash:(NSData *)data {
    if (!data) {
        return nil;
    }

    unsigned char hash[CC_SHA256_DIGEST_LENGTH];
    CC_SHA256(data.bytes, (CC_LONG)data.length, hash);

    NSMutableString *hashString = [NSMutableString stringWithCapacity:CC_SHA256_DIGEST_LENGTH * 2];
    for (int i = 0; i < CC_SHA256_DIGEST_LENGTH; i++) {
        [hashString appendFormat:@"%02x", hash[i]];
    }

    return hashString;
}

+ (NSString *)sha1Hash:(NSData *)data {
    if (!data) {
        return nil;
    }

    unsigned char hash[CC_SHA1_DIGEST_LENGTH];
    CC_SHA1(data.bytes, (CC_LONG)data.length, hash);

    NSMutableString *hashString = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    for (int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++) {
        [hashString appendFormat:@"%02x", hash[i]];
    }

    return hashString;
}

#pragma mark - Key Generation

+ (NSData *)generateKeyFromPassword:(NSString *)password
                                salt:(NSData *)salt
                          iterations:(NSUInteger)iterations {
    if (!password || !salt) {
        return nil;
    }

    // PBKDF2-HMAC-SHA256 key derivation
    NSMutableData *derivedKey = [NSMutableData dataWithLength:kCCKeySizeAES256];

    int status = CCKeyDerivationPBKDF(kCCPBKDF2,
                                      password.UTF8String,
                                      password.length,
                                      salt.bytes,
                                      salt.length,
                                      kCCPRFHmacAlgSHA256,
                                      (uint)iterations,
                                      derivedKey.mutableBytes,
                                      derivedKey.length);

    if (status != kCCSuccess) {
        NSLog(@"[OxCryptoWrapper] Key derivation failed with status: %d", status);
        return nil;
    }

    return derivedKey;
}

+ (NSData *)generateRandomIV {
    NSMutableData *iv = [NSMutableData dataWithLength:kCCBlockSizeAES128];

    int status = SecRandomCopyBytes(kSecRandomDefault,
                                     iv.length,
                                     iv.mutableBytes);

    if (status != errSecSuccess) {
        NSLog(@"[OxCryptoWrapper] IV generation failed with status: %d", status);
        return nil;
    }

    return iv;
}

#pragma mark - HMAC Operations

+ (NSData *)hmacSHA256:(NSData *)data
                  key:(NSData *)key {
    if (!data || !key) {
        return nil;
    }

    NSMutableData *hmac = [NSMutableData dataWithLength:CC_SHA256_DIGEST_LENGTH];

    CCHmac(kCCHmacAlgSHA256,
           key.bytes, key.length,
           data.bytes, data.length,
           hmac.mutableBytes);

    return hmac;
}

+ (NSData *)hmacMD5:(NSData *)data
               key:(NSData *)key {
    if (!data || !key) {
        return nil;
    }

    NSMutableData *hmac = [NSMutableData dataWithLength:CC_MD5_DIGEST_LENGTH];

    CCHmac(kCCHmacAlgMD5,
           key.bytes, key.length,
           data.bytes, data.length,
           hmac.mutableBytes);

    return hmac;
}

#pragma mark - Base64 Operations

+ (NSString *)base64Encode:(NSData *)data {
    if (!data) {
        return nil;
    }

    return [data base64EncodedStringWithOptions:0];
}

+ (NSData *)base64Decode:(NSString *)base64String {
    if (!base64String) {
        return nil;
    }

    return [[NSData alloc] initWithBase64EncodedString:base64String options:0];
}

#pragma mark - Memory Management Bridge

+ (void *)allocateBuffer:(size_t)size {
    return malloc(size);
}

+ (void)freeBuffer:(void *)buffer {
    if (buffer) {
        free(buffer);
    }
}

+ (void)secureZeroBuffer:(void *)buffer length:(size_t)length {
    if (buffer && length > 0) {
        volatile uint8_t *p = (volatile uint8_t *)buffer;
        for (size_t i = 0; i < length; i++) {
            p[i] = 0;
        }
        // Compiler optimization engelleme
        __asm__ __volatile__("" ::: "memory");
    }
}

#pragma mark - C++ Bridge Implementation

#ifdef __cplusplus
extern "C" {
#endif

void* oxide_encrypt_c(const void* input, size_t input_len,
                      const void* key, size_t key_len,
                      const void* iv, size_t iv_len,
                      size_t* output_len) {
    NSData *inputData = [NSData dataWithBytes:input length:input_len];
    NSData *keyData = [NSData dataWithBytes:key length:key_len];
    NSData *ivData = [NSData dataWithBytes:iv length:iv_len];

    NSData *encrypted = [OxCryptoWrapper encryptData:inputData
                                             withKey:keyData
                                                  iv:ivData];

    if (!encrypted) {
        *output_len = 0;
        return NULL;
    }

    *output_len = encrypted.length;
    void* output = malloc(encrypted.length);
    memcpy(output, encrypted.bytes, encrypted.length);

    return output;
}

void* oxide_decrypt_c(const void* input, size_t input_len,
                      const void* key, size_t key_len,
                      const void* iv, size_t iv_len,
                      size_t* output_len) {
    NSData *inputData = [NSData dataWithBytes:input length:input_len];
    NSData *keyData = [NSData dataWithBytes:key length:key_len];
    NSData *ivData = [NSData dataWithBytes:iv length:iv_len];

    NSData *decrypted = [OxCryptoWrapper decryptData:inputData
                                             withKey:keyData
                                                  iv:ivData];

    if (!decrypted) {
        *output_len = 0;
        return NULL;
    }

    *output_len = decrypted.length;
    void* output = malloc(decrypted.length);
    memcpy(output, decrypted.bytes, decrypted.length);

    return output;
}

void oxide_free_c(void* buffer) {
    if (buffer) {
        free(buffer);
    }
}

void* oxide_hmac_sha256_c(const void* input, size_t input_len,
                          const void* key, size_t key_len,
                          size_t* output_len) {
    NSData *inputData = [NSData dataWithBytes:input length:input_len];
    NSData *keyData = [NSData dataWithBytes:key length:key_len];

    NSData *hmac = [OxCryptoWrapper hmacSHA256:inputData
                                          key:keyData];

    if (!hmac) {
        *output_len = 0;
        return NULL;
    }

    *output_len = hmac.length;
    void* output = malloc(hmac.length);
    memcpy(output, hmac.bytes, hmac.length);

    return output;
}

void* oxide_hmac_md5_c(const void* input, size_t input_len,
                       const void* key, size_t key_len,
                       size_t* output_len) {
    NSData *inputData = [NSData dataWithBytes:input length:input_len];
    NSData *keyData = [NSData dataWithBytes:key length:key_len];

    NSData *hmac = [OxCryptoWrapper hmacMD5:inputData
                                       key:keyData];

    if (!hmac) {
        *output_len = 0;
        return NULL;
    }

    *output_len = hmac.length;
    void* output = malloc(hmac.length);
    memcpy(output, hmac.bytes, hmac.length);

    return output;
}

void* oxide_base64_encode_c(const void* input, size_t input_len,
                            size_t* output_len) {
    NSData *inputData = [NSData dataWithBytes:input length:input_len];
    NSString *base64 = [OxCryptoWrapper base64Encode:inputData];

    if (!base64) {
        *output_len = 0;
        return NULL;
    }

    *output_len = base64.length + 1; // Include null terminator
    void* output = malloc(*output_len);
    memcpy(output, base64.UTF8String, *output_len);

    return output;
}

void* oxide_base64_decode_c(const char* base64_str,
                            size_t* output_len) {
    if (!base64_str) {
        *output_len = 0;
        return NULL;
    }

    NSString *base64String = [NSString stringWithUTF8String:base64_str];
    NSData *decoded = [OxCryptoWrapper base64Decode:base64String];

    if (!decoded) {
        *output_len = 0;
        return NULL;
    }

    *output_len = decoded.length;
    void* output = malloc(decoded.length);
    memcpy(output, decoded.bytes, decoded.length);

    return output;
}

#ifdef __cplusplus
}
#endif

@end
