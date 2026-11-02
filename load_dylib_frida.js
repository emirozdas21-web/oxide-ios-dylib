/**
 * Frida script to load libOxCryptoWrapper.dylib
 * Usage: frida -U -f com.oxide.app -l load_dylib_frida.js --no-pause
 */

console.log("[*] Loading libOxCryptoWrapper.dylib...");

// Load the dylib
Module.load("/var/containers/Bundle/Application/*/OXIDE.app/Frameworks/libOxCryptoWrapper.dylib")
    .then(function(module) {
        console.log("[+] Successfully loaded: " + module.name);
        console.log("[+] Base address: " + module.base);
        console.log("[+] Size: " + module.size);

        // Find and log exported functions
        var exports = module.enumerateExports();
        console.log("[+] Exported functions:");
        exports.forEach(function(exp) {
            console.log("    - " + exp.name + " @ " + exp.address);
        });
    })
    .catch(function(err) {
        console.log("[-] Failed to load dylib: " + err);

        // Try alternative path
        console.log("[*] Trying alternative path...");
        Module.load("@executable_path/Frameworks/libOxCryptoWrapper.dylib")
            .then(function(module) {
                console.log("[+] Successfully loaded (alternative): " + module.name);
            })
            .catch(function(err2) {
                console.log("[-] Alternative path also failed: " + err2);
            });
    });

// Hook process resume to ensure dylib is loaded
Interceptor.attach(Module.findExportByName(null, "main"), {
    onEnter: function(args) {
        console.log("[*] main() called - dylib should be loaded");
    }
});

console.log("[*] Script loaded. Waiting for dylib to load...");
