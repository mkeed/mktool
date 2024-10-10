starting test:1728554631511
(type (;0;) (func (param i32 i32 i32 i32 (result i32 ))
(type (;1;) (func (param i32 i32 (result i32 ))
(type (;2;) (func (param i32 i32 i32 (result i32 ))
(type (;3;) (func (param i32 i32 i32 i32 i32 i64 i64 i32 i32 (result i32 ))
(type (;4;) (func (param i32 )
(type (;5;) (func )
(type (;6;) (func (param i32 i32 )
(import "wasi_snapshot_preview1" "fd_read" wasm.ImportSection.Import.Desc{ .type = 0 })
(import "wasi_snapshot_preview1" "fd_write" wasm.ImportSection.Import.Desc{ .type = 0 })
(import "wasi_snapshot_preview1" "fd_prestat_get" wasm.ImportSection.Import.Desc{ .type = 1 })
(import "wasi_snapshot_preview1" "fd_prestat_dir_name" wasm.ImportSection.Import.Desc{ .type = 2 })
(import "wasi_snapshot_preview1" "path_open" wasm.ImportSection.Import.Desc{ .type = 3 })
(import "wasi_snapshot_preview1" "proc_exit" wasm.ImportSection.Import.Desc{ .type = 4 })
[0] wasm.CodeSection.Code{ .size = 200, .locals = array_list.ArrayListAligned(wasm.CodeSection.Code.Local,null){ .items = { wasm.CodeSection.Code.Local{ ... } }, .capacity = 8, .allocator = mem.Allocator{ .ptr = anyopaque@119f628, .vtable = mem.Allocator.VTable{ ... } } }, .expr = wasmInstructions.Instruction{ .i32_const = 3 }
wasmInstructions.Instruction{ .global_get = 3 }
wasmInstructions.Instruction{ .call = 2 }
wasmInstructions.Instruction{ .local_set = 0 }
wasmInstructions.Instruction{ .local_get = 0 }
wasmInstructions.Instruction{ .i32_const = 0 }
wasmInstructions.Instruction{ .i32_ne = void }
wasmInstructions.Instruction{ .if_else = wasmInstructions.IfBlock{ .if_branch = wasmInstructions.Instruction{ .local_get = 0 }
wasmInstructions.Instruction{ .call = 9 }
wasmInstructions.Instruction{ .i32_const = 6900 }
wasmInstructions.Instruction{ .i32_const = 28 }
wasmInstructions.Instruction{ .call = 8 }
, .else_branch = null } }
wasmInstructions.Instruction{ .i32_const = 3 }
wasmInstructions.Instruction{ .global_get = 5 }
wasmInstructions.Instruction{ .global_get = 4 }
wasmInstructions.Instruction{ .i64_load = wasmInstructions.MemArg{ .align = 2, .offset = 0 } }
wasmInstructions.Instruction{ .call = 3 }
wasmInstructions.Instruction{ .local_set = 0 }
wasmInstructions.Instruction{ .local_get = 0 }
wasmInstructions.Instruction{ .i32_const = 0 }
wasmInstructions.Instruction{ .i32_ne = void }
wasmInstructions.Instruction{ .if_else = wasmInstructions.IfBlock{ .if_branch = wasmInstructions.Instruction{ .local_get = 0 }
wasmInstructions.Instruction{ .call = 9 }
wasmInstructions.Instruction{ .i32_const = 6950 }
wasmInstructions.Instruction{ .i32_const = 33 }
wasmInstructions.Instruction{ .call = 8 }
, .else_branch = null } }
wasmInstructions.Instruction{ .global_get = 4 }
wasmInstructions.Instruction{ .i64_load = wasmInstructions.MemArg{ .align = 2, .offset = 0 } }
wasmInstructions.Instruction{ .i32_const = 1 }
wasmInstructions.Instruction{ .i32_lt_u = void }
wasmInstructions.Instruction{ .global_get = 5 }
wasmInstructions.Instruction{ .i32_load8_u = wasmInstructions.MemArg{ .align = 0, .offset = 0 } }
wasmInstructions.Instruction{ .i32_const = 47 }
wasmInstructions.Instruction{ .i32_ne = void }
wasmInstructions.Instruction{ .i32_or = void }
wasmInstructions.Instruction{ .if_else = wasmInstructions.IfBlock{ .if_branch = wasmInstructions.Instruction{ .i32_const = 7025 }
wasmInstructions.Instruction{ .i32_const = 49 }
wasmInstructions.Instruction{ .call = 8 }
, .else_branch = null } }
wasmInstructions.Instruction{ .i32_const = 3 }
wasmInstructions.Instruction{ .i32_const = 1 }
wasmInstructions.Instruction{ .i32_const = 7940 }
wasmInstructions.Instruction{ .i32_const = 10 }
wasmInstructions.Instruction{ .i32_const = 0 }
wasmInstructions.Instruction{ .i64_const = 3 }
wasmInstructions.Instruction{ .i64_const = 3 }
wasmInstructions.Instruction{ .i32_const = 0 }
wasmInstructions.Instruction{ .global_get = 6 }
wasmInstructions.Instruction{ .call = 4 }
wasmInstructions.Instruction{ .local_set = 0 }
wasmInstructions.Instruction{ .local_get = 0 }
wasmInstructions.Instruction{ .i32_const = 0 }
wasmInstructions.Instruction{ .i32_ne = void }
wasmInstructions.Instruction{ .if_else = wasmInstructions.IfBlock{ .if_branch = wasmInstructions.Instruction{ .local_get = 0 }
wasmInstructions.Instruction{ .call = 9 }
wasmInstructions.Instruction{ .i32_const = 7090 }
wasmInstructions.Instruction{ .i32_const = 37 }
wasmInstructions.Instruction{ .call = 8 }
, .else_branch = null } }
wasmInstructions.Instruction{ .global_get = 8 }
wasmInstructions.Instruction{ .global_get = 10 }
wasmInstructions.Instruction{ .i32_store = wasmInstructions.MemArg{ .align = 2, .offset = 0 } }
wasmInstructions.Instruction{ .global_get = 8 }
wasmInstructions.Instruction{ .i32_const = 4 }
wasmInstructions.Instruction{ .i32_add = void }
wasmInstructions.Instruction{ .i32_const = 128 }
wasmInstructions.Instruction{ .i32_store = wasmInstructions.MemArg{ .align = 2, .offset = 0 } }
wasmInstructions.Instruction{ .global_get = 6 }
wasmInstructions.Instruction{ .i64_load = wasmInstructions.MemArg{ .align = 2, .offset = 0 } }
wasmInstructions.Instruction{ .global_get = 8 }
wasmInstructions.Instruction{ .i32_const = 1 }
wasmInstructions.Instruction{ .global_get = 9 }
wasmInstructions.Instruction{ .call = 0 }
wasmInstructions.Instruction{ .local_set = 0 }
wasmInstructions.Instruction{ .local_get = 0 }
wasmInstructions.Instruction{ .i32_const = 0 }
wasmInstructions.Instruction{ .i32_ne = void }
wasmInstructions.Instruction{ .if_else = wasmInstructions.IfBlock{ .if_branch = wasmInstructions.Instruction{ .i32_const = 7130 }
wasmInstructions.Instruction{ .i32_const = 29 }
wasmInstructions.Instruction{ .call = 8 }
, .else_branch = null } }
wasmInstructions.Instruction{ .global_get = 9 }
wasmInstructions.Instruction{ .i64_load = wasmInstructions.MemArg{ .align = 2, .offset = 0 } }
wasmInstructions.Instruction{ .call = 9 }
wasmInstructions.Instruction{ .i32_const = 7170 }
wasmInstructions.Instruction{ .i32_const = 17 }
wasmInstructions.Instruction{ .call = 7 }
wasmInstructions.Instruction{ .global_get = 10 }
wasmInstructions.Instruction{ .global_get = 9 }
wasmInstructions.Instruction{ .call = 7 }
 }[1] wasm.CodeSection.Code{ .size = 53, .locals = array_list.ArrayListAligned(wasm.CodeSection.Code.Local,null){ .items = {  }, .capacity = 0, .allocator = mem.Allocator{ .ptr = anyopaque@119f628, .vtable = mem.Allocator.VTable{ ... } } }, .expr = wasmInstructions.Instruction{ .global_get = 0 }
wasmInstructions.Instruction{ .local_get = 0 }
wasmInstructions.Instruction{ .i32_store = wasmInstructions.MemArg{ .align = 2, .offset = 0 } }
wasmInstructions.Instruction{ .global_get = 1 }
wasmInstructions.Instruction{ .local_get = 1 }
wasmInstructions.Instruction{ .i32_store = wasmInstructions.MemArg{ .align = 2, .offset = 0 } }
wasmInstructions.Instruction{ .i32_const = 1 }
wasmInstructions.Instruction{ .global_get = 0 }
wasmInstructions.Instruction{ .i32_const = 1 }
wasmInstructions.Instruction{ .global_get = 2 }
wasmInstructions.Instruction{ .call = 1 }
wasmInstructions.Instruction{ .drop = void }
wasmInstructions.Instruction{ .global_get = 0 }
wasmInstructions.Instruction{ .i32_const = 8010 }
wasmInstructions.Instruction{ .i32_store = wasmInstructions.MemArg{ .align = 2, .offset = 0 } }
wasmInstructions.Instruction{ .global_get = 1 }
wasmInstructions.Instruction{ .i32_const = 1 }
wasmInstructions.Instruction{ .i32_store = wasmInstructions.MemArg{ .align = 2, .offset = 0 } }
wasmInstructions.Instruction{ .i32_const = 1 }
wasmInstructions.Instruction{ .global_get = 0 }
wasmInstructions.Instruction{ .i32_const = 1 }
wasmInstructions.Instruction{ .global_get = 2 }
wasmInstructions.Instruction{ .call = 1 }
wasmInstructions.Instruction{ .drop = void }
 }[2] wasm.CodeSection.Code{ .size = 12, .locals = array_list.ArrayListAligned(wasm.CodeSection.Code.Local,null){ .items = {  }, .capacity = 0, .allocator = mem.Allocator{ .ptr = anyopaque@119f628, .vtable = mem.Allocator.VTable{ ... } } }, .expr = wasmInstructions.Instruction{ .local_get = 0 }
wasmInstructions.Instruction{ .local_get = 1 }
wasmInstructions.Instruction{ .call = 7 }
wasmInstructions.Instruction{ .i32_const = 1 }
wasmInstructions.Instruction{ .call = 5 }
 }[3] wasm.CodeSection.Code{ .size = 119, .locals = array_list.ArrayListAligned(wasm.CodeSection.Code.Local,null){ .items = { wasm.CodeSection.Code.Local{ ... } }, .capacity = 8, .allocator = mem.Allocator{ .ptr = anyopaque@119f628, .vtable = mem.Allocator.VTable{ ... } } }, .expr = wasmInstructions.Instruction{ .local_get = 0 }
wasmInstructions.Instruction{ .i32_const = 10 }
wasmInstructions.Instruction{ .i32_lt_s = void }
wasmInstructions.Instruction{ .if_else = wasmInstructions.IfBlock{ .if_branch = wasmInstructions.Instruction{ .i32_const = 1 }
wasmInstructions.Instruction{ .local_set = 2 }
, .else_branch = null } }
wasmInstructions.Instruction{ .i32_const = 0 }
wasmInstructions.Instruction{ .local_set = 2 }
wasmInstructions.Instruction{ .local_get = 0 }
wasmInstructions.Instruction{ .local_set = 1 }
wasmInstructions.Instruction{ .loop = void }
wasmInstructions.Instruction{ .memory_grow = void }
wasmInstructions.Instruction{ .block = void }
wasmInstructions.Instruction{ .memory_grow = void }
wasmInstructions.Instruction{ .local_get = 1 }
wasmInstructions.Instruction{ .i32_eqz = void }
wasmInstructions.Instruction{ .br_if = void }
wasmInstructions.Instruction{ .unreachable = void }
wasmInstructions.Instruction{ .local_get = 1 }
wasmInstructions.Instruction{ .i32_const = 10 }
wasmInstructions.Instruction{ .i32_div_u = void }
wasmInstructions.Instruction{ .local_set = 1 }
wasmInstructions.Instruction{ .local_get = 2 }
wasmInstructions.Instruction{ .i32_const = 1 }
wasmInstructions.Instruction{ .i32_add = void }
wasmInstructions.Instruction{ .local_set = 2 }
wasmInstructions.Instruction{ .br = void }
wasmInstructions.Instruction{ .nop = void }
 }