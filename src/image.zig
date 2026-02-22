// image.zig - Factor boot image loading and saving
// Image format documentation:
//   vm/image.hpp, vm/image.cpp

const std = @import("std");
const builtin = @import("builtin");

const bump_allocator = @import("bump_allocator.zig");
const c_api = @import("c_api.zig");
const code_blocks_mod = @import("code_blocks.zig");
const data_heap = @import("data_heap.zig");
const free_list = @import("free_list.zig");
const gc_mod = @import("gc.zig");
const io_mod = @import("io.zig");
const layouts = @import("layouts.zig");
const object_start_map = @import("object_start_map.zig");
const objects = @import("objects.zig");
const segments = @import("segments.zig");
const trampolines = @import("trampolines.zig");
const vm_mod = @import("vm.zig");
const write_barrier = @import("write_barrier.zig");

const Cell = layouts.Cell;
const Io = std.Io;

// Track mapped dummy pages to avoid duplicate mappings
var mapped_pages: std.AutoHashMap(Cell, void) = undefined;
var mapped_pages_initialized: bool = false;

// Workaround for Factor JIT code that reads expired alien.address
// values without checking the expired flag
fn mapDummyMemoryIfNeeded(address: Cell, allocator: std.mem.Allocator) void {
    // Only map addresses in the suspicious range (0x7fc0_0000_0000 - 0x7fd0_0000_0000)
    // These are addresses from previous VM runs that are no longer valid
    if (address < 0x7fc000000000 or address >= 0x7fd000000000) {
        return;
    }

    // Initialize hash map on first use
    if (!mapped_pages_initialized) {
        mapped_pages = std.AutoHashMap(Cell, void).init(allocator);
        mapped_pages_initialized = true;
    }

    // Round down to page boundary (64KB alignment like macOS uses)
    const page_size: Cell = 64 * 1024; // 64KB
    const page_addr = address & ~(page_size - 1);

    if (mapped_pages.contains(page_addr)) {
        return;
    }

    // Try to mmap at this specific address
    const result = std.c.mmap(
        @ptrFromInt(page_addr),
        page_size,
        .{ .READ = true, .WRITE = true },
        .{ .TYPE = .PRIVATE, .ANONYMOUS = true, .FIXED = true },
        -1,
        0,
    );

    if (result != std.c.MAP_FAILED) {
        // Workaround tracking: if put fails, worst case is a redundant mmap next call
        mapped_pages.put(page_addr, {}) catch {};
    }
}

// Image format constants
pub const image_magic: Cell = 0x0f0e0d0c;
pub const image_version: Cell = 4;

// Embedded image footer (for executables with appended images)
pub const EmbeddedImageFooter = extern struct {
    magic: Cell,
    image_offset: Cell,
};

// Image header structure - must match C++ exactly
pub const ImageHeader = extern struct {
    magic: Cell,
    version: Cell,
    // base address of data heap when image was saved
    data_relocation_base: Cell,
    // size of data heap (or version4_escape if 0 for compressed)
    data_size: Cell,
    // base address of code heap when image was saved
    code_relocation_base: Cell,
    // size of code heap
    code_size: Cell,
    // reserved fields (used for compression info in v4)
    reserved_1: Cell, // escaped_data_size if data_size==0
    reserved_2: Cell, // compressed_data_size
    reserved_3: Cell, // compressed_code_size
    reserved_4: Cell,
    // Initial special objects
    special_objects: [objects.special_object_count]Cell,
};

// VM parameters for initialization
pub const VMParameters = struct {
    embedded_image: bool = false,
    image_path: ?[]const u8 = null,
    executable_path: ?[]const u8 = null,
    datastack_size: Cell = 32 * @sizeOf(Cell) * 1024, // 256KB - matches C++ (32 * sizeof(cell) kilobytes)
    retainstack_size: Cell = 32 * @sizeOf(Cell) * 1024, // 256KB - matches C++ (32 * sizeof(cell) kilobytes)
    callstack_size: Cell = 128 * @sizeOf(Cell) * 1024, // 1MB - matches C++ (128 * sizeof(cell) kilobytes)
    young_size: Cell = 2 * 1024 * 1024, // 2MB - matches C++ VM (sizeof(cell)/4 << 20)
    aging_size: Cell = 4 * 1024 * 1024, // 4MB
    tenured_size: Cell = 192 * 1024 * 1024, // 192MB - matches C++ VM (24 * sizeof(cell) << 20)
    code_size: Cell = 8 * 1024 * 1024, // 8MB
    fep: bool = false,
    console: bool = true,
    signals: bool = true,
    max_pic_size: Cell = 3,
    callback_size: Cell = 256 * 1024, // 256KB
};

pub const ImageError = error{
    FileNotFound,
    ReadError,
    BadMagic,
    BadVersion,
    CompressedNotSupported,
    OutOfMemory,
    AllocationFailed,
};

const DlsymKey = struct { symbol: Cell, library: Cell };

