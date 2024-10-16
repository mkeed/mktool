const std = @import("std");

const ArgIter = struct {
    alloc: std.me.Allocator,
    args: [][:0]u8,
    idx: usize,
    pub fn initProc(alloc: std.mem.Allocator) !ArgIter {
        return .{
            .alloc = alloc,
            .args = try std.process.argsAlloc(alloc),
            .idx = 0,
        };
    }
    pub fn deinit(self: ArgIter) void {
        std.process.argsFree(self.alloc, self.args);
    }
};

pub fn parseArgs(comptime T: type, alloc: std.mem.Allocator) !T {
    var result = if (@hasDecl(T, "init")) T.init(alloc) else .{};
    errdefer {
        if (@hasDecl(T, "deinit")) result.deinit();
    }
    const tInfo = @typeInfo(T).@"struct";
    var iter = try ArgIter.init(alloc);
    defer iter.deinit();
    //for(tInfo.fields

    return result;
}
