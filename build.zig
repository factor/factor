const std = @import("std");

fn runCommand(b: *std.Build, argv: []const []const u8) []const u8 {
    return std.mem.trimEnd(u8, b.run(argv), "\n\r ");
}

pub fn build(b: *std.Build) void {
    // Use native target by default. The VM architecture must match the boot image.
    // Override with -Dtarget= if cross-compiling.
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // Get git and date info at build time
    const git_label = runCommand(b, &.{ "git", "log", "-1", "--format=heads/master-%h" });
    const compile_time = runCommand(b, &.{ "date", "+%b %e %Y %H:%M:%S" });

    const options = b.addOptions();
    options.addOption([]const u8, "git_label", if (git_label.len > 0) git_label else "zig-vm");
    options.addOption([]const u8, "compile_time", if (compile_time.len > 0) compile_time else "");

    // Main Factor VM executable
    const exe = b.addExecutable(.{
        .name = "factor",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });

    exe.root_module.addOptions("build_options", options);

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

    // Run command
    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

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
    const install_docs = b.addInstallDirectory(.{
        .source_dir = docs.getEmittedDocs(),
        .install_dir = .prefix,
        .install_subdir = "docs",
    });
    docs_step.dependOn(&install_docs.step);

    const cov_step = b.step("cov", "Generate code coverage");

    const cov_run = b.addSystemCommand(&.{ "kcov", "--clean", "--include-pattern=src/" });
    cov_run.addArg(b.getInstallPath(.prefix, "kcov-output"));
    cov_run.addArtifactArg(tests);

    cov_step.dependOn(&cov_run.step);
}
