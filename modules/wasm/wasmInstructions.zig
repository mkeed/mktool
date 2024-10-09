const std = @import("std");
const wasm = @import("wasm.zig");

pub const ExprBlock = struct {
    instructions: std.ArrayList(Instruction),
    pub fn init(alloc: std.mem.Allocator) ExprBlock {
        return ExprBlock{
            .instructions = std.ArrayList(Instruction).init(alloc),
        };
    }
    pub fn decode(alloc: std.mem.Allocator, reader: anytype) !ExprBlock {
        var self = ExprBlock.init(alloc);
        errdefer self.deinit();
        _ = try self.parse(alloc, reader);
        return self;
    }
    const ParseErrorSet = error{ WasmDecodeError, OutOfMemory };
    pub fn parse(self: *ExprBlock, alloc: std.mem.Allocator, reader: anytype) ParseErrorSet!InsCode {
        while (true) {
            const ins = wasm.wasmDecode(Instruction, alloc, reader) catch return error.WasmDecodeError;
            std.log.err("{}", .{ins});
            switch (ins) {
                .end_block => {
                    return .end_block;
                },
                .end_if => {
                    return .end_block;
                },
                else => {
                    try self.instructions.append(ins);
                },
            }
        }
    }

    pub fn deinit(self: ExprBlock) void {
        for (self.instructions.items) |i| {
            i.deinit();
        }
        self.instructions.deinit();
    }
    pub fn format(self: ExprBlock, _: []const u8, _: std.fmt.FormatOptions, writer: anytype) !void {
        for (self.instructions.items) |i| {
            try std.fmt.format(writer, "{}\n", .{i});
        }
    }
};

pub const IfBlock = struct {
    if_branch: ExprBlock,
    else_branch: ?ExprBlock,

    pub fn decode(alloc: std.mem.Allocator, reader: anytype) !IfBlock {
        const blockType = try reader.readInt(u8, .little);
        if (blockType != 0x40) return error.Unimplemented;
        var self = IfBlock{
            .if_branch = ExprBlock.init(alloc),
            .else_branch = null,
        };
        errdefer self.deinit();
        std.log.err("Start if", .{});
        const block = self.if_branch.parse(alloc, reader) catch return error.BlockParseFail;
        if (block == .end_if) {
            std.log.err("Start else", .{});
            var e = ExprBlock.init(alloc);
            errdefer e.deinit();
            const end = e.parse(alloc, reader) catch return error.BlockParseFail;
            if (end != .end_block) {
                return error.InvalidBlock;
            }
            self.else_branch = e;
        }
        std.log.err("end if", .{});
        return self;
    }
    pub fn deinit(self: IfBlock) void {
        self.if_branch.deinit();
        if (self.else_branch) |e| e.deinit();
    }
};

