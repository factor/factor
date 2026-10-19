// Linux ARM coprocessor records: arch/arm/include/asm/ucontext.h.
const std = @import("std");
pub fn findFpscr(records: []u32) ?*u32 {
    var cursor: usize = 0;
    while (records.len - cursor >= 2) {
        const magic = records[cursor];
        const size = records[cursor + 1];
        if (magic == 0 or size == 0) return null;
        if (size < 8 or size & 7 != 0 or size / 4 > records.len - cursor) return null;
        if (magic == 0x56465001 and size >= 268) return &records[cursor + 66];
        cursor += size / 4;
    }
    return null;
}
pub fn status(records: []u32) u32 {
    return if (findFpscr(records)) |fpscr| fpscr.* else 0;
}
pub fn clearStatus(records: []u32) void {
    if (findFpscr(records)) |fpscr| fpscr.* &= ~@as(u32, 0x9f);
}
test "VFP record traversal preserves FPSCR controls and bounds" {
    var records: [128]u32 = @splat(0);
    records[0] = 0xb0d9ed01;
    records[1] = 8;
    records[2] = 0x56465001;
    records[3] = 288;
    records[68] = 0x0040009f;
    try std.testing.expectEqual(@as(u32, 0x0040009f), status(&records));
    clearStatus(&records);
    try std.testing.expectEqual(@as(u32, 0x00400000), status(&records));
    records[3] = 0xfffffff8;
    try std.testing.expect(findFpscr(&records) == null);
}