// Image loader
pub const ImageLoader = struct {
    const Self = @This();

    vm: *vm_mod.FactorVM,
    io: Io,
    header: ImageHeader,
    params: VMParameters,

    // Allocated heap regions
    data_region: ?[]u8 = null,
    code_region: ?[]u8 = null,
    // Full mmap region for code (includes safepoint page) - needed for munmap
    code_mmap_region: ?[]align(std.heap.page_size_min) u8 = null,
    // Note: nursery_region, aging_region, cards, decks are now part of DataHeap
    // and are freed by DataHeap.deinit()
    // Real DataHeap pointer (for proper cleanup of mark bits etc)
    data_heap_ptr: ?*data_heap.DataHeap = null,
    // Code heap free list allocator
    code_free_list: ?*free_list.FreeListAllocator = null,

    // Cached dlopen(null) handle for symbol resolution
    null_dll_handle: ?*anyopaque = null,

    // Cache for dlsym lookups during image fixup (avoids redundant dlsym calls)
    dlsym_cache: std.AutoHashMapUnmanaged(DlsymKey, Cell) = .empty,

    pub fn init(vm: *vm_mod.FactorVM, io: Io, params: VMParameters) Self {
        return Self{
            .vm = vm,
            .io = io,
            .header = undefined,
            .params = params,
        };
    }

    fn readEmbeddedImageFooter(file: *std.c.FILE, footer: *EmbeddedImageFooter) !bool {
        const footer_size = @sizeOf(EmbeddedImageFooter);
        io_mod.safeFseek(file, -@as(i64, @intCast(footer_size)), 2) catch return false;

        var footer_bytes: [@sizeOf(EmbeddedImageFooter)]u8 = undefined;
        const items_read = io_mod.safeFread(@ptrCast(&footer_bytes), 1, footer_size, file) catch return false;

        if (items_read != footer_size) return false;

        footer.* = @bitCast(footer_bytes);
        return true;
    }

    pub fn loadImage(self: *Self, path: []const u8) !void {
        var path_buf: [4096]u8 = undefined;
        if (path.len >= path_buf.len) return ImageError.FileNotFound;
        @memcpy(path_buf[0..path.len], path);
        path_buf[path.len] = 0;
        const file = io_mod.safeFopen(path_buf[0..path.len :0].ptr, "rb") catch return ImageError.FileNotFound;
        defer io_mod.safeFclose(file) catch @panic("fclose failed");

        if (self.params.embedded_image) {
            var footer: EmbeddedImageFooter = undefined;
            const has_footer = readEmbeddedImageFooter(file, &footer) catch {
                return ImageError.BadMagic;
            };

            if (!has_footer or footer.magic != image_magic) {
                return ImageError.BadMagic;
            }

            io_mod.safeFseek(file, @intCast(footer.image_offset), 0) catch return ImageError.ReadError;
        }

        try self.loadImageFromFile(file);
    }

    fn loadImageFromFile(self: *Self, file: *std.c.FILE) !void {
        // Read header
        var header_bytes: [@sizeOf(ImageHeader)]u8 = undefined;
        const header_read = io_mod.safeFread(@ptrCast(&header_bytes), 1, @sizeOf(ImageHeader), file) catch {
            return ImageError.ReadError;
        };
        if (header_read != @sizeOf(ImageHeader)) {
            return ImageError.ReadError;
        }
        self.header = @bitCast(header_bytes);

        // Validate magic number
        if (self.header.magic != image_magic) {
            return ImageError.BadMagic;
        }

        // Validate version
        if (self.header.version != image_version) {
            return ImageError.BadVersion;
        }

        // Handle version4 escape format (must match C++ logic in image.cpp:297-302):
        // If version4_escape (data_size field) is 0, use escaped_data_size from reserved_1
        // Otherwise, compressed sizes are in data_size/code_size fields
        if (self.header.data_size == 0) {
            // !version4_escape: data_size was 0, so actual size is in reserved_1 (escaped_data_size)
            self.header.data_size = self.header.reserved_1; // escaped_data_size
            // In this mode, compressed_data_size and compressed_code_size are in reserved fields
            // (already in reserved_2 and reserved_3)
        } else {
            // version4_escape: data_size is non-zero, contains compressed_data_size
            // Copy these to the reserved fields for consistent access
            self.header.reserved_2 = self.header.data_size; // compressed_data_size = data_size
            self.header.reserved_3 = self.header.code_size; // compressed_code_size = code_size
        }

        // Check for compression - if compressed size != uncompressed size
        const data_compressed = self.header.data_size != self.header.reserved_2;
        const code_compressed = self.header.code_size != self.header.reserved_3;
        if (data_compressed or code_compressed) {
            return ImageError.CompressedNotSupported;
        }

        // Load data heap
        try self.loadDataHeap(file);

        // Load code heap
        try self.loadCodeHeap(file);

        // Copy special objects
        @memcpy(&self.vm.vm_asm.special_objects, &self.header.special_objects);

        // Initialize heap allocators after image load (like C++ init_data_heap/init_code_heap)
        // This must be done BEFORE fixup because C++ does it in load_code_heap
        try self.initDataHeapAllocators();
        try self.initCodeHeapAllocators();

        // Initialize code block index for frame walking (like C++ all_blocks set)
        // C++ does this in load_code_heap, BEFORE fixup
        if (self.vm.code) |code| {
            code.initializeAllBlocksSet() catch @panic("OOM");
        }

        // Fix up pointers (relocation)
        // Use wrapping subtraction since new address may be lower than original
        const data_offset = @intFromPtr(self.data_region.?.ptr) -% self.header.data_relocation_base;
        const code_offset = if (self.code_region) |cr| @intFromPtr(cr.ptr) -% self.header.code_relocation_base else 0;

        self.fixupHeaps(data_offset, code_offset);

        // CRITICAL: Rebuild the object_start map for all objects loaded from the image
        // Must be done AFTER fixupHeaps since object headers need to be valid first.
        // Without this, card scanning during GC can't find objects in dirty cards,
        // leading to stale nursery pointers not being updated.
        // Only scan the OCCUPIED portion of tenured space, not the free block area.
        if (self.vm.data) |heap| {
            const tenured_start = heap.tenured.start;
            const tenured_occupied_end = tenured_start + self.header.data_size;
            heap.tenured.object_start.rebuild(tenured_start, tenured_occupied_end);
        }

        // Rebuild code heap scan flags for all boot image code blocks.
        // Without this, blockHasCodePointers/blockHasLiterals return false
        // for boot image blocks, causing GC to miss marking PIC code blocks.
        if (self.vm.code) |code| {
            code.rebuildScanFlags(self.vm.allocator);
        }

        // Now make code heap executable
        self.makeCodeExecutable();

        if (comptime @import("builtin").mode == .Debug) {
            self.validateHeapSetup();
        }
    }

    fn validateHeapSetup(self: *Self) void {
        const heap = self.data_heap_ptr orelse return;

        const segment_start = heap.segment.start;
        const segment_end = heap.segment.end;
        const segment_size = segment_end - segment_start;

        const cards_ptr = @intFromPtr(heap.cards.cards.ptr);
        const cards_len = heap.cards.cards.len;
        const card_size: Cell = 256; // card_bits = 8

        // Expected card count for segment
        const expected_cards = (segment_size + card_size - 1) / card_size;
        std.debug.assert(cards_len >= expected_cards);

        // Verify nursery is within segment
        const nursery_start = self.vm.vm_asm.nursery.start;
        const nursery_end = self.vm.vm_asm.nursery.end;
        std.debug.assert(nursery_start >= segment_start and nursery_end <= segment_end);

        // Verify cards_offset formula: card for segment_start should be cards_ptr
        const cards_offset = self.vm.vm_asm.cards_offset;
        const test_card_addr: Cell = @bitCast(cards_offset +% (segment_start >> 8));
        std.debug.assert(test_card_addr == cards_ptr);

        // Card for segment_end - 1 should be within range
        const last_card_addr: Cell = @bitCast(cards_offset +% ((segment_end - 1) >> 8));
        std.debug.assert(last_card_addr < cards_ptr + cards_len);
    }

    fn loadDataHeap(self: *Self, file: *std.c.FILE) !void {
        const data_size = self.header.data_size;

        // Create a proper DataHeap with all generations in a single contiguous Segment.
        // This matches the C++ VM: data_heap allocates [tenured|aging|aging_semi|nursery]
        // in one mmap, with guard pages. The write barrier's card_offset formula only works
        // when all heap addresses are within the card table's coverage.
        const young_size = self.params.young_size;
        const aging_size = self.params.aging_size;
        const tenured_size = layouts.alignCell(@max((data_size * 3) / 2, self.params.tenured_size), layouts.data_alignment);

        const heap = try data_heap.DataHeap.init(self.vm.allocator, young_size, aging_size, tenured_size);
        self.data_heap_ptr = heap;

        // Set up the VM's data heap pointer and vm_asm (nursery, cards_offset, etc.)
        self.vm.setDataHeap(heap);

        // Store card/deck arrays for cleanup tracking
        self.vm.cards_array = heap.cards.cards;
        self.vm.decks_array = heap.decks.decks;

        const tenured_start = heap.tenured.start;

        // Read image data into the tenured portion of the heap
        const tenured_slice_ptr: [*]u8 = @ptrFromInt(tenured_start);
        const tenured_slice = tenured_slice_ptr[0..data_size];
        const bytes_read = try io_mod.safeFread(@ptrCast(tenured_slice.ptr), 1, data_size, file);

        if (bytes_read != data_size) {
            return ImageError.ReadError;
        }

        // Re-initialize the tenured free list allocator to account for occupied image data.
        // DataHeap.init() created one big free block covering all of tenured.
        // We need the first data_size bytes to be occupied, with a free block after.
        heap.tenured.free_list.deinit(); // Free the ArrayLists from the initial (wrong) allocator
        heap.tenured.free_list = free_list.FreeListAllocator.initForImageLoad(
            self.vm.allocator,
            tenured_start,
            heap.tenured.size,
            data_size,
        );

        // NOTE: Don't call scanAndFixGaps here - the image is properly compacted with no gaps.
        // Any apparent gaps during scanning would be misalignment artifacts due to un-relocated
        // tuple layout pointers (fixup hasn't run yet).

        self.data_region = tenured_slice_ptr[0..heap.tenured.size];
    }

    fn loadCodeHeap(self: *Self, file: *std.c.FILE) !void {
        const code_size = self.header.code_size;

        // IMPORTANT: Always allocate a code heap, even if the image has no code!
        // The C++ VM does this too: code = new code_heap(p->code_size);
        // The code heap is needed for:
        // 1. JIT compilation of new quotations
        // 2. Signal handlers that check vm.code for dispatch
        // 3. Callback trampolines

        // C++ default is 96 MB - we use the same to have room for new code blocks
        const default_code_heap_size: Cell = 96 * 1024 * 1024;
        const page_size = std.heap.page_size_min;
        const aligned_code_size = layouts.alignCell(code_size, page_size);
        // Use the larger of default size or image's code size
        const heap_size = @max(default_code_heap_size, aligned_code_size);

        // ARM64 BL/B instructions encode ±128MB relative offsets.
        // Code heap must not exceed this limit. Matches C++ code_heap constructor.
        if (comptime builtin.cpu.arch == .aarch64) {
            if (heap_size > 0x8000000) {
                @panic("Code heap too large for ARM64 (max 128MB)");
            }
        }

        // Total size includes safepoint page at the start (like C++ code_heap constructor)
        const total_size = page_size + heap_size;

        // On x86_64 macOS (including under Rosetta), use RWX permissions directly in mmap
        // Note: MAP_JIT is for Apple Silicon - on x86_64, standard RWX should work
        const is_arm64 = builtin.cpu.arch == .aarch64;
        const map_flags: std.c.MAP = if (is_arm64)
            .{ .TYPE = .PRIVATE, .ANONYMOUS = true, .JIT = true }
        else
            .{ .TYPE = .PRIVATE, .ANONYMOUS = true };
        const full_region = std.c.mmap(
            null,
            total_size,
            .{ .READ = true, .WRITE = true, .EXEC = true },
            map_flags,
            -1,
            0,
        );
        if (full_region == std.c.MAP_FAILED) {
            return ImageError.OutOfMemory;
        }

        // Store the full mmap region so we can munmap it correctly later
        const region_bytes: [*]align(std.heap.page_size_min) u8 = @ptrCast(@alignCast(full_region));
        self.code_mmap_region = region_bytes[0..total_size];

        // The first page is the safepoint page
        const safepoint_page = @intFromPtr(full_region);

        // Code starts after the safepoint page
        const code_start = region_bytes + page_size;

        // On Apple Silicon (ARM64), MAP_JIT memory is write-protected by default.
        // We need to disable write protection before writing to it.
        // IMPORTANT: This must be done BEFORE any writes, including when code_size == 0,
        // because initCodeHeapAllocators will write free blocks to the code heap later.
        if (is_arm64 and (builtin.os.tag == .macos or builtin.os.tag == .ios)) {
            const pthread_jit_write_protect_np = struct {
                extern "c" fn pthread_jit_write_protect_np(enabled: c_int) void;
            }.pthread_jit_write_protect_np;
            pthread_jit_write_protect_np(0); // Disable write protection (allow writes)
        }

        if (code_size > 0) {
            self.code_region = code_start[0..code_size];

            // Read code heap contents
            if (comptime builtin.cpu.arch == .aarch64) {
                // On macOS ARM64 with MAP_JIT, the kernel may not allow direct
                // read() into JIT memory. Use a temporary buffer and copy.
                const temp_buffer = self.vm.allocator.alloc(u8, code_size) catch {
                    return ImageError.OutOfMemory;
                };
                defer self.vm.allocator.free(temp_buffer);

                const bytes_read = try io_mod.safeFread(@ptrCast(temp_buffer.ptr), 1, code_size, file);

                if (bytes_read != code_size) {
                    return ImageError.ReadError;
                }

                @memcpy(self.code_region.?, temp_buffer);
            } else {
                // On x86_64, read directly into the code region
                const bytes_read = try io_mod.safeFread(@ptrCast(self.code_region.?.ptr), 1, code_size, file);

                if (bytes_read != code_size) {
                    return ImageError.ReadError;
                }
            }
        } else {
            // Empty code heap in image, but we still have allocated space
            self.code_region = code_start[0..0]; // Empty slice but with valid pointer
        }

        // Set up the CodeHeap struct in the VM
        // We allocate it with the VM's allocator
        const code_heap_struct = self.vm.allocator.create(vm_mod.CodeHeap) catch {
            return ImageError.OutOfMemory;
        };
        code_heap_struct.* = .{
            .seg = null, // We don't use segment struct here
            .safepoint_page = safepoint_page,
            .code_start = @intFromPtr(code_start),
            .code_size = heap_size, // Total heap size (not just loaded code)
            .allocator = self.vm.allocator,
            .remembered_sets = write_barrier.CodeHeapRememberedSets.init(self.vm.allocator),
            .marks = null,
        };
        self.vm.code = code_heap_struct;

        // Store the loaded image code size in the header for later use
        // (initCodeHeapAllocators will use this to set up free space)

        // Build the all_blocks index by scanning the code heap
        // This is done in initializeAllBlocksSet() below after fixup

        // Keep code writable for now - we'll make it executable after fixup
        // See makeCodeExecutable() called after fixupHeaps()
    }

    pub fn makeCodeExecutable(self: *Self) void {
        if (self.code_region) |cr| {
            const full_heap_size = if (self.vm.code) |code| code.code_size else cr.len;
            const aligned_code_size = layouts.alignCell(full_heap_size, std.heap.page_size_min);

            const is_arm64 = builtin.cpu.arch == .aarch64;
            if (is_arm64 and (builtin.os.tag == .macos or builtin.os.tag == .ios)) {
                // On ARM64 macOS with MAP_JIT, use pthread_jit_write_protect_np to switch
                // from write mode to execute mode. The memory is already mapped RWX,
                // but JIT write protection controls which mode is active.
                const pthread_jit_write_protect_np = struct {
                    extern "c" fn pthread_jit_write_protect_np(enabled: c_int) void;
                }.pthread_jit_write_protect_np;
                pthread_jit_write_protect_np(1); // Enable write protection (allow execution)
            } else {
                // For x86_64, ensure code is RWX (like C++ Factor)
                // The mmap already requested RWX, but call mprotect to be sure
                const code_page_ptr: *align(std.heap.page_size_min) anyopaque = @ptrCast(@alignCast(cr.ptr));
                _ = std.c.mprotect(code_page_ptr, aligned_code_size, .{ .READ = true, .WRITE = true, .EXEC = true });
            }
        }
    }

    fn fixupHeaps(self: *Self, data_offset: Cell, code_offset: Cell) void {
        // Fix up special objects array
        for (&self.vm.vm_asm.special_objects) |*obj| {
            if (!layouts.isImmediate(obj.*)) {
                obj.* = self.fixupPointer(obj.*, data_offset, code_offset);
            }
        }

        // Fix up all objects in data heap
        self.fixupDataHeap(data_offset, code_offset);

        // Fix up all code blocks in code heap
        self.fixupCodeHeap(data_offset, code_offset);

        // Free the dlsym cache — only needed during fixup
        self.dlsym_cache.deinit(self.vm.allocator);
        self.dlsym_cache = .empty;
    }

    fn fixupPointer(self: *Self, ptr: Cell, data_offset: Cell, code_offset: Cell) Cell {
        const type_tag = layouts.TAG(ptr);
        const untagged = layouts.UNTAG(ptr);

        // Data heap object types have tags 2-13 (array through dll)
        if (type_tag >= @intFromEnum(layouts.TypeTag.array) and type_tag <= @intFromEnum(layouts.TypeTag.dll)) {
            return layouts.RETAG(untagged +% data_offset, type_tag);
        }

        // Fixnum (tag 0) and false_object are immediates — no fixup needed.
        // Only check code range for the rare case of untagged code pointers.
        if (type_tag == 0 or ptr == layouts.false_object) {
            return ptr;
        }

        if (self.isCodeAddress(untagged)) {
            return layouts.RETAG(untagged +% code_offset, type_tag);
        }

        return ptr;
    }

    fn isCodeAddress(self: *const Self, addr: Cell) bool {
        const code_start = self.header.code_relocation_base;
        const code_end = code_start + self.header.code_size;
        return addr >= code_start and addr < code_end;
    }

    fn fixupDataHeap(self: *Self, data_offset: Cell, code_offset: Cell) void {
        // Walk through all objects in the data heap and fix up their slot pointers
        const data_start = @intFromPtr(self.data_region.?.ptr);
        const data_end = data_start + self.header.data_size;

        var current = data_start;
        while (current < data_end) {
            const obj: *layouts.Object = @ptrFromInt(current);

            if (obj.isFree()) {
                const free_size = obj.header & ~@as(Cell, 7);
                if (free_size == 0) break;
                current += free_size;
                continue;
            }

            // Get object type and size
            const obj_type = obj.getType();
            const size = objectSize(obj, obj_type, data_offset);

            // Fix up slots based on object type
            self.fixupObjectSlots(obj, obj_type, data_offset, code_offset);

            // Move to next object (aligned)
            current += layouts.alignCell(size, layouts.data_alignment);
        }
    }

    fn fixupObjectSlots(self: *Self, obj: *layouts.Object, obj_type: layouts.TypeTag, data_offset: Cell, code_offset: Cell) void {
        switch (obj_type) {
            .array => {
                const arr: *layouts.Array = @ptrCast(obj);
                const capacity_raw = arr.capacity;
                // Check if capacity looks like a fixnum
                if (!layouts.hasTag(capacity_raw, .fixnum)) {
                    return; // Skip this "array"
                }
                const capacity = layouts.untagFixnumUnsigned(capacity_raw);
                const arr_data = arr.data();
                for (0..capacity) |i| {
                    if (!layouts.isImmediate(arr_data[i])) {
                        arr_data[i] = self.fixupPointer(arr_data[i], data_offset, code_offset);
                    }
                }
            },
            .tuple => {
                const tup: *layouts.Tuple = @ptrCast(obj);
                // Get slot count BEFORE fixing layout pointer (using old address with offset)
                const old_layout_addr = layouts.UNTAG(tup.layout);
                var slot_count: Cell = 0;
                if (old_layout_addr != 0) {
                    const layout: *layouts.TupleLayout = @ptrFromInt(old_layout_addr +% data_offset);
                    slot_count = layouts.untagFixnumUnsigned(layout.size);
                }
                // Fix layout pointer
                if (!layouts.isImmediate(tup.layout)) {
                    tup.layout = self.fixupPointer(tup.layout, data_offset, code_offset);
                }
                // Fix slot data
                const data = tup.data();
                for (0..slot_count) |i| {
                    if (!layouts.isImmediate(data[i])) {
                        data[i] = self.fixupPointer(data[i], data_offset, code_offset);
                    }
                }
            },
            .word => {
                const w: *layouts.Word = @ptrCast(obj);
                // Fix tagged slots
                if (!layouts.isImmediate(w.name)) w.name = self.fixupPointer(w.name, data_offset, code_offset);
                if (!layouts.isImmediate(w.vocabulary)) w.vocabulary = self.fixupPointer(w.vocabulary, data_offset, code_offset);
                if (!layouts.isImmediate(w.def)) w.def = self.fixupPointer(w.def, data_offset, code_offset);
                if (!layouts.isImmediate(w.props)) w.props = self.fixupPointer(w.props, data_offset, code_offset);
                if (!layouts.isImmediate(w.pic_def)) w.pic_def = self.fixupPointer(w.pic_def, data_offset, code_offset);
                if (!layouts.isImmediate(w.pic_tail_def)) w.pic_tail_def = self.fixupPointer(w.pic_tail_def, data_offset, code_offset);
                if (!layouts.isImmediate(w.subprimitive)) w.subprimitive = self.fixupPointer(w.subprimitive, data_offset, code_offset);
                // entry_point is untagged code pointer
                if (w.entry_point != 0) w.entry_point +%= code_offset;
            },
            .quotation => {
                const q: *layouts.Quotation = @ptrCast(obj);
                if (!layouts.isImmediate(q.array)) q.array = self.fixupPointer(q.array, data_offset, code_offset);
                if (!layouts.isImmediate(q.cached_effect)) q.cached_effect = self.fixupPointer(q.cached_effect, data_offset, code_offset);
                // entry_point is untagged code pointer — fixup like C++ visit_object_code_block
                if (q.entry_point != 0) {
                    // C++ does: q->entry_point = fixup.fixup_code(q->code())->entry_point();
                    // q->code() = (code_block*)(entry_point) - 1, fixup adds code_offset
                    // The code_block's entry_point() returns the address right after the header
                    // This is equivalent to: entry_point += code_offset
                    q.entry_point +%= code_offset;
                }
            },
            .wrapper => {
                const w: *layouts.Wrapper = @ptrCast(obj);
                if (!layouts.isImmediate(w.object)) w.object = self.fixupPointer(w.object, data_offset, code_offset);
            },
            .string => {
                const s: *layouts.String = @ptrCast(obj);
                if (!layouts.isImmediate(s.aux)) s.aux = self.fixupPointer(s.aux, data_offset, code_offset);
            },
            .alien => {
                const a: *layouts.Alien = @ptrCast(obj);
                // Fix base pointer
                if (!layouts.isImmediate(a.base)) {
                    a.base = self.fixupPointer(a.base, data_offset, code_offset);
                }
                // Fix expired flag
                if (!layouts.isImmediate(a.expired)) {
                    a.expired = self.fixupPointer(a.expired, data_offset, code_offset);
                }
                // Update computed address after fixing base
                // Like C++: if base is not false, update address; otherwise mark as expired
                if (a.base != layouts.false_object) {
                    a.updateAddress();
                } else {
                    // Mark as expired - the old address is no longer valid
                    // Note: Like C++, we keep the old address value. Factor code should check
                    // the expired flag before using the alien, but JIT-compiled FFI code often
                    // reads alien.address directly. The old addresses may still be mapped.
                    if (a.address != 0) {
                        // Try to map dummy memory at this address to prevent crashes
                        // when Factor JIT code accesses it without checking expired
                        mapDummyMemoryIfNeeded(a.address, self.vm.allocator);
                    }
                    a.expired = self.vm.vm_asm.special_objects[@intFromEnum(objects.SpecialObject.canonical_true)];
                }
            },
            .dll => {
                const d: *layouts.Dll = @ptrCast(obj);
                if (!layouts.isImmediate(d.path)) d.path = self.fixupPointer(d.path, data_offset, code_offset);
                // Reload the DLL like C++ ffi_dlopen does
                d.handle = null;
                if (d.path != layouts.false_object and layouts.hasTag(d.path, .byte_array)) {
                    const path_ba: *const layouts.ByteArray = @ptrFromInt(layouts.UNTAG(d.path));
                    const path_len = layouts.untagFixnumUnsigned(path_ba.capacity);
                    const path_data = path_ba.data();

                    // Create null-terminated path
                    var path_buf: [1024]u8 = undefined;
                    if (path_len < path_buf.len) {
                        @memcpy(path_buf[0..path_len], path_data[0..path_len]);
                        path_buf[path_len] = 0;

                        // Try to load the DLL
                        d.handle = std.c.dlopen(@ptrCast(&path_buf), .{ .LAZY = true, .GLOBAL = true });
                    }
                }
            },
            .callstack => {
                // Callstack contains stack frames with return addresses that need fixing
                // We must walk the frames properly, like C++ iterate_callstack_object
                self.fixupCallstackObject(obj, code_offset);
            },
            // Types with no pointer slots to fix
            .bignum, .byte_array, .float, .fixnum, .f => {},
        }
    }

    // Fix up return addresses in a callstack object
    // This properly walks frames using frame sizes from code blocks
    // instead of treating every cell as a code address.
    fn fixupCallstackObject(self: *Self, obj: *layouts.Object, code_offset: Cell) void {
        const cs: *layouts.Callstack = @ptrCast(obj);
        const frame_length = layouts.untagFixnumUnsigned(cs.length);

        if (frame_length == 0) return;

        // FRAME_RETURN_ADDRESS for x86-64 is 0 (return address at top of frame)
        const FRAME_RETURN_ADDRESS: Cell = 0;
        const LEAF_FRAME_SIZE: Cell = 16;

        var frame_offset: Cell = 0;

        while (frame_offset < frame_length) {
            const frame_top = cs.frameTopAt(frame_offset);

            // Read the old (unrelocated) return address
            const ret_addr_ptr: *Cell = @ptrFromInt(frame_top + FRAME_RETURN_ADDRESS);
            const old_addr = ret_addr_ptr.*;

            if (old_addr == 0) {
                // End of callstack or invalid frame
                break;
            }

            // Translate the address by adding code_offset
            const fixed_addr = old_addr +% code_offset;

            // Look up the code block using the TRANSLATED address
            // (all_blocks was populated with final addresses before fixup)
            var frame_size: Cell = LEAF_FRAME_SIZE;

            if (self.vm.code) |code| {
                if (code.codeBlockForAddress(fixed_addr)) |block| {
                    frame_size = block.stackFrameSizeForAddress(fixed_addr);
                } else {
                    // Code block not found - this could happen if the callstack
                    // references code that doesn't exist. Use leaf frame size.
                }
            }

            if (frame_size == 0) {
                frame_size = LEAF_FRAME_SIZE;
            }

            // Write back the translated return address
            ret_addr_ptr.* = fixed_addr;

            // Move to next frame
            frame_offset += frame_size;
        }
    }

    fn fixupCodeHeap(self: *Self, data_offset: Cell, code_offset: Cell) void {
        // Walk through code blocks and fix up their embedded pointers
        if (self.code_region == null) return;

        const code_start = @intFromPtr(self.code_region.?.ptr);
        const code_end = code_start + self.header.code_size;

        var current = code_start;
        while (current < code_end) {
            const block = CodeBlock.fromAddress(current);

            if (block.isFree()) {
                const free_size = block.size();
                if (free_size == 0) break;
                current += free_size;
                continue;
            }

            const block_size = block.size();
            std.debug.assert(current + block_size <= code_end);

            // Fix up code block's tagged fields
            if (!layouts.isImmediate(block.owner)) {
                block.owner = self.fixupPointer(block.owner, data_offset, code_offset);
            }
            if (!layouts.isImmediate(block.parameters)) {
                block.parameters = self.fixupPointer(block.parameters, data_offset, code_offset);
            }
            if (!layouts.isImmediate(block.relocation)) {
                block.relocation = self.fixupPointer(block.relocation, data_offset, code_offset);
            }

            // Process relocation entries to fix embedded pointers in code
            // The relocation base is where the code WAS before loading
            const rel_base = block.entryPoint() -% code_offset;
            _ = self.fixupInstructionOperands(block, rel_base, data_offset, code_offset);

            current += block_size;
        }
    }

    fn fixupInstructionOperands(self: *Self, block: *CodeBlock, rel_base: Cell, data_offset: Cell, code_offset: Cell) usize {
        if (self.vm.code) |code| {
            if (code.isBlockUninitialized(block)) {
                return 0;
            }
        }

        // Skip if no relocation data
        if (block.relocation == layouts.false_object) return 0;

        // Get the relocation byte array (already fixed up)
        const relocation_ptr = layouts.UNTAG(block.relocation);
        if (relocation_ptr == 0) return 0;

        const rel_array: *layouts.ByteArray = @ptrFromInt(relocation_ptr);
        const rel_capacity = layouts.untagFixnumUnsigned(rel_array.capacity);
        const entry_count = rel_capacity / @sizeOf(RelocationEntry);

        if (entry_count == 0) return 0;

        const entries: [*]RelocationEntry = @ptrCast(@alignCast(rel_array.data()));

        // Parameter index tracks which literal we're on
        var param_index: Cell = 0;
        var safepoint_count: usize = 0;

        for (0..entry_count) |i| {
            const entry = entries[i];
            const rel_type = entry.getType();
            const rel_class = entry.getClass();
            const offset = entry.getOffset();

            // Compute the address in code where this value is stored
            const pointer = block.entryPoint() + offset;
            const old_offset = rel_base + offset;

            // Load the old value based on relocation class
            const old_value = loadRelocValue(pointer, rel_class, old_offset);

            // Compute the new value based on relocation type
            const new_value: Cell = switch (rel_type) {
                .literal => blk: {
                    // Data heap literal - fix if non-immediate
                    if (!layouts.isImmediate(old_value)) {
                        break :blk self.fixupPointer(old_value, data_offset, code_offset);
                    }
                    break :blk old_value;
                },
                .entry_point, .entry_point_pic, .entry_point_pic_tail, .here => blk: {
                    // Code block references - the value encodes a code address
                    // with the offset from entry point in the tag bits
                    const tag = layouts.TAG(old_value);
                    const code_addr = layouts.UNTAG(old_value);
                    break :blk layouts.RETAG(code_addr +% code_offset, tag);
                },
                .this => blk: {
                    // Reference to current code block's entry point
                    // C++ returns compiled->entry_point(), not the block address
                    break :blk block.entryPoint();
                },
                .untagged => old_value, // Untagged numbers don't need relocation
                .dlsym => blk: {
                    // DLL symbol - look up via cache to avoid redundant dlsym calls
                    const params_arr: *const layouts.Array = @ptrFromInt(layouts.UNTAG(block.parameters));
                    const key = DlsymKey{
                        .symbol = params_arr.data()[param_index],
                        .library = params_arr.data()[param_index + 1],
                    };
                    if (self.dlsym_cache.get(key)) |cached| {
                        break :blk cached;
                    }
                    const result = resolveDlsym(block, param_index);
                    self.dlsym_cache.put(self.vm.allocator, key, result) catch {};
                    break :blk result;
                },
                .trampoline => if (builtin.cpu.arch == .aarch64) @intFromPtr(&trampolines.trampoline) else unreachable,
                .trampoline2 => if (builtin.cpu.arch == .aarch64) @intFromPtr(&trampolines.trampoline2) else unreachable,
                .megamorphic_cache_hits => @intFromPtr(&self.vm.dispatch_stats.megamorphic_cache_hits),
                .vm => blk: {
                    // VM address + offset from parameter
                    // CRITICAL: Factor code expects pointer to VMAssemblyFields, not FactorVM
                    // The vm_asm contains the fields Factor JIT code accesses
                    const offset_value = getParameter(block, param_index);
                    std.debug.assert(layouts.hasTag(offset_value, .fixnum));
                    const vm_offset: isize = layouts.untagFixnum(offset_value);
                    const base: isize = @bitCast(@intFromPtr(&self.vm.vm_asm));
                    break :blk @bitCast(base + vm_offset);
                },
                .cards_offset => @bitCast(self.vm.vm_asm.cards_offset),
                .decks_offset => @bitCast(self.vm.vm_asm.decks_offset),
                .inline_cache_miss => @intFromPtr(&c_api.inline_cache_miss),
                .safepoint => blk: {
                    const safepoint_addr = if (self.vm.code) |code| code.safepoint_page else unreachable;
                    safepoint_count += 1;
                    break :blk safepoint_addr;
                },
            };

            // Bounds check: ensure the write stays within the code block
            const block_end = @intFromPtr(block) + block.size();
            const write_size: Cell = switch (rel_class) {
                .absolute_cell => @sizeOf(Cell),
                .absolute => @sizeOf(u32),
                .absolute_2 => @sizeOf(u16),
                .absolute_1 => 1,
                .relative => @sizeOf(i32),
                else => @sizeOf(u32), // ARM types
            };
            std.debug.assert(pointer <= block_end and pointer - write_size < block_end);

            // Store the new value
            storeRelocValue(pointer, rel_class, new_value);

            // Update parameter index for types that consume parameters
            param_index += entry.numberOfParameters();
        }

        return safepoint_count;
    }

    // Initialize data heap allocators after image load.
    // The DataHeap was already created in loadDataHeap with a proper contiguous Segment.
    // This just creates the GarbageCollector instance.
    fn initDataHeapAllocators(self: *Self) ImageError!void {
        const heap = self.data_heap_ptr orelse return ImageError.OutOfMemory;

        // Create GarbageCollector instance
        const gc_instance = self.vm.allocator.create(gc_mod.GarbageCollector) catch {
            return ImageError.OutOfMemory;
        };
        gc_instance.* = gc_mod.GarbageCollector.init(self.vm.allocator, self.vm, heap);
        self.vm.garbage_collector = gc_instance;
    }

    // Initialize code heap free list allocator after image load
    // This is analogous to C++ factor_vm::load_code_heap calling allocator->initial_free_list()
    fn initCodeHeapAllocators(self: *Self) ImageError!void {
        // The code heap already has allocated space from loadCodeHeap
        // We need to initialize a free list for the remaining space
        if (self.vm.code) |code| {
            const loaded_code_size = self.header.code_size;
            const total_heap_size = code.code_size;

            // Ensure code heap mark bits are initialized for full GC.
            code.ensureMarks(self.vm.allocator) catch {
                return ImageError.OutOfMemory;
            };

            // Allocate and initialize a new FreeListAllocator for the code heap
            const alloc_ptr = self.vm.allocator.create(free_list.FreeListAllocator) catch {
                return ImageError.OutOfMemory;
            };
            // Initialize with empty free list (we'll scan for free blocks below)
            alloc_ptr.* = free_list.FreeListAllocator{
                .start = code.code_start,
                .end = code.code_start + total_heap_size,
                .size = total_heap_size,
                .small_blocks = undefined,
                .large_blocks = .{},
                .free_block_count = 0,
                .free_space = 0,
                .non_empty_mask = 0,
                .allocator = self.vm.allocator,
            };
            for (&alloc_ptr.small_blocks) |*bucket| {
                bucket.* = .{};
            }
            // Store in code heap
            code.free_list = alloc_ptr;

            // Scan the loaded code for free blocks
            var scan_addr = code.code_start;
            const loaded_end = code.code_start + loaded_code_size;

            while (scan_addr < loaded_end) {
                const block: *code_blocks_mod.CodeBlock = @ptrFromInt(scan_addr);
                const block_size = block.size();
                if (block_size == 0) break;

                if (block.isFree()) {
                    alloc_ptr.addFreeBlock(scan_addr, block_size);
                }

                scan_addr += block_size;
            }

            // Add the remaining heap space (after loaded code) as a single large free block
            const remaining_space = total_heap_size - loaded_code_size;
            if (remaining_space >= free_list.min_block_size) {
                alloc_ptr.addFreeBlock(loaded_end, remaining_space);
            }

            // Validate free list integrity after initialization
            alloc_ptr.validateFreeList();

            code.free_list = alloc_ptr;
            self.code_free_list = alloc_ptr; // Store for cleanup
        }
    }

    pub fn deinit(self: *Self) void {
        if (self.code_free_list) |alloc| {
            self.vm.allocator.destroy(alloc);
            self.code_free_list = null;
        }
        if (self.vm.code) |code| {
            code.deinit();
            self.vm.allocator.destroy(code);
            self.vm.code = null;
        }

        // Free the DataHeap - this handles segment, cards, decks, marks, object_start
        if (self.data_heap_ptr) |heap| {
            if (self.vm.data) |current| {
                const current_heap: *data_heap.DataHeap = @ptrCast(@alignCast(current));
                if (current_heap == heap) {
                    // Still using original heap - call deinit which cleans everything
                    heap.deinit();
                } else {
                    // Heap was replaced (e.g., grown by GC); the current one needs cleanup
                    current_heap.deinit();
                }
                self.vm.data = null;
            }
            self.data_heap_ptr = null;
        }

        // Clear card/deck array refs (already freed by DataHeap.deinit)
        self.vm.cards_array = null;
        self.vm.decks_array = null;

        if (self.vm.garbage_collector) |gc_inst| {
            self.vm.allocator.destroy(gc_inst);
            self.vm.garbage_collector = null;
        }

        // Use the full mmap region for munmap (includes safepoint page)
        if (self.code_mmap_region) |region| {
            _ = std.c.munmap(@ptrCast(region.ptr), region.len);
            self.code_mmap_region = null;
            self.code_region = null; // code_region is a slice of code_mmap_region
        }

        if (mapped_pages_initialized) {
            mapped_pages.deinit();
            mapped_pages_initialized = false;
        }
    }
};

