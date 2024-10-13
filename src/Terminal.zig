const std = @import("std");
const t_cmd = @import("terminal");

pub const Terminal = struct {
    old_termios: std.posix.termios,
    stdout: std.fs.File,
    stdin: std.fs.File,
    pub fn init() !Terminal {
        const stdout = std.io.getStdOut();
        const stdin = std.io.getStdIn();
        const old_attr = try std.posix.tcgetattr(stdin.handle);

        var new_attr = old_attr;
        new_attr.iflag.BRKINT = false;
        new_attr.iflag.ICRNL = false;
        new_attr.iflag.INPCK = false;
        new_attr.iflag.ISTRIP = false;
        new_attr.iflag.IXON = false;

        new_attr.oflag.OPOST = false;
        new_attr.cflag.CSIZE = .CS8;

        new_attr.lflag.ECHO = false;
        new_attr.lflag.ICANON = false;
        new_attr.lflag.IEXTEN = false;
        new_attr.lflag.ISIG = false;

        try std.posix.tcsetattr(stdin.handle, .FLUSH, new_attr);

        try t_cmd.altBuffer(stdout.writer(), .enable);
        var Font = t_cmd.Font{
            .bold = true,
            .underline = true,
        };
        try Font.set(stdout.writer());
        try std.fmt.format(stdout.writer(), "Test123", .{});

        Font.strike = true;
        try Font.set(stdout.writer());
        try std.fmt.format(stdout.writer(), "Test123", .{});
        std.time.sleep(1000_000_000);

        return .{
            .old_termios = old_attr,
            .stdout = stdout,
            .stdin = stdin,
        };
    }
    pub fn deinit(self: Terminal) void {
        std.posix.tcsetattr(self.stdin.handle, .FLUSH, self.old_termios) catch {};
        t_cmd.altBuffer(self.stdout.writer(), .disable) catch {};
    }
};
