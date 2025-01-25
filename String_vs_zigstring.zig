const std = @import("std");
const io = @import("./libs/io/io.zig");
const zbench = @import("./libs/zbench//zbench.zig");
const zString = @import("./libs/zig-string/zig-string.zig").String;
const Allocator = std.mem.Allocator;

const long_str : [1024]u8 = [_]u8{'a'} ** 1024;
const norm_str : [24]u8 = [_]u8{'a'} ** 24;

fn String(allocator: Allocator, comptime num: usize) void {
    var string = io.types.String.initAlloc(allocator); defer string.deinit();
    for (0..num) |_| string.append(long_str[0..]) catch @panic("Error");
}

fn zigstring(allocator: Allocator, comptime num: usize) void {
    var string = zString.init(allocator); defer string.deinit();
    for (0..num) |_| string.concat(long_str[0..]) catch @panic("Error");
}

fn String_x1(allocator: Allocator) void { String(allocator, 1); }
fn String_x10(allocator: Allocator) void { String(allocator, 10); }
fn String_x100(allocator: Allocator) void { String(allocator, 100); }
fn String_x1000(allocator: Allocator) void { String(allocator, 1000); }

fn zigstring_x1(allocator: Allocator) void { zigstring(allocator, 1); }
fn zigstring_x10(allocator: Allocator) void { zigstring(allocator, 10); }
fn zigstring_x100(allocator: Allocator) void { zigstring(allocator, 100); }
fn zigstring_x1000(allocator: Allocator) void { zigstring(allocator, 1000); }


pub fn main() !void {

    const stdout = std.io.getStdOut().writer();
    var bench = zbench.Benchmark.init(std.heap.page_allocator, .{});
    defer bench.deinit();

    try bench.add("zig-string x1",      zigstring_x1,       .{});
    try bench.add("String x1",          String_x1,          .{});

    try bench.add("zig-string x10",     zigstring_x10,      .{});
    try bench.add("String x10",         String_x10,         .{});

    try bench.add("zig-string x100",    zigstring_x100,     .{});
    try bench.add("String x100",        String_x100,        .{});

    try bench.add("zig-string x1000",   zigstring_x1000,    .{});
    try bench.add("String x1000",       String_x1000,       .{});

    try stdout.writeAll("\n");

    try bench.run(stdout);
}