fn objectSize(obj: *layouts.Object, obj_type: layouts.TypeTag, data_offset: Cell) Cell {
    return switch (obj_type) {
        .array => blk: {
            const arr: *layouts.Array = @ptrCast(obj);
            break :blk @sizeOf(layouts.Array) + layouts.untagFixnumUnsigned(arr.capacity) * @sizeOf(Cell);
        },
        .bignum => blk: {
            const bn: *layouts.Bignum = @ptrCast(obj);
            break :blk @sizeOf(layouts.Bignum) + layouts.untagFixnumUnsigned(bn.capacity) * @sizeOf(Cell);
        },
        .byte_array => blk: {
            const ba: *layouts.ByteArray = @ptrCast(obj);
            break :blk @sizeOf(layouts.ByteArray) + layouts.untagFixnumUnsigned(ba.capacity);
        },
        .string => blk: {
            const str: *layouts.String = @ptrCast(obj);
            break :blk @sizeOf(layouts.String) + layouts.untagFixnumUnsigned(str.length);
        },
        .tuple => blk: {
            const tup: *layouts.Tuple = @ptrCast(obj);
            // Layout pointer is not yet fixed up - we need to apply offset to access it
            const old_layout_addr = layouts.UNTAG(tup.layout);
            if (old_layout_addr != 0) {
                // Apply data offset to get actual layout address
                const layout: *layouts.TupleLayout = @ptrFromInt(old_layout_addr +% data_offset);
                break :blk @sizeOf(layouts.Tuple) + layouts.untagFixnumUnsigned(layout.size) * @sizeOf(Cell);
            }
            break :blk @sizeOf(layouts.Tuple);
        },
        .quotation => @sizeOf(layouts.Quotation),
        .word => @sizeOf(layouts.Word),
        .wrapper => @sizeOf(layouts.Wrapper),
        .float => @sizeOf(layouts.BoxedFloat),
        .alien => @sizeOf(layouts.Alien),
        .dll => @sizeOf(layouts.Dll),
        .callstack => blk: {
            const cs: *layouts.Callstack = @ptrCast(obj);
            break :blk @sizeOf(layouts.Callstack) + layouts.untagFixnumUnsigned(cs.length);
        },
        .fixnum, .f => @sizeOf(layouts.Object), // Should not appear as heap objects
    };
}

