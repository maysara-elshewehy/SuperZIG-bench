// run using `zig run ./bench/string.zig -O ReleaseFast`

const std = @import("std");
const String = @import("./libs/io/io.zig").String(u8);
const zstr = @import("./libs/zig-string/zig-string.zig").String;
const zbench = @import("./libs/zbench//zbench.zig");
const Allocator = std.mem.Allocator;

const long_str : [99]u8 = [_]u8{'a'} ** 99;
const norm_str : [10]u8 = [_]u8{'a'} ** 10;

fn ArrayListBench(allocator: Allocator, comptime num: usize) void {
    var list = std.ArrayList(u8).init(allocator); defer list.deinit();
    for (0..num) |_| list.appendSlice(long_str[0..]) catch @panic("Error");
}

fn ZigStringBench(allocator: Allocator, comptime num: usize) void {
    var string = zstr.init(allocator); defer string.deinit();
    for (0..num) |_| string.concat(long_str[0..]) catch @panic("Error");
}

fn StringBench(allocator: Allocator, comptime num: usize) void {
    var string = String.initEmpty(allocator) catch @panic("Error"); defer string.deinit();
    for (0..num) |_| string.appendSlice(long_str[0..]) catch @panic("Error");
}

fn ArrayList_x1(allocator: Allocator) void { ArrayListBench(allocator, 1); }
fn ArrayList_x10(allocator: Allocator) void { ArrayListBench(allocator, 10); }
fn ArrayList_x100(allocator: Allocator) void { ArrayListBench(allocator, 100); }
fn ArrayList_x1000(allocator: Allocator) void { ArrayListBench(allocator, 1000); }

fn zString_x1(allocator: Allocator) void { ZigStringBench(allocator, 1); }
fn zString_x10(allocator: Allocator) void { ZigStringBench(allocator, 10); }
fn zString_x100(allocator: Allocator) void { ZigStringBench(allocator, 100); }
fn zString_x1000(allocator: Allocator) void { ZigStringBench(allocator, 1000); }

fn String_x1(allocator: Allocator) void { StringBench(allocator, 1); }
fn String_x10(allocator: Allocator) void { StringBench(allocator, 10); }
fn String_x100(allocator: Allocator) void { StringBench(allocator, 100); }
fn String_x1000(allocator: Allocator) void { StringBench(allocator, 1000); }

pub fn main() !void {

    const stdout = std.io.getStdOut().writer();
    var bench = zbench.Benchmark.init(std.heap.page_allocator, .{});
    defer bench.deinit();

    try bench.add("__",                 ArrayList_x1,       .{});
    try bench.add("__",                 zString_x1,         .{});
    try bench.add("__",                 String_x1,          .{});

    // slice
    try bench.add("std_MANY_x1",        ArrayList_x1,       .{});
    try bench.add("zstr_MANY_x1",       zString_x1,         .{});
    try bench.add("str_MANY_x1",        String_x1,          .{});

    try bench.add("std_MANY_x10",       ArrayList_x10,      .{});
    try bench.add("zstr_MANY_x10",      zString_x10,        .{});
    try bench.add("str_MANY_x10",       String_x10,         .{});

    try bench.add("std_MANY_x100",      ArrayList_x100,     .{});
    try bench.add("zstr_MANY_x100",     zString_x100,       .{});
    try bench.add("str_MANY_x100",      String_x100,        .{});

    try bench.add("std_MANY_x1000",     ArrayList_x1000,    .{});
    try bench.add("zstr_MANY_x1000",    zString_x1000,      .{});
    try bench.add("str_MANY_x1000",     String_x1000,       .{});

    try stdout.writeAll("\n");
    try bench.run(stdout);
}