const std = @import("std");
const zon = @import("build.zig.zon");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const reproducible = b.option(
        bool,
        "reproducible",
        "make a reproducible build",
    ) orelse false;

    const sanitizer = b.option(enum {
        undefined,
        thread,
        none,
    }, "sanitizer", "enable a sanitizer") orelse .none;

    const mod = b.addModule("factor", .{
        .target = target,
        .optimize = optimize,
        .link_libc = true,
        .link_libcpp = true,
        .sanitize_c = if (sanitizer == .undefined) .full else .off,
        .sanitize_thread = sanitizer == .thread,
    });

    mod.addIncludePath(b.path("vm/"));

    mod.addCMacro("FACTOR_VERSION", zon.version);
    mod.addCMacro("FACTOR_GIT_LABEL", "TODO");

    if (optimize == .Debug) {
        mod.addCMacro("FACTOR_DEBUG", "");
    }

    if (reproducible) {
        mod.addCMacro("FACTOR_REPRODUCIBLE", "");
    }

    mod.addCSourceFiles(.{
        .root = b.path("vm"),
        .files = &.{
            "ffi_test.c",
        },
        .flags = c_flags ++ &[_][]const u8{"-std=c99"},
    });
    mod.addCSourceFiles(.{
        .root = b.path("vm"),
        .files = &.{
            "aging_collector.cpp",
            "alien.cpp",
            "arrays.cpp",
            "bignum.cpp",
            "byte_arrays.cpp",
            "callbacks.cpp",
            "callstack.cpp",
            "code_blocks.cpp",
            "code_heap.cpp",
            "compaction.cpp",
            "contexts.cpp",
            "data_heap.cpp",
            "data_heap_checker.cpp",
            "debug.cpp",
            "dispatch.cpp",
            "entry_points.cpp",
            "errors.cpp",
            "factor.cpp",
            "full_collector.cpp",
            "gc.cpp",
            "image.cpp",
            "inline_cache.cpp",
            "instruction_operands.cpp",
            "io.cpp",
            "jit.cpp",
            "math.cpp",
            "mvm.cpp",
            "nursery_collector.cpp",
            "object_start_map.cpp",
            "objects.cpp",
            "primitives.cpp",
            "quotations.cpp",
            "run.cpp",
            "safepoints.cpp",
            "sampling_profiler.cpp",
            "strings.cpp",
            "to_tenured_collector.cpp",
            "tuples.cpp",
            "utilities.cpp",
            "vm.cpp",
            "words.cpp",
            "zstd.cpp",
        },
        .flags = common_flags,
    });

    switch (target.result.os.tag) {
        .freebsd, .dragonfly => {
            mod.addCSourceFiles(.{
                .root = b.path("vm/"),
                .files = &.{
                    "os-genunix.cpp",
                    "os-freebsd.cpp",
                    "mvm-unix.cpp",
                    "os-unix.cpp",
                    "main-unix.cpp",
                },
                .flags = common_flags,
            });
        },
        .linux => {
            mod.addCSourceFiles(.{
                .root = b.path("vm/"),
                .files = &.{
                    "os-genunix.cpp",
                    "os-linux.cpp",
                    "mvm-unix.cpp",
                    "os-unix.cpp",
                    "main-unix.cpp",
                },
                .flags = common_flags,
            });
        },
        .macos => {
            mod.linkFramework("Cocoa", .{});
            mod.linkFramework("AppKit", .{});
            mod.addCSourceFiles(.{
                .root = b.path("vm/"),
                .files = &.{
                    "os-macos.mm",
                    "mach_signal.cpp",
                    "mvm-unix.cpp",
                    "os-unix.cpp",
                    "main-unix.cpp",
                },
                .flags = common_flags,
            });
        },
        .windows => {
            switch (target.result.cpu.arch) {
                .x86_64 => {
                    mod.addCSourceFiles(.{
                        .root = b.path("vm/"),
                        .files = &.{
                            "os-windows.cpp",
                            "os-windows-x86.64.cpp",
                            "mvm-windows.cpp",
                            "main-windows.cpp",
                        },
                        .flags = common_flags,
                    });
                },
                .x86 => {
                    mod.addCSourceFiles(.{
                        .root = b.path("vm/"),
                        .files = &.{
                            "os-windows.cpp",
                            "os-windows-x86.32.cpp",
                            "mvm-windows.cpp",
                            "main-windows.cpp",
                        },
                        .flags = common_flags,
                    });
                },
                else => @panic("TODO"),
            }
        },
        else => @panic("TODO"),
    }

    switch (target.result.cpu.arch) {
        .aarch64 => {
            mod.addCSourceFiles(.{
                .root = b.path("vm/"),
                .files = &.{"cpu-arm.64.cpp"},
                .flags = common_flags,
            });
        },
        .x86_64, .x86 => {
            mod.addCSourceFiles(.{
                .root = b.path("vm/"),
                .files = &.{"cpu-x86.cpp"},
                .flags = common_flags,
            });
        },
        else => @panic("TODO"),
    }

    const exe = b.addExecutable(.{
        .name = "factor",
        .root_module = mod,
    });

    b.installArtifact(exe);
}

const c_flags: []const []const u8 = &.{
    // "-Wextra",
    // "-pedantic",
    "-Wno-date-time",
};

const cpp_flags: []const []const u8 = &.{
    "-std=c++11",
};

const common_flags = c_flags ++ cpp_flags;