// Get a parameter from a code block's parameters array
fn getParameter(block: *CodeBlock, param_index: Cell) Cell {
    std.debug.assert(block.parameters != layouts.false_object);
    std.debug.assert(layouts.hasTag(block.parameters, .array));
    const params: *const layouts.Array = @ptrFromInt(layouts.UNTAG(block.parameters));
    std.debug.assert(param_index < layouts.untagFixnumUnsigned(params.capacity));
    return params.data()[param_index];
}

fn resolveDlsym(block: *CodeBlock, param_index: Cell) Cell {
    std.debug.assert(block.parameters != layouts.false_object);
    std.debug.assert(layouts.hasTag(block.parameters, .array));
    const params: *const layouts.Array = @ptrFromInt(layouts.UNTAG(block.parameters));
    std.debug.assert(param_index + 1 < layouts.untagFixnumUnsigned(params.capacity));
    return code_blocks_mod.computeDlsymAddress(params, param_index);
}

// Extract the symbol name from an alien (or byte-array) containing a C string
pub fn extractSymbolName(alien_or_ba: Cell) [:0]const u8 {
    const tag = layouts.typeTag(alien_or_ba);

    // Could be a byte-array directly
    if (tag == .byte_array) {
        const ba: *const layouts.ByteArray = @ptrFromInt(layouts.UNTAG(alien_or_ba));
        // Validate capacity is a tagged fixnum
        if (!layouts.hasTag(ba.capacity, .fixnum)) {
            return "";
        }
        const len = layouts.untagFixnumUnsigned(ba.capacity);
        if (len == 0) return "";
        const data = ba.data();
        // Find null terminator
        var end: usize = 0;
        while (end < len and data[end] != 0) : (end += 1) {}
        const slice = data[0..end];
        return @ptrCast(slice);
    }

    // Could be an alien wrapping a byte-array
    if (tag == .alien) {
        const alien: *const layouts.Alien = @ptrFromInt(layouts.UNTAG(alien_or_ba));
        // The address field contains the computed address
        if (alien.address == 0) return "";
        const ptr: [*:0]const u8 = @ptrFromInt(alien.address);
        return std.mem.sliceTo(ptr, 0);
    }

    return "";
}

