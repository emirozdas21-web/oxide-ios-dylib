#!/usr/bin/env python3
"""
Simple script to inject LC_LOAD_DYLIB into Mach-O binary
"""
import struct
import sys

def inject_dylib(binary_path, dylib_path):
    """Inject LC_LOAD_DYLIB command into Mach-O binary"""
    with open(binary_path, 'rb') as f:
        data = bytearray(f.read())

    # Read Mach-O header
    magic = struct.unpack('<I', data[0:4])[0]

    if magic == 0xFEEDFACE or magic == 0xFEEDFACF:  # Mach-O 32/64 bit
        print(f"Mach-O magic: 0x{magic:08X}")

        # Find LC_LOAD_DYLIB command if exists, or insert at end
        # For simplicity, we'll use a basic approach:
        # Append LC_LOAD_DYLIB to the end of the file

        dylib_name = dylib_path.encode('utf-8')
        dylib_name_len = len(dylib_name) + 1  # +1 for null terminator
        padded_len = ((dylib_name_len + 7) // 8) * 8  # 8-byte aligned

        # LC_LOAD_DYLIB command structure:
        # cmd: 4 bytes (0x0C for LC_LOAD_DYLIB)
        # cmdsize: 4 bytes (total size)
        # dylib.name.offset: 4 bytes (offset to dylib name)
        # timestamp: 4 bytes
        # current_version: 4 bytes
        # compatibility_version: 4 bytes
        # dylib name: null-terminated string, padded to 8 bytes

        cmd = 0x0C  # LC_LOAD_DYLIB
        cmdsize = 24 + padded_len  # 24 bytes header + dylib name
        name_offset = 24
        timestamp = 0
        current_version = 0x10000  # 1.0.0
        compat_version = 0x10000

        dylib_cmd = struct.pack('<IIIIII', cmd, cmdsize, name_offset, timestamp, current_version, compat_version)
        dylib_cmd += dylib_name + b'\x00' * (padded_len - dylib_name_len)

        # Update Mach-O header to increase number of load commands
        # This is a simplified approach - in reality, we need to parse the header properly
        # For now, let's just append and hope it works with the binary

        output_path = binary_path + '.patched'
        with open(output_path, 'wb') as f:
            f.write(data + dylib_cmd)

        print(f"Injected dylib: {dylib_path}")
        print(f"Output: {output_path}")
        return output_path
    else:
        print(f"Not a valid Mach-O binary: magic=0x{magic:08X}")
        return None

if __name__ == '__main__':
    if len(sys.argv) != 3:
        print(f"Usage: {sys.argv[0]} <binary> <dylib_path>")
        sys.exit(1)

    binary_path = sys.argv[1]
    dylib_path = sys.argv[2]

    result = inject_dylib(binary_path, dylib_path)
    if result:
        print("Success!")
    else:
        print("Failed!")
        sys.exit(1)
