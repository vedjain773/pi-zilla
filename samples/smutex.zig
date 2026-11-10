const timer = @import("irq").timer;
const irq = @import("irq").irq;

const console = @import("drivers").console;

const utils = @import("lib").utils;

const fork = @import("sched").fork;
const scheduler = @import("sched").scheduler;
const mutexf = @import("sched").mutex;

const panic_handler = @import("panic.zig");
pub const panic = panic_handler.PanicHandler;

var os_mutex = mutexf.Mutex.init();
var shared_counter: usize = 0;

fn task1() noreturn {
    while (true) {
        os_mutex.acquire();
        
        shared_counter += 1;
        console.print("Counter T1: %d\n", .{shared_counter});
 
        os_mutex.release();
        scheduler.sleep(5);
    }
}
fn task2() noreturn {
    while (true) {
        os_mutex.acquire();
        
        shared_counter += 1;
        console.print("Counter T2: %d\n", .{shared_counter});

        scheduler.sleep(5);  
        os_mutex.release();
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