// Relocation types, classes, entries, and CodeBlock are defined in code_blocks.zig
const RelocationType = code_blocks_mod.RelocationType;
const RelocationClass = code_blocks_mod.RelocationClass;
const RelocationEntry = code_blocks_mod.RelocationEntry;
pub const CodeBlock = code_blocks_mod.CodeBlock;
const rel_arm_b_mask = code_blocks_mod.rel_arm_b_mask;
const rel_arm_b_cond_ldr_mask = code_blocks_mod.rel_arm_b_cond_ldr_mask;
const rel_arm_ldur_mask = code_blocks_mod.rel_arm_ldur_mask;
const rel_arm_cmp_mask = code_blocks_mod.rel_arm_cmp_mask;

fn loadRelocValueMasked(pointer: Cell, msb: u5, lsb: u5, scaling: u5) isize {
    const ptr: [*]const u8 = @ptrFromInt(pointer - @sizeOf(u32));
    const word = std.mem.readInt(i32, ptr[0..@sizeOf(u32)], .little);
    const shift_left: u5 = @intCast(31 - msb);
    // shift_right can be > 31 if msb < lsb (invalid), cap at 31 for safety
    const shift_right_raw: u6 = @intCast(31 - msb + lsb);
    const shift_right: u5 = if (shift_right_raw > 31) 31 else @intCast(shift_right_raw);
    const masked: i32 = (word << shift_left) >> shift_right;
    return @as(isize, masked) << @intCast(scaling);
}

