const std = @import("std");

const ESC = "\x1B";
const CSI = ESC ++ "[";

pub fn moveCursorAbs(writer: anytype, pos: struct { x: i32, y: i32 }) !void {
    try std.fmt.format(writer, CSI ++ "{};{}H", .{ pos.y, pos.x });
}

pub fn erase(writer: anytype, amount: enum { toBeginning, toEnd, whole }, pos: enum { line, screen }) !void {
    const mod = switch (pos) {
        .line => 'K',
        .screen => 'J',
    };
    const amt = switch (amount) {
        .toEnd => '0',
        .toBegining => '1',
        .whole => '2',
    };
    try std.fmt.format(writer, CSI ++ "{}{}", .{ amt, mod });
}

pub fn cursorVisibility(writer: anytype, visibility: enum { invisible, visible }) !void {
    switch (visibility) {
        .visible => try std.fmt.format(writer, CSI ++ "?25h", .{}),
        .invisible => try std.fmt.format(writer, CSI ++ "?25l", .{}),
    }
}

pub fn altBuffer(writer: anytype, cmd: enum { enable, disable }) !void {
    switch (cmd) {
        .enable => try std.fmt.format(writer, CSI ++ "?1049h", .{}),
        .disable => try std.fmt.format(writer, CSI ++ "?1049l", .{}),
    }
}

pub const Colour = union(enum) {
    rgb: struct { r: u8, g: u8, b: u8 },
    col_256: u8,
    col_16: enum(u8) {
        Black = 0,
        Red = 1,
        Green = 2,
        Yellow = 3,
        Blue = 4,
        Magenta = 5,
        Cyan = 6,
        White = 7,
        Default = 9,
    },
    //todo 256/ 16 colour screens
};

pub const Font = struct {
    bold: bool = false,
    dim: bool = false,
    italic: bool = false,
    underline: bool = false,
    strike: bool = false,

    foreGround: ?Colour = null,
    backGround: ?Colour = null,

    pub fn set(self: Font, writer: anytype) !void {
        if (self.bold) try std.fmt.format(writer, CSI ++ "1m", .{});
        if (self.dim) try std.fmt.format(writer, CSI ++ "2m", .{});
        if (self.italic) try std.fmt.format(writer, CSI ++ "3m", .{});
        if (self.underline) try std.fmt.format(writer, CSI ++ "4m", .{});
        if (self.strike) try std.fmt.format(writer, CSI ++ "9m", .{});
        if (self.foreGround) |fg| {
            switch (fg) {
                .rgb => |r| try std.fmt.format(writer, CSI ++ "38;2;{};{};{}m", .{ r.r, r.g, r.b }),
                .col_256 => |c| try std.fmt.format(writer, CSI ++ "38;5;{}m", .{c}),
                .col_16 => |c| try std.fmt.format(writer, CSI ++ "{}m", .{@intFromEnum(c) + 30}),
            }
        }
    }
};
