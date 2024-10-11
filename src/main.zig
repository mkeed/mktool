const std = @import("std");
const wasm = @import("wasm");
const ExecCtx = @import("ExecCtx.zig").ExecCtx;

pub fn main() !void {
    var out = std.io.getStdOut();
    var bufw = std.io.bufferedWriter(out.writer());
    defer _ = bufw.flush() catch {};
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const alloc = gpa.allocator();
    var file = try std.fs.cwd().openFile("src/add.wasm", .{});
    defer file.close();
    var bufr = std.io.bufferedReader(file.reader());

    var w = try wasm.WasmFile.parseFile(alloc, bufr.reader());
    defer w.deinit();
    try std.fmt.format(bufw.writer(), "{}", .{w});
}
