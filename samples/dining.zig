const timer = @import("irq").timer;
const irq = @import("irq").irq;

const console = @import("drivers").console;

const utils = @import("lib").utils;

const fork = @import("sched").fork;
const scheduler = @import("sched").scheduler;

const Mutex = @import("sync").Mutex;
const SpinLock = @import("sync").SpinLock;

const panic_handler = @import("panic.zig");
pub const panic = panic_handler.PanicHandler;

const PhilState = enum {
    HUNGRY,
    EATING,
    THINKING,
};

const N: usize = 5;
var forks: [N]Mutex = undefined;
var philosopher_states: [N]PhilState = @splat(PhilState.HUNGRY);
var meals_eaten: [N]u32 = @splat(0);

var sl = SpinLock.init();

fn philosopher(id: usize) callconv(.c) noreturn {
    const a = id - 1;
    const b = id % N;
    const first = @min(a, b);
    const second = @max(a, b);

    const min: u32 = @intCast(5 + id);

    while (true) {
        const think_time = utils.randRange(timer.getTimerVal(), min, 15);

        philosopher_states[a] = PhilState.HUNGRY; 
        forks[first].acquire();
        forks[second].acquire();

        philosopher_states[a] = PhilState.EATING;
        meals_eaten[a] += 1;
        scheduler.sleep(5);

        forks[second].release();
        forks[first].release();

        philosopher_states[a] = PhilState.THINKING; 
        scheduler.sleep(think_time);
    }
}

fn print_stats() callconv(.c) noreturn {
    while (true) {
        const prev_state = sl.lock();
        const snapshot = philosopher_states;
        sl.unlock(prev_state);

        for (0..N) |i| {
            console.print("PHILOSOPHER %d: MEALS: %d STATE: %s\n",
                .{i, meals_eaten[i], @tagName(snapshot[i])});
        }

        console.print("\n", .{});
        scheduler.sleep(5);
    }
}

export fn kernel_main() noreturn {
    for (0..N) |i| {
        forks[i] = Mutex.init();
    }

    console.setUart(console.UartType.mini_uart);
    irq.vector_init();
    timer.timerInit();

    irq.enableInterruptController();
    irq.enable();  

    scheduler.initTasks(); 

    fork.copyProcess(@intFromPtr(&philosopher), 1)
        catch console.print("Failed to create task 1\n", .{}); 

    fork.copyProcess(@intFromPtr(&philosopher), 2)
        catch console.print("Failed to create task 2\n", .{}); 

    fork.copyProcess(@intFromPtr(&philosopher), 3)
        catch console.print("Failed to create task 3\n", .{});

    fork.copyProcess(@intFromPtr(&philosopher), 4)
        catch console.print("Failed to create task 4\n", .{});

    fork.copyProcess(@intFromPtr(&philosopher), 5)
        catch console.print("Failed to create task 5\n", .{});

    fork.copyProcess(@intFromPtr(&print_stats), 6)
        catch console.print("Failed to create task 6\n", .{});

    while(true) {
        scheduler.schedule();
    }
}
