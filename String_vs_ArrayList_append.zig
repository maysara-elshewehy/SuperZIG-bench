const std = @import("std");
const io = @import("./libs/io/io.zig");
const zbench = @import("./libs/zbench//zbench.zig");
const Allocator = std.mem.Allocator;

const long_str : [1024]u8 = [_]u8{'a'} ** 1024;
const norm_str : [24]u8 = [_]u8{'a'} ** 24;

fn String(allocator: Allocator, comptime num: usize) void {
    var string = io.types.String.initAlloc(allocator); defer string.deinit();
    for (0..num) |_| string.append(long_str[0..]) catch @panic("Error");
}

fn ArrayList(allocator: Allocator, comptime num: usize) void {
    var list = std.ArrayList(u8).init(allocator); defer list.deinit();
    for (0..num) |_| list.appendSlice(long_str[0..]) catch @panic("Error");
}

fn String_x1(allocator: Allocator) void { String(allocator, 1); }
fn String_x10(allocator: Allocator) void { String(allocator, 10); }
fn String_x100(allocator: Allocator) void { String(allocator, 100); }
fn String_x1000(allocator: Allocator) void { String(allocator, 1000); }

fn ArrayList_x1(allocator: Allocator) void { ArrayList(allocator, 1); }
fn ArrayList_x10(allocator: Allocator) void { ArrayList(allocator, 10); }
fn ArrayList_x100(allocator: Allocator) void { ArrayList(allocator, 100); }
fn ArrayList_x1000(allocator: Allocator) void { ArrayList(allocator, 1000); }


pub fn main() !void {

    const stdout = std.io.getStdOut().writer();
    var bench = zbench.Benchmark.init(std.heap.page_allocator, .{});
    defer bench.deinit();

    try bench.add("ArrayList x1",       ArrayList_x1,       .{});
    try bench.add("String x1",          String_x1,          .{});

    try bench.add("ArrayList x10",      ArrayList_x10,      .{});
    try bench.add("String x10",         String_x10,         .{});

    try bench.add("ArrayList x100",     ArrayList_x100,     .{});
    try bench.add("String x100",        String_x100,        .{});

    try bench.add("ArrayList x1000",    ArrayList_x1000,    .{});
    try bench.add("String x1000",       String_x1000,       .{});

    try stdout.writeAll("\n");

    try bench.run(stdout);
}