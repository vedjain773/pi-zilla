const gpios = @import("drivers").gpio;

const PAGE_SHIFT: usize = 12;
const TABLE_SHIFT: usize = 9;
const SECTION_SHIFT: usize = (PAGE_SHIFT + TABLE_SHIFT);

const PAGE_SIZE: usize = (1 << PAGE_SHIFT);
const SECTION_SIZE: usize = (1 << SECTION_SHIFT);

const LOW_MEMORY: usize = (2 * SECTION_SIZE);
const HIGH_MEMORY: usize = gpios.BASE;

const PAGE_MEMORY: usize = HIGH_MEMORY - LOW_MEMORY;
const PAGES: usize = (PAGE_MEMORY / PAGE_SIZE);

var mem_map :[PAGES]u16 = @splat(0);

pub extern fn memzero(src: usize, n: usize) callconv(.c) void;  

pub fn kMalloc() usize {
    for (mem_map, 0..) |_, i| {
        if (mem_map[i] == 0) {
            mem_map[i] = 1;
            return LOW_MEMORY + i * PAGE_SIZE;
        }
    }

    return 0;
}

pub fn kFree(addr: usize) void {
    const i: usize = (addr - LOW_MEMORY) / PAGE_SIZE;
    mem_map[i] = 0;
}
