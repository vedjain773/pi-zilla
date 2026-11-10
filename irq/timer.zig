const gpios = @import("drivers").gpio;
const utils = @import("lib").utils;
const scheduler = @import("sched").scheduler;

const BASE: usize = gpios.BASE;

pub const TIMER_CS: usize = (BASE+0x00003000);
pub const TIMER_CLO: usize = (BASE+0x00003004);
pub const TIMER_CHI: usize = (BASE+0x00003008);
pub const TIMER_C0: usize = (BASE+0x0000300C);
pub const TIMER_C1: usize = (BASE+0x00003010);
pub const TIMER_C2: usize = (BASE+0x00003014);
pub const TIMER_C3: usize = (BASE+0x00003018);

pub const TIMER_CS_M0: u32 = (1 << 0);
pub const TIMER_CS_M1: u32 = (1 << 1);
pub const TIMER_CS_M2: u32 = (1 << 2);
pub const TIMER_CS_M3: u32 = (1 << 3);

const interval: u32 = 200000;
var curr_val: u32 = 0;

pub fn getTimerVal() u32 {
    return utils.read32(TIMER_CLO);
}

pub fn timerInit() void {
    //Read current free-timer value
    curr_val = utils.read32(TIMER_CLO);

    //Add interval to the curerent value to make sure that the next Interrupt
    //fires at after that interval
    curr_val += interval;

    //write this value to the first compare register
    utils.write32(TIMER_C1, curr_val);
}

pub fn handleTimerIrq() void {
    //Increase the current value by the interval to make sure another Interrupt
    //fires after said interval and write this value to the first compare reg
    curr_val += interval;
    utils.write32(TIMER_C1, curr_val);

    //Acknowledge the interrupt
    utils.write32(TIMER_CS, TIMER_CS_M1);
    //print.print("Timer interrupt received!\n", .{});

    scheduler.timerTick();
}
