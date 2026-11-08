pub const State = enum {
    TASK_RUNNING,
    TASK_READY,
    TASK_SLEEPING,
    TASK_WAITING,
    TASK_ZOMBIE,
};

const CPUContext = extern struct {
    x19: usize,
    x20: usize,
    x21: usize,
    x22: usize,
    x23: usize,
    x24: usize,
    x25: usize,
    x26: usize,
    x27: usize,
    x28: usize,
    fp: usize,
    sp: usize,
    pc: usize
};

pub const Task = struct {
    cpu_cxt: CPUContext,
    state: State,
    counter: u64,
    priority: u64,
    preempt_count: u64,
    wake_ticks: u64,
    wait_next: ?*Task
};

