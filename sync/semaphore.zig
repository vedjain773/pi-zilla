const scheduler = @import("sched").scheduler;
const WaitQueue = @import("sched").WaitQueue;
const Task = @import("sched").task.Task;
const State = @import("sched").task.State;

const SpinLock = @import("spin.zig").SpinLock;

pub const Semaphore = struct {
    count: usize,
    guard: SpinLock,
    wait_queue: WaitQueue,

    pub fn init(cnt: usize) Semaphore {
        return .{
            .count = cnt,
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

    pub fn wait(self: *Semaphore) void {
        while (true) {
            const prev_state = self.guard.lock();

            if (self.count > 0) {
                self.count -= 1;
                self.guard.unlock(prev_state);
                return;
            }

            scheduler.current.*.state = State.TASK_WAITING;
            self.wait_queue.enqueue(scheduler.current);
            self.guard.unlock(prev_state);

            scheduler.schedule();
        } 
    }

    pub fn post(self: *Semaphore) void {
        const prev_state = self.guard.lock();

        if (!self.wait_queue.isEmpty()) {
            const popped: ?*Task = self.wait_queue.dequeue();
            popped.?.*.state = State.TASK_RUNNING; 
        }
         
        self.count += 1;
        self.guard.unlock(prev_state);
    }
};
