const timer = @import("irq").timer;
const irq = @import("irq").irq;

const console = @import("drivers").console;

const utils = @import("lib").utils;

const fork = @import("sched").fork;
const scheduler = @import("sched").scheduler;

const pong = @import("apps/pong.zig");
const clock = @import("apps/clock.zig");

const panic_handler = @import("panic.zig");
pub const panic = panic_handler.PanicHandler;

export fn kernel_main() noreturn {
    console.setUart(console.UartType.mini_uart);
    irq.vector_init();
    timer.timerInit();

    irq.enableInterruptController();
    irq.enable();  

    scheduler.initTasks(); 

    fork.copyProcess(@intFromPtr(&pong.start), @intFromPtr("pong")) 
        catch console.print("Error while trying to start process 1\n", .{});

    fork.copyProcess(@intFromPtr(&clock.update), @intFromPtr("clock"))
        catch console.print("Error while trying to start process 2\n", .{});
        
    while(true) {
        scheduler.schedule();
    }
}
