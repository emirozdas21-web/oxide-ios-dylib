/**
 * frida_hook.js
 * oxide cry4me - iOS Dynamic Analysis Hook Script
 *
 * Bu script OxCryptoWrapper dylib'ini dinamik olarak analiz eder
 */

console.log("[*] oxide cry4me - Frida Hook Script Başlatıldı");

if (ObjC.available) {
    console.log("[+] Objective-C Runtime kullanılabilir");

    try {
        // OxCryptoWrapper sınıfını al
        var OxCryptoWrapper = ObjC.classes.OxCryptoWrapper;

        if (OxCryptoWrapper) {
            console.log("[+] OxCryptoWrapper sınıfı bulundu");

            // encryptData:withKey:iv: hook
            if (OxCryptoWrapper['+ encryptData:withKey:iv:']) {
                Interceptor.attach(OxCryptoWrapper['+ encryptData:withKey:iv:'].implementation, {
                    onEnter: function(args) {
                        console.log("\n[+] encryptData:withKey:iv: çağrıldı");

                        // args[0] = self (class)
                        // args[1] = _cmd (selector)
                        // args[2] = data (NSData*)
                        // args[3] = key (NSData*)
                        // args[4] = iv (NSData*)

                        var data = new ObjC.Object(args[2]);
                        var key = new ObjC.Object(args[3]);
                        var iv = new ObjC.Object(args[4]);

                        console.log("    Input length: " + data.length());
                        console.log("    Input hex: " + hexdump(data.bytes(), { length: Math.min(data.length(), 32) }));

                        console.log("    Key length: " + key.length());
                        console.log("    Key hex: " + hexdump(key.bytes(), { length: Math.min(key.length(), 32) }));

                        console.log("    IV length: " + iv.length());
                        console.log("    IV hex: " + hexdump(iv.bytes(), { length: Math.min(iv.length(), 16) }));

                        this.output = null;
                    },
                    onLeave: function(retval) {
                        console.log("[-] encryptData:withKey:iv: tamamlandı");

                        if (retval.toInt32() !== 0) {
                            var output = new ObjC.Object(retval);
                            console.log("    Output length: " + output.length());
                            console.log("    Output hex: " + hexdump(output.bytes(), { length: Math.min(output.length(), 32) }));
                        } else {
                            console.log("    Output: nil (hata)");
                        }
                    }
                });
            }

            // decryptData:withKey:iv: hook
            if (OxCryptoWrapper['+ decryptData:withKey:iv:']) {
                Interceptor.attach(OxCryptoWrapper['+ decryptData:withKey:iv:'].implementation, {
                    onEnter: function(args) {
                        console.log("\n[+] decryptData:withKey:iv: çağrıldı");

                        var data = new ObjC.Object(args[2]);
                        var key = new ObjC.Object(args[3]);
                        var iv = new ObjC.Object(args[4]);

                        console.log("    Input length: " + data.length());
                        console.log("    Input hex: " + hexdump(data.bytes(), { length: Math.min(data.length(), 32) }));

                        console.log("    Key length: " + key.length());
                        console.log("    Key hex: " + hexdump(key.bytes(), { length: Math.min(key.length(), 32) }));

                        console.log("    IV length: " + iv.length());
                        console.log("    IV hex: " + hexdump(iv.bytes(), { length: Math.min(iv.length(), 16) }));
                    },
                    onLeave: function(retval) {
                        console.log("[-] decryptData:withKey:iv: tamamlandı");

                        if (retval.toInt32() !== 0) {
                            var output = new ObjC.Object(retval);
                            console.log("    Output length: " + output.length());
                            console.log("    Output hex: " + hexdump(output.bytes(), { length: Math.min(output.length(), 32) }));
                        } else {
                            console.log("    Output: nil (hata)");
                        }
                    }
                });
            }

            // md5Hash: hook
            if (OxCryptoWrapper['+ md5Hash:']) {
                Interceptor.attach(OxCryptoWrapper['+ md5Hash:'].implementation, {
                    onEnter: function(args) {
                        console.log("\n[+] md5Hash: çağrıldı");

                        var data = new ObjC.Object(args[2]);
                        console.log("    Input length: " + data.length());
                        console.log("    Input hex: " + hexdump(data.bytes(), { length: Math.min(data.length(), 32) }));
                    },
                    onLeave: function(retval) {
                        console.log("[-] md5Hash: tamamlandı");

                        if (retval.toInt32() !== 0) {
                            var hash = new ObjC.Object(retval);
                            console.log("    MD5 Hash: " + hash.toString());
                        } else {
                            console.log("    Output: nil (hata)");
                        }
                    }
                });
            }

            // sha256Hash: hook
            if (OxCryptoWrapper['+ sha256Hash:']) {
                Interceptor.attach(OxCryptoWrapper['+ sha256Hash:'].implementation, {
                    onEnter: function(args) {
                        console.log("\n[+] sha256Hash: çağrıldı");

                        var data = new ObjC.Object(args[2]);
                        console.log("    Input length: " + data.length());
                        console.log("    Input hex: " + hexdump(data.bytes(), { length: Math.min(data.length(), 32) }));
                    },
                    onLeave: function(retval) {
                        console.log("[-] sha256Hash: tamamlandı");

                        if (retval.toInt32() !== 0) {
                            var hash = new ObjC.Object(retval);
                            console.log("    SHA256 Hash: " + hash.toString());
                        } else {
                            console.log("    Output: nil (hata)");
                        }
                    }
                });
            }

            // generateKeyFromPassword:salt:iterations: hook
            if (OxCryptoWrapper['+ generateKeyFromPassword:salt:iterations:']) {
                Interceptor.attach(OxCryptoWrapper['+ generateKeyFromPassword:salt:iterations:'].implementation, {
                    onEnter: function(args) {
                        console.log("\n[+] generateKeyFromPassword:salt:iterations: çağrıldı");

                        var password = new ObjC.Object(args[2]);
                        var salt = new ObjC.Object(args[3]);
                        var iterations = args[4];

                        console.log("    Password: " + password.toString());
                        console.log("    Salt length: " + salt.length());
                        console.log("    Salt hex: " + hexdump(salt.bytes(), { length: Math.min(salt.length(), 16) }));
                        console.log("    Iterations: " + iterations);
                    },
                    onLeave: function(retval) {
                        console.log("[-] generateKeyFromPassword:salt:iterations: tamamlandı");

                        if (retval.toInt32() !== 0) {
                            var key = new ObjC.Object(retval);
                            console.log("    Key length: " + key.length());
                            console.log("    Key hex: " + hexdump(key.bytes(), { length: Math.min(key.length(), 32) }));
                        } else {
                            console.log("    Output: nil (hata)");
                        }
                    }
                });
            }

            // generateRandomIV hook
            if (OxCryptoWrapper['+ generateRandomIV']) {
                Interceptor.attach(OxCryptoWrapper['+ generateRandomIV'].implementation, {
                    onEnter: function(args) {
                        console.log("\n[+] generateRandomIV çağrıldı");
                    },
                    onLeave: function(retval) {
                        console.log("[-] generateRandomIV tamamlandı");

                        if (retval.toInt32() !== 0) {
                            var iv = new ObjC.Object(retval);
                            console.log("    IV length: " + iv.length());
                            console.log("    IV hex: " + hexdump(iv.bytes(), { length: Math.min(iv.length(), 16) }));
                        } else {
                            console.log("    Output: nil (hata)");
                        }
                    }
                });
            }

            // sha1Hash: hook
            if (OxCryptoWrapper['+ sha1Hash:']) {
                Interceptor.attach(OxCryptoWrapper['+ sha1Hash:'].implementation, {
                    onEnter: function(args) {
                        console.log("\n[+] sha1Hash: çağrıldı");

                        var data = new ObjC.Object(args[2]);
                        console.log("    Input length: " + data.length());
                        console.log("    Input hex: " + hexdump(data.bytes(), { length: Math.min(data.length(), 32) }));
                    },
                    onLeave: function(retval) {
                        console.log("[-] sha1Hash: tamamlandı");

                        if (retval.toInt32() !== 0) {
                            var hash = new ObjC.Object(retval);
                            console.log("    SHA1 Hash: " + hash.toString());
                        } else {
                            console.log("    Output: nil (hata)");
                        }
                    }
                });
            }

            // hmacSHA256:data:key: hook
            if (OxCryptoWrapper['+ hmacSHA256:data:key:']) {
                Interceptor.attach(OxCryptoWrapper['+ hmacSHA256:data:key:'].implementation, {
                    onEnter: function(args) {
                        console.log("\n[+] hmacSHA256:data:key: çağrıldı");

                        var data = new ObjC.Object(args[2]);
                        var key = new ObjC.Object(args[3]);

                        console.log("    Data length: " + data.length());
                        console.log("    Data hex: " + hexdump(data.bytes(), { length: Math.min(data.length(), 32) }));
                        console.log("    Key length: " + key.length());
                        console.log("    Key hex: " + hexdump(key.bytes(), { length: Math.min(key.length(), 32) }));
                    },
                    onLeave: function(retval) {
                        console.log("[-] hmacSHA256:data:key: tamamlandı");

                        if (retval.toInt32() !== 0) {
                            var hmac = new ObjC.Object(retval);
                            console.log("    HMAC length: " + hmac.length());
                            console.log("    HMAC hex: " + hexdump(hmac.bytes(), { length: Math.min(hmac.length(), 32) }));
                        } else {
                            console.log("    Output: nil (hata)");
                        }
                    }
                });
            }

            // hmacMD5:data:key: hook
            if (OxCryptoWrapper['+ hmacMD5:data:key:']) {
                Interceptor.attach(OxCryptoWrapper['+ hmacMD5:data:key:'].implementation, {
                    onEnter: function(args) {
                        console.log("\n[+] hmacMD5:data:key: çağrıldı");

                        var data = new ObjC.Object(args[2]);
                        var key = new ObjC.Object(args[3]);

                        console.log("    Data length: " + data.length());
                        console.log("    Data hex: " + hexdump(data.bytes(), { length: Math.min(data.length(), 32) }));
                        console.log("    Key length: " + key.length());
                        console.log("    Key hex: " + hexdump(key.bytes(), { length: Math.min(key.length(), 32) }));
                    },
                    onLeave: function(retval) {
                        console.log("[-] hmacMD5:data:key: tamamlandı");

                        if (retval.toInt32() !== 0) {
                            var hmac = new ObjC.Object(retval);
                            console.log("    HMAC length: " + hmac.length());
                            console.log("    HMAC hex: " + hexdump(hmac.bytes(), { length: Math.min(hmac.length(), 32) }));
                        } else {
                            console.log("    Output: nil (hata)");
                        }
                    }
                });
            }

            // base64Encode: hook
            if (OxCryptoWrapper['+ base64Encode:']) {
                Interceptor.attach(OxCryptoWrapper['+ base64Encode:'].implementation, {
                    onEnter: function(args) {
                        console.log("\n[+] base64Encode: çağrıldı");

                        var data = new ObjC.Object(args[2]);
                        console.log("    Input length: " + data.length());
                        console.log("    Input hex: " + hexdump(data.bytes(), { length: Math.min(data.length(), 32) }));
                    },
                    onLeave: function(retval) {
                        console.log("[-] base64Encode: tamamlandı");

                        if (retval.toInt32() !== 0) {
                            var base64 = new ObjC.Object(retval);
                            console.log("    Base64: " + base64.toString());
                        } else {
                            console.log("    Output: nil (hata)");
                        }
                    }
                });
            }

            // base64Decode: hook
            if (OxCryptoWrapper['+ base64Decode:']) {
                Interceptor.attach(OxCryptoWrapper['+ base64Decode:'].implementation, {
                    onEnter: function(args) {
                        console.log("\n[+] base64Decode: çağrıldı");

                        var base64 = new ObjC.Object(args[2]);
                        console.log("    Base64: " + base64.toString());
                    },
                    onLeave: function(retval) {
                        console.log("[-] base64Decode: tamamlandı");

                        if (retval.toInt32() !== 0) {
                            var data = new ObjC.Object(retval);
                            console.log("    Output length: " + data.length());
                            console.log("    Output hex: " + hexdump(data.bytes(), { length: Math.min(data.length(), 32) }));
                        } else {
                            console.log("    Output: nil (hata)");
                        }
                    }
                });
            }

            // secureZeroBuffer:length: hook
            if (OxCryptoWrapper['+ secureZeroBuffer:length:']) {
                Interceptor.attach(OxCryptoWrapper['+ secureZeroBuffer:length:'].implementation, {
                    onEnter: function(args) {
                        console.log("\n[+] secureZeroBuffer:length: çağrıldı");
                        console.log("    Buffer: " + args[2]);
                        console.log("    Length: " + args[3]);
                    },
                    onLeave: function(retval) {
                        console.log("[-] secureZeroBuffer:length: tamamlandı");
                    }
                });
            }

            // C wrapper fonksiyonları hook
            var oxide_encrypt_c = Module.findExportByName("libOxCryptoWrapper.dylib", "oxide_encrypt_c");
            if (oxide_encrypt_c) {
                Interceptor.attach(oxide_encrypt_c, {
                    onEnter: function(args) {
                        console.log("\n[+] oxide_encrypt_c (C wrapper) çağrıldı");
                        console.log("    Input length: " + args[1]);
                        console.log("    Key length: " + args[3]);
                        console.log("    IV length: " + args[5]);
                    },
                    onLeave: function(retval) {
                        console.log("[-] oxide_encrypt_c tamamlandı");
                        console.log("    Output: " + retval);
                    }
                });
            }

            var oxide_decrypt_c = Module.findExportByName("libOxCryptoWrapper.dylib", "oxide_decrypt_c");
            if (oxide_decrypt_c) {
                Interceptor.attach(oxide_decrypt_c, {
                    onEnter: function(args) {
                        console.log("\n[+] oxide_decrypt_c (C wrapper) çağrıldı");
                        console.log("    Input length: " + args[1]);
                        console.log("    Key length: " + args[3]);
                        console.log("    IV length: " + args[5]);
                    },
                    onLeave: function(retval) {
                        console.log("[-] oxide_decrypt_c tamamlandı");
                        console.log("    Output: " + retval);
                    }
                });
            }

            var oxide_hmac_sha256_c = Module.findExportByName("libOxCryptoWrapper.dylib", "oxide_hmac_sha256_c");
            if (oxide_hmac_sha256_c) {
                Interceptor.attach(oxide_hmac_sha256_c, {
                    onEnter: function(args) {
                        console.log("\n[+] oxide_hmac_sha256_c (C wrapper) çağrıldı");
                        console.log("    Input length: " + args[1]);
                        console.log("    Key length: " + args[3]);
                    },
                    onLeave: function(retval) {
                        console.log("[-] oxide_hmac_sha256_c tamamlandı");
                        console.log("    Output: " + retval);
                    }
                });
            }

            var oxide_hmac_md5_c = Module.findExportByName("libOxCryptoWrapper.dylib", "oxide_hmac_md5_c");
            if (oxide_hmac_md5_c) {
                Interceptor.attach(oxide_hmac_md5_c, {
                    onEnter: function(args) {
                        console.log("\n[+] oxide_hmac_md5_c (C wrapper) çağrıldı");
                        console.log("    Input length: " + args[1]);
                        console.log("    Key length: " + args[3]);
                    },
                    onLeave: function(retval) {
                        console.log("[-] oxide_hmac_md5_c tamamlandı");
                        console.log("    Output: " + retval);
                    }
                });
            }

            var oxide_base64_encode_c = Module.findExportByName("libOxCryptoWrapper.dylib", "oxide_base64_encode_c");
            if (oxide_base64_encode_c) {
                Interceptor.attach(oxide_base64_encode_c, {
                    onEnter: function(args) {
                        console.log("\n[+] oxide_base64_encode_c (C wrapper) çağrıldı");
                        console.log("    Input length: " + args[1]);
                    },
                    onLeave: function(retval) {
                        console.log("[-] oxide_base64_encode_c tamamlandı");
                        console.log("    Output: " + retval);
                    }
                });
            }

            var oxide_base64_decode_c = Module.findExportByName("libOxCryptoWrapper.dylib", "oxide_base64_decode_c");
            if (oxide_base64_decode_c) {
                Interceptor.attach(oxide_base64_decode_c, {
                    onEnter: function(args) {
                        console.log("\n[+] oxide_base64_decode_c (C wrapper) çağrıldı");
                        console.log("    Base64 string: " + Memory.readUtf8String(args[0]));
                    },
                    onLeave: function(retval) {
                        console.log("[-] oxide_base64_decode_c tamamlandı");
                        console.log("    Output: " + retval);
                    }
                });
            }

            console.log("[+] Tüm hook'lar kuruldu");

        } else {
            console.log("[-] OxCryptoWrapper sınıfı bulunamadı");
            console.log("    Hint: libOxCryptoWrapper.dylib yüklenmiş mi?");
        }

    } catch (e) {
        console.log("[-] Hook kurulum hatası: " + e);
    }

} else {
    console.log("[-] Objective-C Runtime kullanılamıyor");
}

console.log("[*] Hook script'i aktif, fonksiyon çağrıları bekleniyor...");
