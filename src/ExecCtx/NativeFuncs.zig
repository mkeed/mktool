const std = @import("std");
//const wasm = @import("wasm");
//const WasmExecCtx = wasm.Exec.WasmExecCtx;
//const Value = wasm.Exec.Value;
//const ValType = wasm.Exec.ValType;

pub const NativeModule = struct {
    name: []const u8,
    funcs: []const NativeFunc,
    pub const NativeFunc = struct {
        name: []const u8,
        //args: []const ValType,
        //func: *const fn (ctx: *anyopaque, args: []const Value, ret_buffer: []Value) []Value,
    };
};

pub fn times2(val: i32) i32 {
    return val * 2;
}

test {
    const info = @typeInfo(@TypeOf(times2)).@"fn";

    inline for (info.params) |p| {
        std.log.err("{}", .{p});
    }
}
