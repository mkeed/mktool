const std = @import("std");
const wasm = @import("wasm");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const alloc = gpa.allocator();
    var file = try std.fs.cwd().openFile("src/readfile.wasm", .{});
    defer file.close();
    var bufr = std.io.bufferedReader(file.reader());

    var w = try wasm.WasmFile.parseFile(alloc, bufr.reader());
    defer w.deinit();
}