pub const InsCode = enum(u8) {
    @"unreachable" = 0x00,
    nop = 0x01, //
    block = 0x02,
    loop = 0x03,
    if_else = 0x04,

    end_if = 0x05,
    end_block = 0x0B,
    br = 0x0C,
    br_if = 0x0D,
    br_table = 0x0E,
    @"return" = 0x0F,

    call = 0x10,
    call_indirect = 0x11,

    drop = 0x1A,
    select = 0x1B,
    select_t = 0x1C,

    local_get = 0x20,
    local_set = 0x21,
    local_tee = 0x22,
    global_get = 0x23,
    global_set = 0x24,
    table_get = 0x25,
    table_set = 0x26,

    i32_load = 0x27,
    i64_load = 0x28,
    f32_load = 0x2A,
    f64_load = 0x2B,
    i32_load8_s = 0x2C,
    i32_load8_u = 0x2D,
    i32_load16_s = 0x2E,
    i32_load16_u = 0x2F,
    i64_load8_s = 0x30,
    i64_load8_u = 0x31,
    i64_load16_s = 0x32,
    i64_load16_u = 0x33,
    i64_load32_s = 0x34,
    i64_load32_u = 0x35,
    i32_store = 0x36,
    i64_store = 0x37,
    f32_store = 0x38,
    f64_store = 0x39,
    i32_store_8 = 0x3A,
    i32_store_16 = 0x3B,
    i64_store_8 = 0x3C,
    i64_store_16 = 0x3D,
    i64_store_32 = 0x3E,

    memory_size = 0x3F,
    memory_grow = 0x40,

    i32_const = 0x41,
    i64_const = 0x42,
    f32_const = 0x43,
    f64_const = 0x44,

    i32_eqz = 0x45,
    i32_eq = 0x46,
    i32_ne = 0x47,
    i32_lt_s = 0x48,
    i32_lt_u = 0x49,
    i32_gt_s = 0x4A,
    i32_gt_u = 0x4B,
    i32_le_s = 0x4C,
    i32_le_u = 0x4D,
    i32_ge_s = 0x4E,
    i32_ge_u = 0x4F,
    i64_eqz = 0x50,
    i64_eq = 0x51,
    i64_ne = 0x52,
    i64_lt_s = 0x53,
    i64_lt_u = 0x54,
    i64_gt_s = 0x55,
    i64_gt_u = 0x56,
    i64_le_s = 0x57,
    i64_le_u = 0x58,
    i64_ge_s = 0x59,
    i64_ge_u = 0x5A,
    f32_eq = 0x5b,
    f32_ne = 0x5c,
    f32_lt = 0x5d,
    f32_gt = 0x5e,
    f32_le = 0x5f,
    f32_ge = 0x60,
    f64_eq = 0x61,
    f64_ne = 0x62,
    f64_lt = 0x63,
    f64_gt = 0x64,
    f64_le = 0x65,
    f64_ge = 0x66,
    i32_clz = 0x67,
    i32_ctz = 0x68,
    i32_popcnt = 0x69,
    i32_add = 0x6a,
    i32_sub = 0x6b,
    i32_mul = 0x6c,
    i32_div_s = 0x6d,
    i32_div_u = 0x6e,
    i32_rem_s = 0x6f,
    i32_rem_u = 0x70,
    i32_and = 0x71,
    i32_or = 0x72,
    i32_xor = 0x73,
    i32_shl = 0x74,
    i32_shr_s = 0x75,
    i32_shr_u = 0x76,
    i32_rotl = 0x77,
    i32_rotr = 0x78,
    i64_clz = 0x79,
    i64_ctz = 0x7a,
    i64_popcnt = 0x7b,
    i64_add = 0x7c,
    i64_sub = 0x7d,
    i64_mul = 0x7e,
    i64_div_s = 0x7f,
    i64_div_u = 0x80,
    i64_rem_s = 0x81,
    i64_rem_u = 0x82,
    i64_and = 0x83,
    i64_or = 0x84,
    i64_xor = 0x85,
    i64_shl = 0x86,
    i64_shr_s = 0x87,
    i64_shr_u = 0x88,
    i64_rotl = 0x89,
    i64_rotr = 0x8a,
    f32_abs = 0x8b,
    f32_neg = 0x8c,
    f32_ceil = 0x8d,
    f32_floor = 0x8e,
    f32_trunc = 0x8f,
    f32_nearest = 0x90,
    f32_sqrt = 0x91,
    f32_add = 0x92,
    f32_sub = 0x93,
    f32_mul = 0x94,
    f32_div = 0x95,
    f32_min = 0x96,
    f32_max = 0x97,
    f32_copysign = 0x98,
    f64_abs = 0x99,
    f64_neg = 0x9a,
    f64_ceil = 0x9b,
    f64_floor = 0x9c,
    f64_trunc = 0x9d,
    f64_nearest = 0x9e,
    f64_sqrt = 0x9f,
    f64_add = 0xa0,
    f64_sub = 0xa1,
    f64_mul = 0xa2,
    f64_div = 0xa3,
    f64_min = 0xa4,
    f64_max = 0xa5,
    f64_copysign = 0xa6,
    i32_wrap_i64 = 0xa7,
    i32_trunc_f32_s = 0xa8,
    i32_trunc_f32_u = 0xa9,
    i32_trunc_f64_s = 0xaa,
    i32_trunc_f64_u = 0xab,
    i64_extend_i32_s = 0xac,
    i64_extend_i32_u = 0xad,
    i64_trunc_f32_s = 0xae,
    i64_trunc_f32_u = 0xaf,
    i64_trunc_f64_s = 0xb0,
    i64_trunc_f64_u = 0xb1,
    f32_convert_i32_s = 0xb2,
    f32_convert_i32_u = 0xb3,
    f32_convert_i64_s = 0xb4,
    f32_convert_i64_u = 0xb5,
    f32_demote_f64 = 0xb6,
    f64_convert_i32_s = 0xb7,
    f64_convert_i32_u = 0xb8,
    f64_convert_i64_s = 0xb9,
    f64_convert_i64_u = 0xba,
    f64_promote_f32 = 0xbb,
    i32_reinterpret_f32 = 0xbc,
    i64_reinterpret_f64 = 0xbd,
    f32_reinterpret_i32 = 0xbe,
    f64_reinterpret_i64 = 0xbf,
    i32_extend8_s = 0xc0,
    i32_extend16_s = 0xc1,
    i64_extend8_s = 0xc2,
    i64_extend16_s = 0xc3,
    i64_extend32_s = 0xc4,
    ref_null = 0xD0,
    ref_is_null = 0xD1,
    ref_func = 0xD2,

    complex_ins = 0xFC,
};

