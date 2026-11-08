const timer = @import("irq").timer;
const irq = @import("irq").irq;

const console = @import("drivers").console;

const utils = @import("lib").utils;

const fork = @import("sched").fork;
const scheduler = @import("sched").scheduler;

const panic_handler = @import("panic.zig");
pub const panic = panic_handler.PanicHandler;

fn task1(arr: usize) callconv(.c) noreturn {
    while (true) {
        const str: *const[5:0]u8 = @ptrFromInt(arr);
        console.print("Running: %s\n", .{str});
        scheduler.sleep(5);
    }
}

fn task2(arr: usize) callconv(.c) noreturn {
    while (true) {
        const str: *const[5:0]u8 = @ptrFromInt(arr);
        console.print("Running %s\n", .{str});
        scheduler.sleep(5); 
    }
}

export fn kernel_main() noreturn {
    const num: u32 = utils.getEl();

    console.setUart(console.UartType.mini_uart);
    console.print("Exception-level: %d\n", .{num});

    irq.vector_init();
    timer.timerInit();

    irq.enableInterruptController();
    irq.enable();  

    scheduler.initTasks(); 

    fork.copyProcess(@intFromPtr(&task1), @intFromPtr("task1"))
        catch console.print("Failed to create task 1\n", .{});

    fork.copyProcess(@intFromPtr(&task2), @intFromPtr("task2"))
        catch console.print("Failed to create task 2\n", .{});
        
    while(true) {
        scheduler.schedule();
    }
}
