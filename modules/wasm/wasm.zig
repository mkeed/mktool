const std = @import("std");

const Name = struct {}; //TODO
const RefType = enum(u8) { funcref = 0x70, externref = 0x6f };
const Limit = struct { min: u32, max: ?u32 = null };
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

pub const Expr = struct {}; //TODO

pub const CustomSection = struct {
    name: Name,
    data: std.ArrayList(u8),
};

pub const TypeSection = struct {
    pub const TypeIdx = u32;
    pub const FuncType = struct {
        args: std.ArrayList(WasmType),
        returns: std.ArrayList(WasmType),
    };
    funcTypes: std.ArrayList(FuncType),
};

pub const ImportSection = struct {
    pub const Import = struct {
        mode: Name,
        name: Name,
        desc: enum(u8) { type = 0, table = 1, mem = 2, global = 3 },
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
        e: expr,
    };
    global: std.ArrayList(Global),
};

pub const ExportSection = struct {
    //
};

pub const WasmFile = struct {
    custom: std.ArrayList(CustomSection),
    type: std.ArrayList(TypeSection),
};
