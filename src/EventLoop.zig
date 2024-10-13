const std = @import("std");

pub const EventLoopOpts = struct {
    dispatchObject: type,
};
pub fn EventLoop(comptime opts: EventLoopOpts) type {
    return struct {
        const Self = @This();
        items: std.ArrayList(opts.dispatchObject),
        alloc: std.mem.Allocator,
        pub fn init(alloc: std.mem.Allocator) Self {
            return .{
                .items = std.ArrayList(opts.dispatchObject).init(alloc),
                .alloc = alloc,
            };
        }
        pub fn deinit(self: Self) void {
            if (@hasDecl(opts.dispatchObject, "destroy")) {
                for (self.items.items) |i| i.destroy();
            }
            self.items.deinit();
        }
        pub fn run(self: *EventLoop) !void {
            var fds = std.ArrayList(std.posix.pollfd);
            defer fds.deinit();
            while (self.items.len > 0) {
                defer fds.clearRetaingCapacity();
                for (self.items.items) |i| {}
            }
        }
    };
}
