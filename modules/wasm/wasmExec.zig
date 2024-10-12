const std = @import("std");
const wasm = @import("wasm.zig");
const wasmIns = @import("wasmInstructions.zig");
pub const ValType = enum {
    i32,
    i64,
    f32,
    f64,
    v128,
    ref_null,
    ref_funcaddr,
    ref_extern,
};

pub const Value = union(ValType) {
    i32: i32,
    i64: i64,
    f32: f32,
    f64: f64,
    v128: i128,
    ref_null: void,
    ref_funcaddr: u32,
    ref_extern: u32,
};

pub const Frame = struct {
    locals: []Value,
    stack: std.ArrayList(Value),
    pub fn load(comptime T: ValType, val: anytype) !void {
        _ = T;
        _ = val;
    }
};

pub const WasmExecCtx = struct {
    prog: *const wasm.WasmFile,

    stack: std.ArrayList(Frame),
    store: std.ArrayList(Value),

    pub fn init(
        alloc: std.mem.Allocator,
        prog: *const wasm.WasmFile,
    ) WasmExecCtx {
        return .{
            .prog = prog,
            .stack = std.ArrayList(Frame).init(alloc),
            .store = std.ArrayList(Value).init(alloc),
        };
    }
    pub fn deinit(self: WasmExecCtx) void {
        self.stack.deinit();
        self.store.deinit();
    }
};

fn execIns(ins: wasmIns.Instruction, frame: *Frame, exec: *WasmExecCtx) !void {
    switch (ins) {
        .nop => {},
        .i32_load => |val| try frame.push(.i32, try exec.loadMem(i32, val)),
        .i64_load => |val| try frame.push(.i64, try exec.loadMem(i64, val)),
        .f32_load => |val| try frame.push(.f32, try exec.loadMem(f32, val)),
        .f64_load => |val| try frame.push(.f64, try exec.loadMem(f64, val)),
        .i32_load => |val| try frame.push(.i32, try exec.loadMem(u8, val)),
        // i32_load8_s: void,
        // i32_load8_u: void,
        // i32_load16_s: void,
        // i32_load16_u: void,
        // i64_load8_s: void,
        // i64_load8_u: void,
        // i64_load16_s: void,
        // i64_load16_u: void,
        // i64_load32_s: void,
        // i64_load32_u: void,
        // i32_store: void,
        // i64_store: void,
        // f32_store: void,
        // f64_store: void,
        // i32_store_8: void,
        // i32_store_16: void,
        // i64_store_8: void,
        // i64_store_16: void,
        // i64_store_32: void,

        .i32_const => |val| try frame.push(val),
        .i64_const => |val| try frame.push(val),
        .f32_const => |val| try frame.push(val),
        .f64_const => |val| try frame.push(val),
    }
}
