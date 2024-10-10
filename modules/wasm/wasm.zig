const std = @import("std");
const wasmInstruction = @import("wasmInstructions.zig");
const ExprBlock = wasmInstruction.ExprBlock;

const Name = struct {
    data: std.ArrayList(u8),
    pub fn decode(alloc: std.mem.Allocator, reader: anytype) !Name {
        const len = try std.leb.readUleb128(u32, reader);
        var data = std.ArrayList(u8).init(alloc);
        try data.resize(len);
        errdefer data.deinit();
        _ = try reader.read(data.items);

        return .{ .data = data };
    }
    pub fn deinit(self: Name) void {
        self.data.deinit();
    }
    pub fn format(self: Name, _: []const u8, _: std.fmt.FormatOptions, writer: anytype) !void {
        try std.fmt.format(writer, "{s}", .{self.data.items});
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
    pub fn format(self: ValType, _: []const u8, _: std.fmt.FormatOptions, writer: anytype) !void {
        const val: []const u8 = switch (self) {
            //numbers
            .i32 => "i32",
            .i64 => "i64",
            .f32 => "f32",
            .f64 => "f64",

            //vectors
            .v128 => "v128",

            //reftype
            .funcref => "funcref",
            .externref => "externref",
        };
        try std.fmt.format(writer, "{s}", .{val});
    }
};
pub const typeidx = i32;
pub const funcidx = i32;
pub const tableidx = i32;
pub const globalidx = i32;
pub const memidx = i32;
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

pub const CustomSection = struct {
    name: Name,
    data: std.ArrayList(u8),
    pub fn deinit(self: CustomSection) void {
        self.name.deinit();
        self.data.deinit();
    }
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
    pub fn format(self: TypeSection, _: []const u8, _: std.fmt.FormatOptions, writer: anytype) !void {
        for (self.funcTypes.items, 0..) |ft, idx| {
            try std.fmt.format(writer, "(type (;{};) (func ", .{idx});
            if (ft.args.items.len > 0) {
                try std.fmt.format(writer, "(param ", .{});
                for (ft.args.items) |a| {
                    try std.fmt.format(writer, "{} ", .{a});
                }
            }
            if (ft.returns.items.len > 0) {
                try std.fmt.format(writer, "(result ", .{});
                for (ft.returns.items) |a| {
                    try std.fmt.format(writer, "{} ", .{a});
                }
                try std.fmt.format(writer, ")", .{});
            }
            try std.fmt.format(writer, ")\n", .{});
        }
    }
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
    pub fn format(self: ImportSection, _: []const u8, _: std.fmt.FormatOptions, writer: anytype) !void {
        for (self.imports.items, 0..) |ft, idx| {
            _ = idx;
            try std.fmt.format(writer, "(import \"{s}\" \"{s}\" {})\n", .{ ft.mode, ft.name, ft.desc });
        }
    }
    imports: std.ArrayList(Import),
};

pub const FunctionSection = struct {
    pub fn init(alloc: std.mem.Allocator) FunctionSection {
        return FunctionSection{
            .funcs = std.ArrayList(TypeSection.TypeIdx).init(alloc),
        };
    }
    pub fn deinit(self: FunctionSection) void {
        self.funcs.deinit();
    }
    pub fn format(self: FunctionSection, _: []const u8, _: std.fmt.FormatOptions, writer: anytype) !void {
        for (self.funcs.items, 0..) |f, idx| {
            try std.fmt.format(writer, "[{}] => ({})\n", .{ idx, f });
        }
    }
    funcs: std.ArrayList(TypeSection.TypeIdx),
};

pub const TableSection = struct {
    pub const Table = struct {
        ref: RefType,
        limit: Limit,
    };
    tables: std.ArrayList(Table),
    pub fn deinit(self: TableSection) void {
        self.tables.deinit();
    }
};

pub const MemorySection = struct {
    pub const Memory = struct {
        limit: Limit,
    };
    mem: std.ArrayList(Memory),
    pub fn deinit(self: MemorySection) void {
        self.mem.deinit();
    }
};

pub const GlobalSection = struct {
    pub const Global = struct {
        globaltype: struct {
            t: ValType,
            m: enum(u8) { @"const" = 0, @"var" = 1 },
        },
        e: ExprBlock,
    };
    global: std.ArrayList(Global),
    pub fn init(alloc: std.mem.Allocator) GlobalSection {
        return .{ .global = std.ArrayList(Global).init(alloc) };
    }
    pub fn deinit(self: GlobalSection) void {
        for (self.global.items) |g| g.e.deinit();
        self.global.deinit();
    }
};

pub const ExportSection = struct {
    pub const ExportDescId = enum(u8) { func = 0x00, table = 0x01, mem = 0x02, global = 0x03 };
    pub const ExportDesc = union(ExportDescId) {
        func: funcidx,
        table: tableidx,
        mem: memidx,
        global: globalidx,
    };
    pub const Export = struct {
        nm: Name,
        d: ExportDesc,
        pub fn deinit(self: Export) void {
            self.nm.deinit();
        }
    };
    pub fn init(alloc: std.mem.Allocator) ExportSection {
        return .{
            .@"export" = std.ArrayList(Export).init(alloc),
        };
    }
    pub fn deinit(self: ExportSection) void {
        for (self.@"export".items) |i| i.deinit();
        self.@"export".deinit();
    }
    pub fn format(self: ExportSection, _: []const u8, _: std.fmt.FormatOptions, writer: anytype) !void {
        for (self.@"export".items, 0..) |e, idx| {
            try std.fmt.format(writer, "[{}] => ({},{})\n", .{ idx, e.nm, e.d });
        }
    }
    @"export": std.ArrayList(Export),
};

pub const StartSection = struct {
    start: funcidx,
};

pub const CodeSection = struct {
    pub fn init(alloc: std.mem.Allocator) CodeSection {
        return .{
            .code = std.ArrayList(Code).init(alloc),
        };
    }
    pub fn deinit(self: CodeSection) void {
        for (self.code.items) |i| i.deinit();
        self.code.deinit();
    }

    pub const Code = struct {
        size: u32,
        locals: std.ArrayList(Local),
        expr: ExprBlock,
        pub const Local = struct {
            num: u32,
            t: ValType,
        };
        pub fn decode(alloc: std.mem.Allocator, reader: anytype) !Code {
            const len = try std.leb.readUleb128(u32, reader);
            var al = std.ArrayList(u8).init(alloc);
            defer al.deinit();
            try al.resize(len);
            _ = try reader.read(al.items);
            var fbs = std.io.fixedBufferStream(al.items);

            var self = Code{
                .size = len,
                .locals = std.ArrayList(Local).init(alloc),
                .expr = ExprBlock.init(alloc),
            };
            errdefer self.deinit();
            try parseVector(Local, &self.locals, alloc, fbs.reader());

            _ = try self.expr.parse(alloc, fbs.reader());
            return self;
        }
        pub fn deinit(self: Code) void {
            self.locals.deinit();
            self.expr.deinit();
        }
    };
    pub fn format(self: CodeSection, _: []const u8, _: std.fmt.FormatOptions, writer: anytype) !void {
        for (self.code.items, 0..) |i, idx| {
            try std.fmt.format(writer, "[{}] {}", .{ idx, i });
        }
    }
    code: std.ArrayList(Code),
};

pub const WasmFile = struct {
    custom: std.ArrayList(CustomSection),
    type: std.ArrayList(TypeSection),
    import: std.ArrayList(ImportSection),
    function: std.ArrayList(FunctionSection),
    table: std.ArrayList(TableSection),
    memory: std.ArrayList(MemorySection),
    global: std.ArrayList(GlobalSection),
    @"export": std.ArrayList(ExportSection),
    start: std.ArrayList(StartSection),
    //element = 9,
    code: std.ArrayList(CodeSection),
    //data = 11,
    //@"data count" = 12,
    pub fn init(alloc: std.mem.Allocator) WasmFile {
        return .{
            .custom = std.ArrayList(CustomSection).init(alloc),
            .type = std.ArrayList(TypeSection).init(alloc),
            .import = std.ArrayList(ImportSection).init(alloc),
            .function = std.ArrayList(FunctionSection).init(alloc),
            .table = std.ArrayList(TableSection).init(alloc),
            .memory = std.ArrayList(MemorySection).init(alloc),
            .global = std.ArrayList(GlobalSection).init(alloc),
            .@"export" = std.ArrayList(ExportSection).init(alloc),
            .start = std.ArrayList(StartSection).init(alloc),
            .code = std.ArrayList(CodeSection).init(alloc),
        };
    }
    pub fn deinit(self: WasmFile) void {
        for (self.custom.items) |i| i.deinit();
        self.custom.deinit();
        for (self.type.items) |i| i.deinit();
        self.type.deinit();
        for (self.import.items) |i| i.deinit();
        self.import.deinit();
        for (self.function.items) |i| i.deinit();
        self.function.deinit();
        for (self.table.items) |i| i.deinit();
        self.table.deinit();
        for (self.memory.items) |i| i.deinit();
        self.memory.deinit();
        for (self.global.items) |i| i.deinit();
        self.global.deinit();
        for (self.@"export".items) |i| i.deinit();
        self.@"export".deinit();
        self.start.deinit();
        for (self.code.items) |i| i.deinit();
        self.code.deinit();
    }

    pub fn parseFile(alloc: std.mem.Allocator, reader: anytype) !WasmFile {
        var self = WasmFile.init(alloc);
        errdefer self.deinit();
        const magic = try reader.readInt(u32, .little);
        const version = try reader.readInt(u32, .little);
        if (magic != 0x6d736100) return error.BadMagic;
        if (version != 0x1) return error.Version;
        var tmp_buffer = std.ArrayList(u8).init(alloc);
        defer tmp_buffer.deinit();
        while (true) {
            defer tmp_buffer.clearRetainingCapacity();
            const id = try std.meta.intToEnum(SectionId, reader.readInt(u8, .little) catch break);
            const len = try std.leb.readUleb128(u32, reader);
            try tmp_buffer.resize(len);
            if (len != try reader.read(tmp_buffer.items)) return error.BadRead;
            var subfbs = std.io.fixedBufferStream(tmp_buffer.items);
            std.log.info("section {}[{}]", .{ id, tmp_buffer.items.len });
            switch (id) {
                .custom => try self.custom.append(try wasmDecode(CustomSection, alloc, subfbs.reader())),
                .type => try self.type.append(try wasmDecode(TypeSection, alloc, subfbs.reader())),
                .import => try self.import.append(try wasmDecode(ImportSection, alloc, subfbs.reader())),
                .function => try self.function.append(try wasmDecode(FunctionSection, alloc, subfbs.reader())),
                .@"export" => try self.@"export".append(try wasmDecode(ExportSection, alloc, subfbs.reader())),
                .code => try self.code.append(try wasmDecode(CodeSection, alloc, subfbs.reader())),
                .global => try self.global.append(try wasmDecode(GlobalSection, alloc, subfbs.reader())),
                else => {
                    std.log.err("unhandled {}[{}]", .{ id, std.fmt.fmtSliceHexUpper(tmp_buffer.items) });
                },
            }
        }
        return self;
    }
};

pub const wasm = struct {}; // this will be the final output

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
    std.log.err("parseVect:{}|{}", .{ T, len });
    try val.ensureTotalCapacity(len);
    for (0..len) |_| {
        val.append(try wasmDecode(T, alloc, reader)) catch unreachable;
    }
}

