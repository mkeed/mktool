const std = @import("std");

const PrintBuf = std.BoundedArray(u8, 64);

pub const PrintedInfo = struct {
    data_type: PrintBuf = .{},
    def: PrintBuf = .{},
    output: PrintBuf = .{},
    pub fn format(self: PrintedInfo, _: []const u8, _: std.fmt.FormatOptions, writer: anytype) !void {
        try std.fmt.format(writer, "{s}\n{s}\t{s}\n", .{
            self.data_type.slice(),
            self.def.slice(),
            self.output.slice(),
        });
    }
};

pub fn int_print(
    comptime T: type,
    val: T,
    list: *std.ArrayList(PrintedInfo),
) !void {
    const BaseInfo = struct {
        base: u8,
        name: []const u8,
    };
    const Base = [_]BaseInfo{
        .{ .base = 8, .name = "octal" },
        .{ .base = 16, .name = "hex" },
        .{ .base = 10, .name = "decimal" },
    };

    const Tinfo = @typeInfo(T).int;
    for (Base) |b| {
        var res = PrintedInfo{};
        try std.fmt.formatInt(val, b.base, .lower, .{}, res.output.writer());
        try std.fmt.format(res.def.writer(), "{s}", .{b.name});
        try std.fmt.format(res.data_type.writer(), "{}", .{T});
        try list.append(res);
    }
    {
        var leb_buffer = std.mem.zeroes([16]u8);
        var fbs = std.io.fixedBufferStream(leb_buffer[0..]);
        switch (Tinfo.signedness) {
            .unsigned => try std.leb.writeUleb128(fbs.writer(), val),
            .signed => try std.leb.writeIleb128(fbs.writer(), val),
        }
        var res = PrintedInfo{};
        try std.fmt.format(res.output.writer(), "{}", .{std.fmt.fmtSliceHexUpper(leb_buffer[0..fbs.pos])});
        try std.fmt.format(res.def.writer(), "LEB128", .{});
        try std.fmt.format(res.data_type.writer(), "{}", .{T});
    }
}

const types = [_]type{ u8, u16, u32, u64, i8, i16, i32, i64 };

pub fn print_info(
    data: []const u8,
    list: *std.ArrayList(PrintedInfo),
) !void {
    inline for (types[0..]) |T| {
        const val: ?T = std.fmt.parseInt(T, data, 0) catch null;
        if (val) |v| {
            try int_print(T, v, list);
        }
    }
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const alloc = gpa.allocator();
    var list = std.ArrayList(PrintedInfo).init(alloc);
    defer list.deinit();
    const input = "1234";
    var stdout = std.io.getStdOut();
    var bufw = std.io.bufferedWriter(stdout.writer());
    defer _ = bufw.flush() catch {};

    const writer = bufw.writer();
    try print_info(input, &list);
    try std.fmt.format(writer, "input:{s}\n", .{input});
    for (list.items) |l| {
        try std.fmt.format(writer, "{}", .{l});
    }
}
