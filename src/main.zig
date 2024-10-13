const std = @import("std");
const wasm = @import("wasm");
const ExecCtx = @import("ExecCtx.zig").ExecCtx;
const Terminal = @import("Terminal.zig").Terminal;

pub const DispatchObject = union(enum) {};
const EventLoop = @import("EventLoop.zig").EventLoop(.{ .dispatchObject = DispatchObject });

pub fn main() !void {
    var out = std.io.getStdOut();
    var bufw = std.io.bufferedWriter(out.writer());
    defer _ = bufw.flush() catch {};
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const alloc = gpa.allocator();
    var file = try std.fs.cwd().openFile("src/stack.wasm", .{});
    defer file.close();

    var el = EventLoop.init(alloc);
    defer el.deinit();
    var term = try Terminal.init();
    defer term.deinit();
}
