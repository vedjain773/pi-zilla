const SpinLock = @import("sync").SpinLock;
const WaitQueue = @import("wq.zig").WaitQueue;

const taskf = @import("task.zig");
const Task = taskf.Task;
const State = taskf.State;

const scheduler = @import("scheduler.zig");

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

        if (self.owner.? != scheduler.current) {
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
