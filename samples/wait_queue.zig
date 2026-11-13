const timer = @import("irq").timer;
const irq = @import("irq").irq;

const console = @import("drivers").console;

const utils = @import("lib").utils;

const fork = @import("sched").fork;
const scheduler = @import("sched").scheduler;
const task = @import("sched").task;
const WaitQueue = @import("sched").WaitQueue;

const panic_handler = @import("panic.zig");
pub const panic = panic_handler.PanicHandler;

const Task = task.Task;
const State = task.State;

var counter: usize = 0;
var wait: WaitQueue = .{
    .head = null,
    .tail = null,
    .size = 0
}; 

fn task1() noreturn {
    while (true) {
        console.print("Task 1 before wait\n", .{});
        scheduler.wait(&wait);
        console.print("Task 1 after wait\n", .{});

        scheduler.sleep(1); 
    }
}

fn task2() noreturn {
    while (true) {
        console.print("Task 2 before wait\n", .{});
        scheduler.wait(&wait);
        console.print("Task 2 after wait\n", .{});

        scheduler.sleep(1);     }
}

fn task3() noreturn {
    while (true) {
        console.print("Task 3 running\n", .{});
        scheduler.sleep(10);
        counter += 1;

        if (counter == 10) {
            console.print("Waking up task 1 and 2...\n", .{});
            scheduler.wakeAll(&wait);
            counter = 0;
        }

        scheduler.sleep(1);
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

    fork.copyProcess(@intFromPtr(&task3), @intFromPtr("task3"))
        catch console.print("Failed to create task 3\n", .{}); 
        
    while(true) {
        scheduler.schedule();
    }
}