pub const Instruction = union(InsCode) {
    @"unreachable": void,
    nop: void,
    block: void,
    loop: void,
    if_else: IfBlock,
    end_if: void,
    end_block: void,
    br: void,
    br_if: void,
    br_table: void,
    @"return": void,

    call: wasm.funcidx,
    call_indirect: struct { y: wasm.typeidx, x: wasm.typeidx },

    drop: void,
    select: void,
    select_t: void,

    local_get: wasm.localidx,
    local_set: wasm.localidx,
    local_tee: wasm.localidx,
    global_get: wasm.globalidx,
    global_set: wasm.globalidx,
    table_get: wasm.tableidx,
    table_set: wasm.tableidx,

    i32_load: void,
    i64_load: void,
    f32_load: void,
    f64_load: void,
    i32_load8_s: void,
    i32_load8_u: void,
    i32_load16_s: void,
    i32_load16_u: void,
    i64_load8_s: void,
    i64_load8_u: void,
    i64_load16_s: void,
    i64_load16_u: void,
    i64_load32_s: void,
    i64_load32_u: void,
    i32_store: void,
    i64_store: void,
    f32_store: void,
    f64_store: void,
    i32_store_8: void,
    i32_store_16: void,
    i64_store_8: void,
    i64_store_16: void,
    i64_store_32: void,

    memory_size: void,
    memory_grow: void,

    i32_const: i32,
    i64_const: i64,
    f32_const: f32,
    f64_const: f64,

    i32_eqz: void,
    i32_eq: void,
    i32_ne: void,
    i32_lt_s: void,
    i32_lt_u: void,
    i32_gt_s: void,
    i32_gt_u: void,
    i32_le_s: void,
    i32_le_u: void,
    i32_ge_s: void,
    i32_ge_u: void,
    i64_eqz: void,
    i64_eq: void,
    i64_ne: void,
    i64_lt_s: void,
    i64_lt_u: void,
    i64_gt_s: void,
    i64_gt_u: void,
    i64_le_s: void,
    i64_le_u: void,
    i64_ge_s: void,
    i64_ge_u: void,
    f32_eq: void,
    f32_ne: void,
    f32_lt: void,
    f32_gt: void,
    f32_le: void,
    f32_ge: void,
    f64_eq: void,
    f64_ne: void,
    f64_lt: void,
    f64_gt: void,
    f64_le: void,
    f64_ge: void,
    i32_clz: void,
    i32_ctz: void,
    i32_popcnt: void,
    i32_add: void,
    i32_sub: void,
    i32_mul: void,
    i32_div_s: void,
    i32_div_u: void,
    i32_rem_s: void,
    i32_rem_u: void,
    i32_and: void,
    i32_or: void,
    i32_xor: void,
    i32_shl: void,
    i32_shr_s: void,
    i32_shr_u: void,
    i32_rotl: void,
    i32_rotr: void,
    i64_clz: void,
    i64_ctz: void,
    i64_popcnt: void,
    i64_add: void,
    i64_sub: void,
    i64_mul: void,
    i64_div_s: void,
    i64_div_u: void,
    i64_rem_s: void,
    i64_rem_u: void,
    i64_and: void,
    i64_or: void,
    i64_xor: void,
    i64_shl: void,
    i64_shr_s: void,
    i64_shr_u: void,
    i64_rotl: void,
    i64_rotr: void,
    f32_abs: void,
    f32_neg: void,
    f32_ceil: void,
    f32_floor: void,
    f32_trunc: void,
    f32_nearest: void,
    f32_sqrt: void,
    f32_add: void,
    f32_sub: void,
    f32_mul: void,
    f32_div: void,
    f32_min: void,
    f32_max: void,
    f32_copysign: void,
    f64_abs: void,
    f64_neg: void,
    f64_ceil: void,
    f64_floor: void,
    f64_trunc: void,
    f64_nearest: void,
    f64_sqrt: void,
    f64_add: void,
    f64_sub: void,
    f64_mul: void,
    f64_div: void,
    f64_min: void,
    f64_max: void,
    f64_copysign: void,
    i32_wrap_i64: void,
    i32_trunc_f32_s: void,
    i32_trunc_f32_u: void,
    i32_trunc_f64_s: void,
    i32_trunc_f64_u: void,
    i64_extend_i32_s: void,
    i64_extend_i32_u: void,
    i64_trunc_f32_s: void,
    i64_trunc_f32_u: void,
    i64_trunc_f64_s: void,
    i64_trunc_f64_u: void,
    f32_convert_i32_s: void,
    f32_convert_i32_u: void,
    f32_convert_i64_s: void,
    f32_convert_i64_u: void,
    f32_demote_f64: void,
    f64_convert_i32_s: void,
    f64_convert_i32_u: void,
    f64_convert_i64_s: void,
    f64_convert_i64_u: void,
    f64_promote_f32: void,
    i32_reinterpret_f32: void,
    i64_reinterpret_f64: void,
    f32_reinterpret_i32: void,
    f64_reinterpret_i64: void,
    i32_extend8_s: void,
    i32_extend16_s: void,
    i64_extend8_s: void,
    i64_extend16_s: void,
    i64_extend32_s: void,
    ref_null: void,
    ref_is_null: void,
    ref_func: void,

    complex_ins: void,

    pub fn deinit(self: Instruction) void {
        switch (self) {
            .if_else => |i| i.deinit(),
            else => {},
        }
        //
    }
};
