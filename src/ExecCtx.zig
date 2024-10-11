const std = @import("std");
const wasm = @import("wasm");
const WasmExecCtx = wasm.Exec.WasmExecCtx;
const Value = wasm.Exec.Value;
const ValType = wasm.Exec.ValType;

pub const ExecCtx = struct {
    exec: WasmExecCtx,
    pub fn init(
        alloc: std.mem.Allocator,
        prog: *const wasm.wasm,
    ) ExecCtx {
        return .{
            .exec = WasmExecCtx.init(alloc, prog),
        };
    }
    pub fn deinit(self: ExecCtx) void {
        self.prog.deinit();
    }
};
