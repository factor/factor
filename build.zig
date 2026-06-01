const std = @import("std");

fn runCommand(b: *std.Build, argv: []const []const u8) []const u8 {
    return std.mem.trimEnd(u8, b.run(argv), "\n\r ");
}

pub fn build(b: *std.Build) void {
    // Use native target by default. The VM architecture must match the boot image.
    // Override with -Dtarget= if cross-compiling.
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const keep_symbols = b.option(bool, "keep_symbols", "Keep symbol names in release builds for debugging") orelse false;

    // Get git and date info at build time
    const git_label = runCommand(b, &.{ "git", "log", "-1", "--format=heads/master-%h" });
    const compile_time = runCommand(b, &.{ "date", "+%b %e %Y %H:%M:%S" });

    const options = b.addOptions();
    options.addOption([]const u8, "git_label", if (git_label.len > 0) git_label else "zig-vm");
    options.addOption([]const u8, "compile_time", if (compile_time.len > 0) compile_time else "");

    // macOS Mach exception handler imports (mach/pthread headers). Zig 0.17
    // removed @cImport from source; the headers are translated via a build
    // step and exposed to mach_signal.zig as the "c" module. Only macOS
    // references this module (gated in signals.zig), so only build it there.
    const c_module: ?*std.Build.Module = if (target.result.os.tag == .macos) blk: {
        const translate_c = b.addTranslateC(.{
            .root_source_file = b.path("src/mach_imports.h"),
            .target = target,
            .optimize = optimize,
            .link_libc = true,
        });
        break :blk translate_c.createModule();
    } else null;

    // Main Factor VM executable
    const exe = b.addExecutable(.{
        .name = "factor",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
            // Strip debug symbols in release builds to reduce binary size (~6x smaller)
            .strip = if (optimize != .Debug and !keep_symbols) true else null,
        }),
    });

    exe.root_module.addOptions("build_options", options);
    if (c_module) |m| {
        exe.root_module.addImport("c", m);
    }

    // Link libc for system calls
    exe.root_module.link_libc = true;

    // Export dynamic symbols so Factor runtime can find primitives via dlsym
    // This is equivalent to -rdynamic in GCC
    exe.rdynamic = true;

    // Platform-specific library linking
    if (target.result.os.tag == .macos) {
        // Link macOS frameworks (like the C++ Factor VM does)
        // These are needed so dlopen(NULL) can find system symbols
        // Use SDK paths for framework resolution
        const sdk_path = "/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk";
        // Always add framework path for both native and cross-compilation
        exe.root_module.addSystemFrameworkPath(.{ .cwd_relative = sdk_path ++ "/System/Library/Frameworks" });
        exe.root_module.addLibraryPath(.{ .cwd_relative = sdk_path ++ "/usr/lib" });
        // Link frameworks - Factor needs CoreFoundation for IO, Foundation for
        // ObjC runtime, and AppKit/Cocoa for GUI classes (NSStatusBar, etc.)
        // These must be linked so dlopen(NULL) can find ObjC class symbols.
        exe.root_module.linkFramework("CoreFoundation", .{});
        exe.root_module.linkFramework("Foundation", .{});
        exe.root_module.linkFramework("Cocoa", .{});
        exe.root_module.linkFramework("AppKit", .{});
        exe.root_module.linkFramework("OpenGL", .{});
        exe.root_module.linkFramework("CoreServices", .{});
        exe.root_module.linkFramework("CoreGraphics", .{});
        exe.root_module.linkFramework("CoreText", .{});
        exe.root_module.linkFramework("ApplicationServices", .{});
        exe.root_module.linkFramework("Carbon", .{});
    } else if (target.result.os.tag == .linux) {
        // Link math library for floor/ceil/etc
        exe.root_module.linkSystemLibrary("m", .{});
    }

    b.installArtifact(exe);

    // On macOS, also drop the binary into Factor.app/Contents/MacOS/factor and
    // refresh the ./factor symlink, mirroring `make`'s macos.app target. The
    // bundle (Info.plist, Resources, Frameworks) is already in the repo. Running
    // ./factor — which resolves into the bundle — gives the VM a proper bundle
    // context (GUI session, NSBundle mainBundle, resources) that a bare
    // zig-out/bin/factor lacks; without it Cocoa/UI code hangs headless.
    // We copy from the freshly-built artifact (not ./factor) so we never mv the
    // symlink over the real binary.
    if (target.result.os.tag == .macos) {
        // Run with cwd = build root, so the bundle paths stay relative.
        const mkdir_bundle = b.addSystemCommand(&.{ "mkdir", "-p", "Factor.app/Contents/MacOS", "Factor.app/Contents/Frameworks" });
        mkdir_bundle.setCwd(b.path("."));
        const copy_to_bundle = b.addSystemCommand(&.{"cp"});
        copy_to_bundle.setCwd(b.path("."));
        copy_to_bundle.addArtifactArg(exe);
        copy_to_bundle.addArg("Factor.app/Contents/MacOS/factor");
        copy_to_bundle.step.dependOn(&mkdir_bundle.step);
        const link_factor = b.addSystemCommand(&.{ "ln", "-sf", "Factor.app/Contents/MacOS/factor", "factor" });
        link_factor.setCwd(b.path("."));
        link_factor.step.dependOn(&copy_to_bundle.step);
        b.getInstallStep().dependOn(&link_factor.step);
    }

    // Run command
    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());

    run_cmd.addPassthruArgs();

    const run_step = b.step("run", "Run the Factor VM");
    run_step.dependOn(&run_cmd.step);

    // Unit tests
    const tests = b.addTest(.{
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });
    tests.root_module.link_libc = true;
    if (c_module) |m| {
        tests.root_module.addImport("c", m);
    }

    const run_tests = b.addRunArtifact(tests);
    const test_step = b.step("test", "Run tests");
    test_step.dependOn(&run_tests.step);

    const docs_step = b.step("docs", "Build docs");
    const docs = b.addObject(.{
        .name = "factor",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });
    docs.root_module.addOptions("build_options", options);
    if (c_module) |m| {
        docs.root_module.addImport("c", m);
    }
    const install_docs = b.addInstallDirectory(.{
        .source_dir = docs.getEmittedDocs(),
        .install_dir = .prefix,
        .install_subdir = "docs",
    });
    docs_step.dependOn(&install_docs.step);
}
