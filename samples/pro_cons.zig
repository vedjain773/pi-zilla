const timer = @import("irq").timer;
const irq = @import("irq").irq;

const console = @import("drivers").console;

const utils = @import("lib").utils;

const fork = @import("sched").fork;
const scheduler = @import("sched").scheduler;

const Semaphore = @import("sync").Semaphore;
const Mutex = @import("sync").Mutex;

const panic_handler = @import("panic.zig");
pub const panic = panic_handler.PanicHandler;

const N = 3;
var head: usize = 0;
var tail: usize = 0;
var item: u32 = 0;
var buf: [N]u32 = @splat(0);

var empty = Semaphore.init(N);
var full = Semaphore.init(0);
var mutex = Mutex.init();

fn gen_item() u32 {
    item += 1;
    return item;
}

fn insert_item(g_item: u32) void {
    buf[head] = g_item;
    head = (head + 1) % N;
}

fn remove_item() u32 {
    const popped = buf[tail];
    tail = (tail + 1) % N;
    return popped;
}

fn producer() noreturn {
    while (true) {
        const g_item = gen_item();
        empty.wait();

        mutex.acquire();
        console.print("Inserted: %d\n", .{g_item});
        insert_item(g_item);
        mutex.release();

        full.post();
        scheduler.sleep(5);
    }
}

fn consumer() noreturn {
    while (true) {
        full.wait();
        
        mutex.acquire();
        const r_item = remove_item();
        console.print("Removed: %d\n", .{r_item});
        mutex.release();

        empty.post();
        scheduler.sleep(5);
    }
}

export fn kernel_main() noreturn {
    console.setUart(console.UartType.mini_uart);    
    irq.vector_init();
    timer.timerInit();

    irq.enableInterruptController();
    irq.enable();  

    scheduler.initTasks(); 
    
    fork.copyProcess(@intFromPtr(&consumer), @intFromPtr("task1"))
        catch console.print("Failed to create task 1\n", .{});

    fork.copyProcess(@intFromPtr(&producer), @intFromPtr("task2"))
        catch console.print("Failed to create task 2\n", .{});

    fork.copyProcess(@intFromPtr(&producer), @intFromPtr("task3"))
        catch console.print("Failed to create task 3\n", .{});

    while(true) {
        scheduler.schedule();
    }
}
