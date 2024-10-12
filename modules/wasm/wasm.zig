const std = @import("std");
const wasmFile = @import("wasmFile.zig");
pub const Exec = @import("wasmExec.zig");
pub const Wasm = struct {
    //pub const Code = struct {};
    //codes: []Code,
    pub fn init(alloc: std.mem.Allocator, reader: anytype) !Wasm {
        var file = try wasmFile.WasmFile.parseFile(alloc, reader);
        defer file.deinit();
        std.log.info("{}", .{file.code.?});
        return .{};
    }
    pub fn deinit(self: Wasm) void {
        _ = self;
    }
};
