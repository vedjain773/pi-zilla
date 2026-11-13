const irq = @import("irq").irq;

pub extern fn load(addr: *usize) callconv(.c) usize;
pub extern fn store(addr: *usize, value: usize) callconv(.c) void;
pub extern fn compare_and_swap(addr: *usize, old: usize, new: usize) callconv(.c) bool;

//locked = 0 -> unlocked
//locked = 1 -> locked
pub const SpinLock = struct {
    locked: usize,

    pub fn init() SpinLock {
        return SpinLock {
            .locked = 0
        };
    }

    pub fn lock(self: *SpinLock) usize {
        const state = irq.save_and_disable();
        while (!compare_and_swap(&self.locked, 0, 1)) {}
        return state;
    }

    pub fn tryLock(self: *SpinLock) ?usize {
        const state = irq.save_and_disable();
        if (!compare_and_swap(&self.locked, 0, 1)) { 
            irq.restore(state);
            return null; 
        }
        return state;
    }

    pub fn unlock(self: *SpinLock, prev_state: usize) void {
        store(&self.locked, 0);
        irq.restore(prev_state);
    } 
};