fn storeRelocValueMasked(pointer: Cell, value: isize, mask: u32, lsb: u5, scaling: u5) void {
    const ptr: [*]u8 = @ptrFromInt(pointer - @sizeOf(u32));
    var word = std.mem.readInt(u32, ptr[0..@sizeOf(u32)], .little);
    const scaled: i32 = @intCast(value >> @intCast(scaling));
    const bits: u32 = (@as(u32, @bitCast(scaled)) << lsb) & mask;
    word = (word & ~mask) | bits;
    std.mem.writeInt(u32, ptr[0..@sizeOf(u32)], word, .little);
}

// Load a value from code based on relocation class
// Uses unaligned reads since code may have unaligned embedded pointers
fn loadRelocValue(pointer: Cell, rel_class: RelocationClass, relative_to: Cell) Cell {
    return switch (rel_class) {
        .absolute_cell => blk: {
            const ptr: [*]const u8 = @ptrFromInt(pointer - @sizeOf(Cell));
            break :blk std.mem.readInt(Cell, ptr[0..@sizeOf(Cell)], .little);
        },
        .absolute => blk: {
            const ptr: [*]const u8 = @ptrFromInt(pointer - @sizeOf(u32));
            break :blk std.mem.readInt(u32, ptr[0..@sizeOf(u32)], .little);
        },
        .relative => blk: {
            const ptr: [*]const u8 = @ptrFromInt(pointer - @sizeOf(i32));
            const rel_val = std.mem.readInt(i32, ptr[0..@sizeOf(i32)], .little);
            // Relative addresses: add position to get absolute
            break :blk @bitCast(@as(isize, rel_val) +% @as(isize, @bitCast(relative_to)));
        },
        .relative_arm_b => blk: {
            const rel_val = loadRelocValueMasked(pointer, 25, 0, 2);
            break :blk @bitCast(rel_val + @as(isize, @bitCast(relative_to)) - 4);
        },
        .relative_arm_b_cond_ldr => blk: {
            const rel_val = loadRelocValueMasked(pointer, 23, 5, 2);
            break :blk @bitCast(rel_val + @as(isize, @bitCast(relative_to)) - 4);
        },
        .absolute_arm_ldur => blk: {
            const imm = loadRelocValueMasked(pointer, 20, 12, 0);
            break :blk @bitCast(imm);
        },
        .absolute_arm_cmp => blk: {
            const imm = loadRelocValueMasked(pointer, 21, 10, 0);
            break :blk @bitCast(imm);
        },
        .absolute_2 => blk: {
            const ptr: [*]const u8 = @ptrFromInt(pointer - @sizeOf(u16));
            break :blk std.mem.readInt(u16, ptr[0..@sizeOf(u16)], .little);
        },
        .absolute_1 => blk: {
            const ptr: [*]const u8 = @ptrFromInt(pointer - @sizeOf(u8));
            break :blk ptr[0];
        },
        ._reserved7, ._reserved8, ._reserved9, ._reserved12, ._reserved13, ._reserved14, ._reserved15 => {
            std.debug.print("[RELOC] FATAL: invalid relocation class {} in loadRelocValue\n", .{@intFromEnum(rel_class)});
            unreachable;
        },
    };
}

