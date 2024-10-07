const std = @import("std");

const Name = struct {
    data: std.ArrayList(u8),
    pub fn decode(alloc: std.mem.Allocator, reader: anytype) !Name {
        const len = try std.leb.readUleb128(u32, reader);
        var data = std.ArrayList(u8).init(alloc);
        try data.resize(len);
        errdefer data.deinit();
        _ = try reader.read(data.items);
        std.log.err("name:[{}]{s}", .{ len, std.fmt.fmtSliceEscapeUpper(data.items) });
        return .{ .data = data };
    }
    pub fn deinit(self: Name) void {
        self.data.deinit();
    }
};
const RefType = enum(u8) { funcref = 0x70, externref = 0x6f };
const Limit = struct {
    min: u32,
    max: ?u32 = null,
    pub fn decode(alloc: std.mem.Allocator, reader: anytype) !Limit {
        _ = alloc;
        const val = try reader.readInt(u8, .little);
        switch (val) {
            0 => return .{
                .min = try std.leb.readUleb128(u32, reader),
                .max = null,
            },
            1 => return .{
                .min = try std.leb.readUleb128(u32, reader),
                .max = try std.leb.readUleb128(u32, reader),
            },
            else => return error.InvalidData,
        }
    }
};
pub const ValType = enum(u8) {
    //numbers
    i32 = 0x7F,
    i64 = 0x7E,
    f32 = 0x7D,
    f64 = 0x7C,

    //vectors
    v128 = 0x7B,

    //reftype
    funcref = 0x70,
    externref = 0x6F,
};
pub const typeidx = i32;
pub const funcidx = i32;
pub const tableidx = i32;
pub const globalidx = i32;
pub const elemidx = i32;
pub const dataidx = i32;
pub const localidx = i32;
pub const labelidx = i32;
pub const memtype = Limit;
pub const tabletype = struct { et: RefType, lim: Limit };
pub const globaltype = struct {
    t: ValType,
    m: enum(u8) { @"const" = 0, @"var" = 1 },
};
pub const Expr = struct {}; //TODO

pub const CustomSection = struct {
    name: Name,
    data: std.ArrayList(u8),
};

pub const TypeSection = struct {
    pub fn init(alloc: std.mem.Allocator) TypeSection {
        return .{
            .funcTypes = std.ArrayList(FuncType).init(alloc),
        };
    }
    pub fn deinit(self: TypeSection) void {
        for (self.funcTypes.items) |i| i.deinit();
        self.funcTypes.deinit();
    }
    pub const TypeIdx = u32;
    pub const FuncType = struct {
        pub fn decode(alloc: std.mem.Allocator, reader: anytype) !FuncType {
            var self = FuncType{
                .args = std.ArrayList(ValType).init(alloc),
                .returns = std.ArrayList(ValType).init(alloc),
            };
            errdefer self.deinit();
            const magic = try reader.readInt(u8, .little);
            if (magic != 0x60) return error.InvalidMagicNumber;
            try parseVector(ValType, &self.args, alloc, reader);
            try parseVector(ValType, &self.returns, alloc, reader);
            return self;
        }
        pub fn deinit(self: FuncType) void {
            self.args.deinit();
            self.returns.deinit();
        }
        args: std.ArrayList(ValType),
        returns: std.ArrayList(ValType),
    };
    funcTypes: std.ArrayList(FuncType),
};

pub const ImportSection = struct {
    pub fn init(alloc: std.mem.Allocator) ImportSection {
        return .{
            .imports = std.ArrayList(Import).init(alloc),
        };
    }
    pub fn deinit(self: ImportSection) void {
        for (self.imports.items) |i| i.deinit();
        self.imports.deinit();
    }
    pub const Import = struct {
        pub fn decode(alloc: std.mem.Allocator, reader: anytype) !Import {
            const mode = try Name.decode(alloc, reader);
            errdefer mode.deinit();
            const name = try Name.decode(alloc, reader);
            errdefer name.deinit();
            return .{
                .mode = mode,
                .name = name,
                .desc = try wasmDecode(Desc, alloc, reader),
            };
        }
        pub fn deinit(self: Import) void {
            self.mode.deinit();
            self.name.deinit();
        }
        pub const DescType = enum(u8) { type = 0, table = 1, mem = 2, global = 3 };
        pub const Desc = union(DescType) {
            type: typeidx,
            table: tabletype,
            mem: memtype,
            global: globaltype,
        };
        mode: Name,
        name: Name,
        desc: Desc,
    };
    imports: std.ArrayList(Import),
};

pub const FunctionSection = struct {
    funcs: std.ArrayList(TypeSection.TypeIdx),
};

pub const TableSection = struct {
    pub const Table = struct {
        ref: RefType,
        limit: Limit,
    };
    tables: std.ArrayList(Table),
};

pub const MemorySection = struct {
    pub const Memory = struct {
        limit: Limit,
    };
    mem: std.ArrayList(Memory),
};

