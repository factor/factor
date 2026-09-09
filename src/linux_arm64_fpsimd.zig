// Linux arm64 UAPI sigcontext.__reserved records. The FPSIMD record must
// occur in this bounded area, never in extra_context's external storage.
const std = @import("std");
const builtin = @import("builtin");
const endian = builtin.cpu.arch.endian();
pub const fpsimd_magic: u32 = 0x46508001;
const fpsimd_size = 528;

// Byte-aligned access keeps this parser usable with synthetic record buffers
// as well as the kernel's 16-byte-aligned signal context. No allocation, I/O,
// or traversal of pointers supplied by extension records occurs here.
pub fn findFPSR(records: []u8) ?*align(1) u32 {
    var offset: usize = 0;
    while (records.len - offset >= 8) {
        const magic = std.mem.readInt(u32, records[offset..][0..4], endian);
        const size: usize = std.mem.readInt(u32, records[offset + 4 ..][0..4], endian);
        if (magic == 0 or size < 16 or size % 16 != 0 or size > records.len - offset)
            return null;
        if (magic == fpsimd_magic) {
            if (size < fpsimd_size) return null;
            return @ptrCast(records[offset + 8 ..][0..4].ptr);
        }
        offset += size;
    }
    return null;
}

pub fn status(records: []u8) u32 {
    const fpsr = findFPSR(records) orelse return 0;
    return fpsr.*;
}

pub fn clearStatus(records: []u8) void {
    const fpsr = findFPSR(records) orelse return;
    // IOC, DZC, OFC, UFC, IXC and IDC. Preserve QC and the other state;
    // in particular, do not change FPCR or the saved vector registers.
    fpsr.* &= ~@as(u32, 0x9f);
}

test "find FPSIMD after an unknown record and preserve unrelated state" {
    var records = [_]u8{0} ** 576;
    std.mem.writeInt(u32, records[0..4], 0x12345678, endian);
    std.mem.writeInt(u32, records[4..8], 16, endian);
    std.mem.writeInt(u32, records[16..20], fpsimd_magic, endian);
    std.mem.writeInt(u32, records[20..24], fpsimd_size, endian);
    std.mem.writeInt(u32, records[24..28], 0x0800009f, endian);
    std.mem.writeInt(u32, records[28..32], 0x11223344, endian);
    records[32] = 0xab;
    try std.testing.expectEqual(@as(u32, 0x0800009f), status(&records));
    clearStatus(&records);
    try std.testing.expectEqual(@as(u32, 0x08000000), status(&records));
    try std.testing.expectEqual(@as(u32, 0x11223344), std.mem.readInt(u32, records[28..32], endian));
    try std.testing.expectEqual(@as(u8, 0xab), records[32]);
}

test "reject missing truncated undersized and nonprogressing records" {
    var records = [_]u8{0} ** 544;
    try std.testing.expect(findFPSR(&records) == null);
    try std.testing.expect(findFPSR(records[0..7]) == null);
    std.mem.writeInt(u32, records[0..4], fpsimd_magic, endian);
    for ([_]u32{ 0, 1, 8, 17, 512, 560, 0xfffffff0 }) |size| {
        std.mem.writeInt(u32, records[4..8], size, endian);
        try std.testing.expect(findFPSR(&records) == null);
    }
    std.mem.writeInt(u32, records[0..4], 0x12345678, endian);
    std.mem.writeInt(u32, records[4..8], 544, endian);
    try std.testing.expect(findFPSR(&records) == null);
}