// Store a value to code based on relocation class
// Uses unaligned writes since code may have unaligned embedded pointers
fn storeRelocValue(pointer: Cell, rel_class: RelocationClass, value: Cell) void {
    switch (rel_class) {
        .absolute_cell => {
            const ptr: [*]u8 = @ptrFromInt(pointer - @sizeOf(Cell));
            std.mem.writeInt(Cell, ptr[0..@sizeOf(Cell)], value, .little);
        },
        .absolute => {
            const ptr: [*]u8 = @ptrFromInt(pointer - @sizeOf(u32));
            std.mem.writeInt(u32, ptr[0..@sizeOf(u32)], @truncate(value), .little);
        },
        .relative => {
            const ptr: [*]u8 = @ptrFromInt(pointer - @sizeOf(i32));
            // Store relative offset
            const rel_val: i32 = @truncate(@as(isize, @bitCast(value)) -% @as(isize, @bitCast(pointer)));
            std.mem.writeInt(i32, ptr[0..@sizeOf(i32)], rel_val, .little);
        },
        .relative_arm_b => {
            const abs_val = @as(isize, @bitCast(value));
            const rel_val = abs_val - @as(isize, @bitCast(pointer));
            std.debug.assert(rel_val + 4 < 0x8000000);
            std.debug.assert(rel_val + 4 >= -0x8000000);
            std.debug.assert((rel_val & 3) == 0);
            storeRelocValueMasked(pointer, rel_val + 4, rel_arm_b_mask, 0, 2);
        },
        .relative_arm_b_cond_ldr => {
            const abs_val = @as(isize, @bitCast(value));
            const rel_val = abs_val - @as(isize, @bitCast(pointer));
            std.debug.assert(rel_val + 4 < 0x2000000);
            std.debug.assert(rel_val + 4 >= -0x2000000);
            std.debug.assert((rel_val & 3) == 0);
            storeRelocValueMasked(pointer, rel_val + 4, rel_arm_b_cond_ldr_mask, 5, 2);
        },
        .absolute_arm_ldur => {
            const abs_val = @as(isize, @bitCast(value));
            std.debug.assert(abs_val >= -256);
            std.debug.assert(abs_val <= 255);
            storeRelocValueMasked(pointer, abs_val, rel_arm_ldur_mask, 12, 0);
        },
        .absolute_arm_cmp => {
            const abs_val = @as(isize, @bitCast(value));
            std.debug.assert(abs_val >= 0);
            std.debug.assert(abs_val <= 4095);
            storeRelocValueMasked(pointer, abs_val, rel_arm_cmp_mask, 10, 0);
        },
        .absolute_2 => {
            const ptr: [*]u8 = @ptrFromInt(pointer - @sizeOf(u16));
            std.mem.writeInt(u16, ptr[0..@sizeOf(u16)], @truncate(value), .little);
        },
        .absolute_1 => {
            const ptr: [*]u8 = @ptrFromInt(pointer - @sizeOf(u8));
            ptr[0] = @truncate(value);
        },
        ._reserved7, ._reserved8, ._reserved9, ._reserved12, ._reserved13, ._reserved14, ._reserved15 => {
            std.debug.print("[RELOC] FATAL: invalid relocation class {} in storeRelocValue\n", .{@intFromEnum(rel_class)});
            unreachable;
        },
    }
}

