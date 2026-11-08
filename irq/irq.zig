const gpios = @import("drivers").gpio;
const console = @import("drivers").console;
const utils = @import("lib").utils;
const timer = @import("timer.zig");

const BASE: usize = gpios.BASE;

pub const IRQ_BASIC_PENDING: usize = (BASE+0x0000B200);
pub const IRQ_PENDING_1: usize = (BASE+0x0000B204);
pub const IRQ_PENDING_2: usize = (BASE+0x0000B208);
pub const FIQ_CONTROL: usize = (BASE+0x0000B20C);
pub const ENABLE_IRQS_1: usize = (BASE+0x0000B210);
pub const ENABLE_IRQS_2: usize = (BASE+0x0000B214);
pub const ENABLE_BASIC_IRQS: usize = (BASE+0x0000B218);
pub const DISABLE_IRQS_1: usize = (BASE+0x0000B21C);
pub const DISABLE_IRQS_2: usize = (BASE+0x0000B220);
pub const DISABLE_BASIC_IRQS: usize = (BASE+0x0000B224);

const SYSTEM_TIMER_IRQ_0: u32 = @intCast(1 << 0);
const SYSTEM_TIMER_IRQ_1: u32 = @intCast(1 << 1);
const SYSTEM_TIMER_IRQ_2: u32 = @intCast(1 << 2);
const SYSTEM_TIMER_IRQ_4: u32 = @intCast(1 << 3);

const error_msgs = [16][] const u8 {
    "SYNC_INVALID_EL1t",
    "IRQ_INVALID_EL1t",
    "FIQ_INVALID_EL1t",
    "ERROR_INVALID_EL1T",

    "SYNC_INVALID_EL1h",
    "IRQ_INVALID_EL1h",
    "FIQ_INVALID_EL1h",
    "ERROR_INVALID_EL1h",

    "SYNC_INVALID_EL0_64",
    "IRQ_INVALID_EL0_64",
    "FIQ_INVALID_EL0_64",
    "ERROR_INVALID_EL0_64",

    "SYNC_INVALID_EL0_32",
    "IRQ_INVALID_EL0_32",
    "FIQ_INVALID_EL0_32",
    "ERROR_INVALID_EL0_32"
};

pub extern fn vector_init() callconv(.c) void;
pub extern fn enable() callconv(.c) void;
pub extern fn disable() callconv(.c) void;

pub extern fn save_and_disable() callconv(.c) usize;
pub extern fn restore(prev_state: usize) callconv(.c) void;

pub export fn show_invalid_entry_message(ty: u32, esr: usize, addr: usize) void {
    console.print("[Invalid entry message] %s, ESR: %x, address: %x\r\n", 
        .{error_msgs[ty], esr, addr});
}

pub fn enableInterruptController() void {
    utils.write32(ENABLE_IRQS_1, SYSTEM_TIMER_IRQ_1);
}

pub export fn handle_irq() void {
    const irq: u32 = utils.read32(IRQ_PENDING_1);

    switch (irq) {
        SYSTEM_TIMER_IRQ_1 => timer.handleTimerIrq(),
        else => console.print("Unknown pending irq: %x", .{irq}),
    }
}
