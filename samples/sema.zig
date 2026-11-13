const timer = @import("irq").timer;
const irq = @import("irq").irq;

const console = @import("drivers").console;

const utils = @import("lib").utils;

const fork = @import("sched").fork;
const scheduler = @import("sched").scheduler;

const Semaphore = @import("sync").Semaphore;

const panic_handler = @import("panic.zig");
pub const panic = panic_handler.PanicHandler;

var sema = Semaphore.init(0);

fn task1() noreturn {
    while (true) {
        console.print("Waiting...\n", .{});
        sema.wait();
        console.print("Resumed...\n", .{});
    }
}
fn task2() noreturn {
    while (true) {
        scheduler.sleep(5);
        console.print("Posting...\n", .{});
        sema.post();
    }
}

export fn kernel_main() noreturn {
    console.setUart(console.UartType.mini_uart);
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
