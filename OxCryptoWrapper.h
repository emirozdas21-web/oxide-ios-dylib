//
//  OxCryptoWrapper.h
//  oxide cry4me - iOS Dynamic Library Skeleton
//
//  Cross-platform crypto wrapper, Android JNI karşılığı
//

#ifndef OxCryptoWrapper_h
#define OxCryptoWrapper_h

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface OxCryptoWrapper : NSObject

#pragma mark - Crypto Operations

/**
 * Android: Java_com_oxide_cry4me_Crypto_encrypt
 * iOS: [OxCryptoWrapper encryptData:withKey:iv:]
 *
 * @param data Şifrelenecek veri
 * @param key AES-256 key (32 bytes)
 * @param iv Initialization vector (16 bytes)
 * @return Şifrelenmiş veri
 */
+ (NSData * _Nullable)encryptData:(NSData *)data
                         withKey:(NSData *)key
                              iv:(NSData *)iv;

/**
 * Android: Java_com_oxide_cry4me_Crypto_decrypt
 * iOS: [OxCryptoWrapper decryptData:withKey:iv:]
 *
 * @param data Deşifrelenecek veri
 * @param key AES-256 key (32 bytes)
 * @param iv Initialization vector (16 bytes)
 * @return Deşifre edilmiş veri
 */
+ (NSData * _Nullable)decryptData:(NSData *)data
                         withKey:(NSData *)key
                              iv:(NSData *)iv;

#pragma mark - Hash Operations

/**
 * Android: Java_com_oxide_cry4me_Hash_md5
 * iOS: [OxCryptoWrapper md5Hash:]
 */
+ (NSString * _Nullable)md5Hash:(NSData *)data;

/**
 * Android: Java_com_oxide_cry4me_Hash_sha256
 * iOS: [OxCryptoWrapper sha256Hash:]
 */
+ (NSString * _Nullable)sha256Hash:(NSData *)data;

/**
 * Android: Java_com_oxide_cry4me_Hash_sha1
 * iOS: [OxCryptoWrapper sha1Hash:]
 */
+ (NSString * _Nullable)sha1Hash:(NSData *)data;

#pragma mark - Key Generation

/**
 * Android: Java_com_oxide_cry4me_KeyGen_generate
 * iOS: [OxCryptoWrapper generateKeyFromPassword:salt:iterations:]
 */
+ (NSData * _Nullable)generateKeyFromPassword:(NSString *)password
                                         salt:(NSData *)salt
                                   iterations:(NSUInteger)iterations;

/**
 * Android: Java_com_oxide_cry4me_IV_initVector
 * iOS: [OxCryptoWrapper generateRandomIV]
 */
+ (NSData * _Nullable)generateRandomIV;

#pragma mark - HMAC Operations

/**
 * Android: Java_com_oxide_cry4me_HMAC_sha256
 * iOS: [OxCryptoWrapper hmacSHA256:data:key:]
 */
+ (NSData * _Nullable)hmacSHA256:(NSData *)data
                            key:(NSData *)key;

/**
 * Android: Java_com_oxide_cry4me_HMAC_md5
 * iOS: [OxCryptoWrapper hmacMD5:data:key:]
 */
+ (NSData * _Nullable)hmacMD5:(NSData *)data
                         key:(NSData *)key;

#pragma mark - Base64 Operations

/**
 * Android: Java_com_oxide_cry4me_Base64_encode
 * iOS: [OxCryptoWrapper base64Encode:]
 */
+ (NSString * _Nullable)base64Encode:(NSData *)data;

/**
 * Android: Java_com_oxide_cry4me_Base64_decode
 * iOS: [OxCryptoWrapper base64Decode:]
 */
+ (NSData * _Nullable)base64Decode:(NSString *)base64String;

#pragma mark - Memory Management Bridge

/**
 * Android: malloc/free (native side)
 * iOS: ARC-managed + manual buffer support
 */
+ (void * _Nullable)allocateBuffer:(size_t)size;
+ (void)freeBuffer:(void *)buffer;

/**
 * Secure memory zeroing (anti-debugging)
 */
+ (void)secureZeroBuffer:(void *)buffer length:(size_t)length;

@end

#pragma mark - C++ Bridge (for native interop)

#ifdef __cplusplus
extern "C" {
#endif

// C-style function exports for potential native interop
// Android: Native C functions
// iOS: Corresponding C wrappers

void* oxide_encrypt_c(const void* input, size_t input_len,
                      const void* key, size_t key_len,
                      const void* iv, size_t iv_len,
                      size_t* output_len);

void* oxide_decrypt_c(const void* input, size_t input_len,
                      const void* key, size_t key_len,
                      const void* iv, size_t iv_len,
                      size_t* output_len);

void oxide_free_c(void* buffer);

// Extended C bridge functions
void* oxide_hmac_sha256_c(const void* input, size_t input_len,
                          const void* key, size_t key_len,
                          size_t* output_len);

void* oxide_hmac_md5_c(const void* input, size_t input_len,
                       const void* key, size_t key_len,
                       size_t* output_len);

void* oxide_base64_encode_c(const void* input, size_t input_len,
                            size_t* output_len);

void* oxide_base64_decode_c(const char* base64_str,
                            size_t* output_len);

#ifdef __cplusplus
}
#endif

NS_ASSUME_NONNULL_END

#endif /* OxCryptoWrapper_h */