inline fn isVector(comptime T: type) bool {
    const tInfo = @typeInfo(T);
    switch (tInfo) {
        .@"struct" => {
            if (@hasField(T, "items")) return true;
        },
        else => {},
    }
    return false;
}

pub fn wasmDecode(comptime T: type, alloc: std.mem.Allocator, reader: anytype) !T {
    const tInfo = @typeInfo(T);
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
                if (isVector(f.type)) { //"items" is just a proxy for being an arraylist find something better?
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
                .signed => {
                    const val = try std.leb.readIleb128(T, reader);
                    return val;
                },
                .unsigned => {
                    const val = try std.leb.readUleb128(T, reader);
                    return val;
                },
            }
        },
        .@"enum" => |e| {
            if (e.tag_type != u8) {
                @compileLog(T);
                @compileError("Expected u8 tag type");
            }
            const byte = try reader.readInt(u8, .little);
            return try std.meta.intToEnum(T, byte);
        },
        .@"union" => |u| {
            if (u.tag_type) |t| {
                const byte = try reader.readInt(u8, .little);
                const value = try std.meta.intToEnum(t, byte);
                inline for (u.fields) |uf| {
                    if (std.meta.stringToEnum(t, uf.name) orelse unreachable == value) {
                        const val = @unionInit(T, uf.name, try wasmDecode(uf.type, alloc, reader));
                        return val;
                    }
                }
            } else {
                @compileLog(T);
                @compileError("Expected tag type");
            }
        },
        .float => {
            var bytes = std.mem.zeroes([@sizeOf(T)]u8);
            _ = try reader.read(bytes[0..]);
            return std.mem.bytesAsValue(T, bytes[0..]).*;
        },
        .void => {
            return {};
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
    {}
}
