const std = @import("std");

const PrintBuf = std.BoundedArray(u8, 64);
const BaseInfo = struct {
    base: u8,
    name: []const u8,
};
const Base = [_]BaseInfo{
    .{ .base = 8, .name = "octal" },
    .{ .base = 16, .name = "hex" },
    .{ .base = 10, .name = "decimal" },
};
pub const PrintedInfo = struct {
    hex: PrintBuf = .{},
    oct: PrintBuf = .{},
    dec: PrintBuf = .{},
    leb: PrintBuf = .{},
    bin: PrintBuf = .{},
    pub fn format(self: PrintedInfo, _: []const u8, _: std.fmt.FormatOptions, writer: anytype) !void {
        try std.fmt.format(writer, "\n{s:>32}\n", .{self.hex.slice()});
        try std.fmt.format(writer, "{s:>32}\n", .{self.oct.slice()});
        try std.fmt.format(writer, "{s:>32}\n", .{self.dec.slice()});
        try std.fmt.format(writer, "{s:>32}\n", .{self.leb.slice()});
        try std.fmt.format(writer, "{s:>32}\n", .{self.bin.slice()});
    }
};

pub fn int_print(
    comptime T: type,
    val: T,
) !PrintedInfo {
    var ret = PrintedInfo{};
    const Tinfo = @typeInfo(T).int;

    try std.fmt.formatInt(val, 16, .upper, .{
        .width = @bitSizeOf(T) / 8,
        .alignment = .right,
        .fill = '0',
    }, ret.hex.writer());
    try std.fmt.formatInt(val, 8, .upper, .{
        .width = @bitSizeOf(T) / 4,
        .alignment = .right,
        .fill = '0',
    }, ret.oct.writer());
    try std.fmt.formatInt(val, 10, .upper, .{
        .width = @bitSizeOf(T),
        .alignment = .right,
        .fill = '0',
    }, ret.dec.writer());
    try std.fmt.formatInt(val, 2, .upper, .{
        .width = @bitSizeOf(T),
        .alignment = .right,
        .fill = '0',
    }, ret.bin.writer());

    {
        var leb_buffer = std.mem.zeroes([16]u8);
        var fbs = std.io.fixedBufferStream(leb_buffer[0..]);
        switch (Tinfo.signedness) {
            .unsigned => try std.leb.writeUleb128(fbs.writer(), val),
            .signed => try std.leb.writeIleb128(fbs.writer(), val),
        }
        try std.fmt.format(ret.leb.writer(), "{}", .{std.fmt.fmtSliceHexUpper(leb_buffer[0..fbs.pos])});
    }
    return ret;
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const alloc = gpa.allocator();
    var list = std.ArrayList(PrintedInfo).init(alloc);
    defer list.deinit();
    //    const input = "1234";
    var stdout = std.io.getStdOut();
    var bufw = std.io.bufferedWriter(stdout.writer());
    defer _ = bufw.flush() catch {};

    const writer = bufw.writer();
    const result = try int_print(u32, 1234);
    try std.fmt.format(writer, "input:{}\n", .{result});
}
const expected_output =
    \\ Input: "1234"
    \\ ├── Hex
    \\ │   ├── 0x04D2
    \\ ├── Oct
    \\ │   ├── 0o2322
    \\ ├── Dec
    \\ │   ├── 1234
    \\ ├── Leb124_signed
    \\ │   ├── 0o2322
    \\ ├── Leb124_unsigned
    \\ │   ├── 0o2322
;
