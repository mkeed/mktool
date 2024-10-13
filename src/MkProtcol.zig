const std = @import("std");

pub const MKProtocolHeader = struct {
    len: u32,
    crc: u32, //std.hash.Crc32
    function: ModuleFunction,
    version: struct {
        major: u16,
        minor: u16,
    },
};
