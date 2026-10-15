// Compiler capability probe, not Factor VM acceptance.
extern "c" fn puts([*:0]const u8) c_int;
pub fn main() void {
    _ = puts("m68k Zig libc execution");
}
