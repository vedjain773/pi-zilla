const scheduler = @import("sched").scheduler;
const WaitQueue = @import("sched").WaitQueue;
const Task = @import("sched").task.Task;
const State = @import("sched").task.State;

const SpinLock = @import("spin.zig").SpinLock;

pub const Mutex =  struct {
    locked: bool,
    owner: ?*Task,
    guard: SpinLock,
    wait_queue: WaitQueue,

    pub fn init() Mutex {
        return .{
            .locked = false,
            .owner = null,
            .guard = .{
                .locked = 0,
            },
            .wait_queue = .{
                .head = null,
                .tail = null,
                .size = 0
            }
        };
    }

    pub fn acquire(self: *Mutex) void {
        while (true) {
            const prev_state = self.guard.lock();

            if (!self.locked) {
                self.locked = true;
                self.owner = scheduler.current; 
                self.guard.unlock(prev_state);
                break;
            }
            
            scheduler.current.*.state = State.TASK_WAITING;
            self.wait_queue.enqueue(scheduler.current);
            self.guard.unlock(prev_state);

            scheduler.schedule();
        }

        return;
    }

    pub fn release(self: *Mutex) void {
        const prev_state = self.guard.lock();

        if (self.owner != scheduler.current) {
            self.guard.unlock(prev_state);
            return;
        }

        if (!self.wait_queue.isEmpty()) {
            const popped: ?*Task = self.wait_queue.dequeue();
            popped.?.*.state = State.TASK_RUNNING; 
        }

        self.locked = false;
        self.owner = null;
        self.guard.unlock(prev_state);
    }
};
