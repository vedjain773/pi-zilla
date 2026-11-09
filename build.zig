const std = @import("std");

pub fn build(b: *std.Build) void {
    const optimize = b.standardOptimizeOption(.{}); 

    const target = b.resolveTargetQuery(.{
        .cpu_arch = .aarch64,
        .os_tag = .freestanding,
        .abi = .none,
    });
    
    const lib_mod = b.addModule("lib", .{
        .root_source_file = b.path("lib/root.zig"),
        .target = target
    });

    const mm_mod = b.addModule("mm", .{
        .root_source_file = b.path("mm/root.zig"),
        .target = target
    });

    const irq_mod = b.addModule("irq", .{
        .root_source_file = b.path("irq/root.zig"),
        .target = target
    }); 

    const boot_mod = b.addModule("boot", .{
        .root_source_file = b.path("boot/root.zig"),
        .target = target
    });

    const drivers_mod = b.addModule("drivers", .{
        .root_source_file = b.path("drivers/root.zig"),
        .target = target
    });

    const sched_mod = b.addModule("sched", .{
        .root_source_file = b.path("sched/root.zig"),
        .target = target
    });

    lib_mod.addImport("drivers", drivers_mod);
    
    mm_mod.addImport("drivers", drivers_mod);

    irq_mod.addImport("drivers", drivers_mod);
    irq_mod.addImport("sched", sched_mod);
    irq_mod.addImport("lib", lib_mod);
        
    drivers_mod.addImport("lib", lib_mod);

    sched_mod.addImport("boot", boot_mod);
    sched_mod.addImport("irq", irq_mod);
    sched_mod.addImport("mm", mm_mod);

    const sample = b.option(
        []const u8,
        "sample",
        "Sample to run (e.g. pong_clock, spinlock)",
    ) orelse "context_switch";

    const sample_path = b.fmt("samples/{s}.zig", .{sample});

    const kernel = b.addExecutable(.{
        .name = "kernel8.elf",
        .root_module = b.createModule(.{
            .root_source_file = b.path(sample_path),
            .target = target,
            .optimize = optimize,
            .imports = &.{
                .{ .name = "boot", .module = boot_mod },
                .{ .name = "irq", .module = irq_mod },
                .{ .name = "drivers", .module = drivers_mod },
                .{ .name = "sched", .module = sched_mod },
                .{ .name = "lib", .module = lib_mod },
            },
        }),
    }); 

    kernel.setLinkerScript(b.path("linker.ld"));
    kernel.root_module.strip = false;
    kernel.pie = false;

    kernel.root_module.addIncludePath(b.path("."));

    kernel.root_module.addCSourceFiles(.{
        .files = &[_][]const u8{
            "./asm/boot.S",
            "./asm/mm.S",
            "./asm/entry.S",
            "./asm/irq.S",
            "./asm/schedule.S",
            "./asm/atomic.S"
        },
        .flags = &[_][]const u8{ "-x", "assembler-with-cpp" },
    });

    b.installArtifact(kernel);
    const elf = kernel.getEmittedBin();

    const qemu_dbg = b.addSystemCommand(&.{
        "qemu-system-aarch64",
        "-M", "raspi3b",
        "-serial", "null",
        "-serial", "stdio",
        "-display", "none",
    });

    qemu_dbg.addArg("-kernel");
    qemu_dbg.addFileArg(elf);
    qemu_dbg.step.dependOn(&kernel.step);

    const qemu_dbg_step = b.step(
        "qemu-dbg",
        "Run kernel in QEMU without display with a gdb remote server at port 1234"
        );
    qemu_dbg_step.dependOn(&qemu_dbg.step);

    const qemu_nd = b.addSystemCommand(&.{
        "qemu-system-aarch64",
        "-M", "raspi3b",
        "-serial", "null",
        "-serial", "stdio",
        "-display", "none",
    });

    qemu_nd.addArg("-kernel");
    qemu_nd.addFileArg(elf);
    qemu_nd.step.dependOn(&kernel.step);

    const qemu_nd_step = b.step("qemu-nd", "Run kernel in QEMU without display");
    qemu_nd_step.dependOn(&qemu_nd.step);

    const qemu_d = b.addSystemCommand(&.{
        "qemu-system-aarch64",
        "-M", "raspi3b",
        "-serial", "null",
        "-serial", "stdio",
        "-display", "gtk",
    });

    qemu_d.addArg("-kernel");
    qemu_d.addFileArg(elf);
    qemu_d.step.dependOn(&kernel.step);

    const qemu_d_step = b.step("qemu-d", "Run kernel in QEMU with display");
    qemu_d_step.dependOn(&qemu_d.step);
}