// Save the current heap to an image file
pub fn saveImage(vm: *vm_mod.FactorVM, temp_path: [:0]const u8, final_path: [:0]const u8) !bool {
    // Get heap information - cast from opaque pointers to real types
    const heap_data_ptr = vm.data orelse return error.AllocationFailed;
    const heap_data: *data_heap.DataHeap = @ptrCast(@alignCast(heap_data_ptr));
    const heap_code = vm.code orelse return error.AllocationFailed;

    // Create image header
    var header: ImageHeader = undefined;
    header.magic = image_magic;
    header.version = image_version;

    // Data heap info - use tenured space
    header.data_relocation_base = heap_data.tenured.start;
    const data_size = heap_data.tenured.usedBytes();
    header.data_size = data_size; // Uncompressed (version4_escape mode)
    header.reserved_1 = data_size; // escaped_data_size
    header.reserved_2 = data_size; // compressed_data_size (same as uncompressed)
    header.reserved_4 = 0;

    // Code heap info
    // Use codeHeapExtent() instead of occupiedSpace() because the Zig VM does
    // not compact the code heap, so free blocks may be interleaved among
    // occupied ones. occupiedSpace() sums only non-free bytes, but we need the
    // full byte range up to the last occupied block so the image includes any
    // free blocks in the middle that the code heap walker will traverse.
    header.code_relocation_base = heap_code.code_start;
    const code_size = heap_code.codeHeapExtent();
    header.code_size = code_size;
    header.reserved_3 = code_size; // compressed_code_size (same as uncompressed)

    // Copy special objects
    @memcpy(&header.special_objects, &vm.vm_asm.special_objects);

    // Open temporary file for writing
    const file = io_mod.safeFopen(temp_path, "wb") catch {
        return false;
    };
    defer io_mod.safeFclose(file) catch @panic("fclose failed");

    // Write header
    const header_bytes = std.mem.asBytes(&header);
    _ = io_mod.safeFwrite(@ptrCast(header_bytes.ptr), 1, header_bytes.len, file) catch {
        return false;
    };

    // Write data heap
    if (data_size > 0) {
        const data_ptr: [*]const u8 = @ptrFromInt(heap_data.tenured.start);
        _ = io_mod.safeFwrite(@ptrCast(data_ptr), 1, data_size, file) catch {
            return false;
        };
    }

    // Write code heap
    if (code_size > 0) {
        const code_ptr: [*]const u8 = @ptrFromInt(heap_code.code_start);
        _ = io_mod.safeFwrite(@ptrCast(code_ptr), 1, code_size, file) catch {
            return false;
        };
    }

    // Move temp file to final location
    const C = struct {
        extern "c" fn rename([*:0]const u8, [*:0]const u8) c_int;
    };
    if (C.rename(temp_path, final_path) != 0) {
        return false;
    }

    return true;
}
