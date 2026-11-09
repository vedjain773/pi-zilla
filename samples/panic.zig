const console = @import("drivers").console;
const muart = @import("drivers").muart;
const fuart = @import("drivers").fuart;

pub const PanicHandler = struct {
    pub fn call(msg: []const u8, ret_addr: ?usize) noreturn {
        _ = ret_addr;

        console.setUart(console.UartType.mini_uart);
        console.print("Panic!: ", .{});
        
        for (msg) |c| {
            fuart.send(c);
        }
        
        console.print("\n", .{});
        while (true) {}
    }

    pub fn castToNull() noreturn {
        call("Cast to NULL", @returnAddress());
        while (true) {}
    }

    pub fn copyLenMismatch() noreturn {
        call("Copy length mismatch", @returnAddress());
        while (true) {}
    }
    
    pub fn corruptSwitch() noreturn {
        call("Corrupt Switch", @returnAddress());
        while (true) {}
    }

    pub fn divideByZero() noreturn {
        call("Divide By zero", @returnAddress());
        while (true) {}
    }

    pub fn exactDivisionRemainder() noreturn {
        call("Exact division remainder", @returnAddress());
        while (true) {}
    }

    pub fn forLenMismatch() noreturn {
        call("For length mismatch", @returnAddress());
        while (true) {}
    }

    pub fn inactiveUnionField(active: anytype, accessed: @TypeOf(active)) noreturn {
        _ = accessed;
        call("Inactive union field", @returnAddress());
        while (true) {}
    }

    pub fn incorrectAlignment() noreturn {
        call("Incorrect alignment", @returnAddress());
        while (true) {}
    }

    pub fn integerOutOfBounds() noreturn {
        call("Integer out of bounds", @returnAddress());
        while (true) {}
    }

    pub fn integerOverflow() noreturn {
        call("Integer overflow", @returnAddress());
        while (true) {}
    }

    pub fn integerPartOutOfBounds() noreturn {
        call("Integer-part out of bounds", @returnAddress());
        while (true) {}
    }

    pub fn invalidEnumValue() noreturn {
        call("Invalid enum value", @returnAddress());
        while (true) {}
    }

    pub fn invalidErrorCode() noreturn {
        call("Invalid error code", @returnAddress());
        while (true) {}
    }

    pub fn memcpyAlias() noreturn {
        call("memcpy Alias", @returnAddress());
        while (true) {}
    }

    pub fn noreturnReturned() noreturn {
        call("No return returned", @returnAddress());
        while (true) {}
    }

    pub fn outOfBounds(index: usize, len: usize) noreturn {
        _ = index;
        _ = len;
        call("Out of bounds", @returnAddress());
        while (true) {}
    }

    pub fn reachedUnreachable() noreturn {
        call("Reached unreachable", @returnAddress());
        while (true) {}
    }

    pub fn sentinelMismatch(expected: anytype, found: @TypeOf(expected)) noreturn {
        _ = found;
        call("Sentinel mismatch", @returnAddress());
        while (true) {}
    }

    pub fn shiftRhsTooBig() noreturn {
        call("Shift RHS too big", @returnAddress());
        while (true) {}
    }

    pub fn shlOverflow() noreturn {
        call("Shift left overflow", @returnAddress());
        while (true) {}
    }

    pub fn shrOverflow() noreturn {
        call("Shift right overflow", @returnAddress());
        while (true) {}
    }

    pub fn sliceCastLenRemainder(src_len: usize) noreturn {
        _ = src_len;
        call("Slice cast length remainder", @returnAddress());
        while (true) {}
    }
    pub fn startGreaterThanEnd(start: usize, end: usize) noreturn {
        _ = start;
        _ = end;
        call("Start greater than end", @returnAddress());
        while (true) {}
    }
    pub fn unwrapError(err: anyerror) noreturn {
        _ = err;
        call("Unwrap error", @returnAddress());
        while (true) {}
    }

    pub fn unwrapNull() noreturn {
        call("Unwrap error", @returnAddress());
        while (true) {}
    }
};