pub const GlobalSection = struct {
    pub const Global = struct {
        globaltype: struct {
            t: ValType,
            m: enum(u8) { @"const" = 0, @"var" = 1 },
        },
        e: Expr,
    };
    global: std.ArrayList(Global),
};

pub const ExportSection = struct {
    pub const ExportDescId = enum(u8) { func = 0x00, table = 0x01, mem = 0x02, global = 0x03 };
    pub const ExportDesc = union(ExportDescId) {
        func: funcidx,
        table: tabletype,
        mem: memtype,
        global: globaltype,
    };
    pub const Export = struct {
        nm: Name,
        d: ExportDesc,
    };
    @"export": std.ArrayList(Export),
};

pub const StartSection = struct {
    start: funcidx,
};

pub const WasmFile = struct {
    custom: std.ArrayList(CustomSection),
    type: std.ArrayList(TypeSection),
};

pub const SectionId = enum(u8) {
    custom = 0,
    type = 1,
    import = 2,
    function = 3,
    table = 4,
    memory = 5,
    global = 6,
    @"export" = 7,
    start = 8,
    element = 9,
    code = 10,
    data = 11,
    @"data count" = 12,
};

fn parseVector(comptime T: type, val: *std.ArrayList(T), alloc: std.mem.Allocator, reader: anytype) !void {
    const len = try std.leb.readUleb128(u32, reader);
    try val.ensureTotalCapacity(len);
    std.log.err("vec:[{}]{}", .{ T, len });
    for (0..len) |_| {
        val.append(try wasmDecode(T, alloc, reader)) catch unreachable;
    }
}

fn wasmDecode(comptime T: type, alloc: std.mem.Allocator, reader: anytype) !T {
    const tInfo = @typeInfo(T);
    std.log.err("decoding {}", .{T});
    switch (tInfo) {
        .@"struct" => |s| {
            if (@hasDecl(T, "decode")) {
                return try T.decode(alloc, reader);
            }

            var ret: T = if (@hasDecl(T, "init")) T.init(alloc) else undefined;
            errdefer if (@hasDecl(T, "deinit")) {
                ret.deinit();
            };
            inline for (s.fields) |f| {
                if (@hasField(f.type, "items")) { //"items" is just a proxy for being an arraylist find something better?
                    const fieldType = @typeInfo(@field(f.type, "Slice")).pointer.child;
                    try parseVector(fieldType, &@field(ret, f.name), alloc, reader);
                    // is vector
                } else {
                    @field(ret, f.name) = try wasmDecode(f.type, alloc, reader);
                }
            }
            return ret;
        },
        .int => |i| {
            switch (i.signedness) {
                .signed => return try std.leb.readIleb128(T, reader),
                .unsigned => return try std.leb.readUleb128(T, reader),
            }
        },
        .@"enum" => |e| {
            if (e.tag_type != u8) {
                @compileLog(T);
                @compileError("Expected u8 tag type");
            }
            const byte = try reader.readInt(u8, .little);
            errdefer std.log.err("Attempt decode of {}", .{byte});
            return try std.meta.intToEnum(T, byte);
        },
        .@"union" => |u| {
            if (u.tag_type) |t| {
                const byte = try reader.readInt(u8, .little);
                errdefer std.log.err("Attempt decode of {}", .{byte});
                const value = try std.meta.intToEnum(t, byte);
                inline for (u.fields) |uf| {
                    if (std.meta.stringToEnum(t, uf.name) orelse unreachable == value) {
                        return @unionInit(T, uf.name, try wasmDecode(uf.type, alloc, reader));
                    }
                }
            } else {
                @compileLog(T);
                @compileError("Expected tag type");
            }
        },
        else => {
            @compileLog(T);
            @compileError("invalid type");
            //std.log.err("{}", .{e});
        },
    }
    return error.TODO;
}

test {
    const bin = @embedFile("loops.wasm");
    var fbs = std.io.fixedBufferStream(bin[0..]);
    errdefer std.log.err("read:{x}", .{fbs.getPos() catch unreachable});
    const reader = fbs.reader();
    const magic = try reader.readInt(u32, .little);
    const version = try reader.readInt(u32, .little);
    std.log.err("{x}|{}", .{ magic, version });
    const alloc = std.testing.allocator;
    var al = std.ArrayList(u8).init(alloc);
    defer al.deinit();
    while (true) {
        std.log.err("read_i:{x}", .{fbs.getPos() catch unreachable});
        defer al.clearRetainingCapacity();
        const id = try std.meta.intToEnum(SectionId, reader.readInt(u8, .little) catch break);
        const len = try std.leb.readUleb128(u32, reader);
        try al.resize(len);
        _ = try reader.read(al.items);
        var subfbs = std.io.fixedBufferStream(al.items);
        std.log.err("{}:{x}", .{ id, len });
        switch (id) {
            .type => {
                const val = try wasmDecode(TypeSection, alloc, subfbs.reader());
                defer val.deinit();
            },
            .import => {
                const val = try wasmDecode(ImportSection, alloc, subfbs.reader());
                defer val.deinit();
            },
            else => {},
        }
    }
}
