const std = @import("std");
const wasm = @import("wasm");
const WasmExecCtx = wasm.Exec.WasmExecCtx;
const Value = wasm.Exec.Value;
const ValType = wasm.Exec.ValType;

pub const ExecCtx = struct {
    exec: WasmExecCtx,
    pub fn init(
        alloc: std.mem.Allocator,
        prog: *const wasm.WasmFile,
    ) ExecCtx {
        return .{
            .exec = WasmExecCtx.init(alloc, prog),
        };
    }
    pub fn deinit(self: ExecCtx) void {
        self.exec.deinit();
    }
    pub fn call(self: ExecCtx, func: []const u8, args: []const Value, ret_buffer: []Value) ![]const Value {
        const fn_ref = self.exec.prog.get_export_func(func) orelse return error.InvalidFunc;
        _ = fn_ref;
        _ = args;
        return ret_buffer;
    }
};
