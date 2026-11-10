pub fn delay(time: usize) void {
    var i: usize = time;
    while (i != 0) {
        i = i - 1;
    }
}

pub fn read32(addr: usize) u32 {
    const ptr = @as(*volatile u32, @ptrFromInt(addr));
    return ptr.*;
}

pub fn write32(addr: usize, value: u32) void {
    const ptr = @as(*volatile u32, @ptrFromInt(addr));
    ptr.* = value;
}

pub fn getEl() u32 {
    var el: u32 = 0;

    asm volatile (//syscall
        "mrs %[result], CurrentEL"
        : [result] "=r" (el)
        :
    );

    el = el >> 2;
    return el;
}

pub fn clamp(x: i32, x_min: u32, x_max: u32) u32 {
    if (x <= @as(i32, @intCast(x_min))) return x_min;
    if (x >= @as(i32, @intCast(x_max))) return x_max;
    return @intCast(x);
}

pub fn rand(seed: u32) u32 {
    var state = seed;
    state ^= state << 13;
    state ^= state >> 17;
    state ^= state << 5;

    return state;
}

pub fn randRange(seed: u32, min: u32, max: u32) u32 {
    return min + rand(seed) % (max - min);
}
