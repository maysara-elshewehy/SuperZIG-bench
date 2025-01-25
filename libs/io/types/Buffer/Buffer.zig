// ╔══════════════════════════════════════ INIT ══════════════════════════════════════╗

    const std = @import("std");
    const utf8 = @import("../../utils/utf8/utf8.zig");
    const Bytes = @import("../../utils/bytes/bytes.zig");

// ╚══════════════════════════════════════════════════════════════════════════════════╝



// ╔══════════════════════════════════════ CORE ══════════════════════════════════════╗

    /// Mutable fixed utf8 string type.
    pub fn Buffer(comptime array_size: usize) type {
        return struct {

            // ┌──────────────────────────── ---- ────────────────────────────┐

                const Self = @This();

            // └──────────────────────────────────────────────────────────────┘


            // ┌─────────────────────────── Fields ───────────────────────────┐

                /// The mutable UTF-8 encoded bytes.
                source: [array_size]u8 = .{0} ** array_size,

                /// The number of written bytes to `source`.
                length: usize = 0,

            // └──────────────────────────────────────────────────────────────┘


            // ┌─────────────────────────── Insert ───────────────────────────┐

                pub const insertError       = Bytes.insertError;
                pub const insertVisualError = Bytes.insertVisualError;

                /// Inserts a `slice` into the `Buffer` instance at the specified `position` by **real position**.
                /// - `insertError.OutOfRange` **_if the insertion exceeds the bounds of the `Buffer` instance._**
                /// - `insertError.OutOfRange` **_if the `pos` is greater than `self.length`._**
                ///
                /// Modifies the `Buffer` instance in place **_if `slice` length is greater than 0_.**
                pub fn insert(self: *Self, slice: []const u8, pos: usize) insertError!void {
                    try Bytes.insert(&self.source, slice, self.length, pos);
                    self.length += slice.len;
                }

                /// Inserts a `byte` into the `Buffer` instance at the specified `position` by **real position**.
                /// - `insertError.OutOfRange` **_if the insertion exceeds the bounds of the `Buffer` instance._**
                /// - `insertError.OutOfRange` **_if the `pos` is greater than `self.length`._**
                ///
                /// Modifies the `Buffer` instance in place.
                pub fn insertOne(self: *Self, byte: u8, pos: usize) insertError!void {
                    try Bytes.insertOne(&self.source, byte, self.length, pos);
                    self.length += 1;
                }

                /// Inserts a `slice` into the `Buffer` instance at the specified `visual position`.
                /// - `insertVisualError.InvalidPosition` **_if the `pos` is invalid._**
                /// - `insertVisualError.OutOfRange` **_if the insertion exceeds the bounds of the `Buffer` instance._**
                /// - `insertVisualError.OutOfRange` **_if the `pos` is greater than `self.length`._**
                ///
                /// Modifies the `Buffer` instance in place **_if `slice` length is greater than 0_.**
                pub fn insertVisual(self: *Self, slice: []const u8, pos: usize) insertVisualError!void {
                    try Bytes.insertVisual(&self.source, slice, self.length, pos);
                    self.length += slice.len;
                }

                /// Inserts a `byte` into the `Buffer` instance at the specified `visual position`.
                /// - `insertVisualError.InvalidPosition` **_if the `pos` is invalid._**
                /// - `insertVisualError.OutOfRange` **_if the insertion exceeds the bounds of the `Buffer` instance._**
                /// - `insertVisualError.OutOfRange` **_if the `pos` is greater than `self.length`._**
                ///
                /// Modifies the `Buffer` instance in place.
                pub fn insertVisualOne(self: *Self, byte: u8, pos: usize) insertVisualError!void {
                    try Bytes.insertVisualOne(&self.source, byte, self.length, pos);
                    self.length += 1;
                }

                /// Appends a `slice` into the `Buffer` instance.
                /// - `insertError.OutOfRange` **_if the insertion exceeds the bounds of the `Buffer` instance._**
                ///
                /// Modifies the `Buffer` instance in place **_if `slice` length is greater than 0_.**
                pub fn append(self: *Self, slice: []const u8) insertError!void {
                    try Bytes.append(&self.source, slice, self.length);
                    self.length += slice.len;
                }

                /// Appends a `byte` into the `Buffer` instance.
                /// - `insertError.OutOfRange` **_if the insertion exceeds the bounds of the `Buffer` instance._**
                ///
                /// Modifies the `Buffer` instance in place.
                pub fn appendOne(self: *Self, byte: u8) insertError!void {
                    try Bytes.appendOne(&self.source, byte, self.length);
                    self.length += 1;
                }

                /// Prepends a `slice` into the `Buffer` instance.
                /// - `insertError.OutOfRange` **_if the insertion exceeds the bounds of the `Buffer` instance._**
                ///
                /// Modifies the `Buffer` instance in place **_if `slice` length is greater than 0_.**
                pub fn prepend(self: *Self, slice: []const u8) insertError!void {
                    try Bytes.prepend(&self.source, slice, self.length);
                    self.length += slice.len;
                }

                /// Prepends a `byte` into the `Buffer` instance.
                /// - `insertError.OutOfRange` **_if the insertion exceeds the bounds of the `Buffer` instance._**
                ///
                /// Modifies the `Buffer` instance in place.
                pub fn prependOne(self: *Self, byte: u8) insertError!void {
                    try Bytes.prependOne(&self.source, byte, self.length);
                    self.length += 1;
                }

            // └──────────────────────────────────────────────────────────────┘


            // ┌─────────────────────────── Remove ───────────────────────────┐

                pub const removeError       = Bytes.removeError;
                pub const removeVisualError = Bytes.removeVisualError;

                /// Removes a byte from the `Buffer` instance.
                /// - `removeError.OutOfRange` **_if the `pos` is greater than `self.length`._**
                ///
                /// Modifies the `Buffer` instance in place.
                pub fn remove(self: *Self, pos: usize) removeError!void {
                    try Bytes.remove(&self.source, self.length, pos);
                    self.length -= 1;
                }

                /// Removes a `range` of bytes from the `Buffer` instance.
                /// - `insertVisualError.InvalidPosition` **_if the `pos` is invalid._**
                /// - `removeError.OutOfRange` **_if the `pos` is greater than `self.length`._**
                ///
                /// Modifies the `Buffer` instance in place.
                pub fn removeRange(self: *Self, pos: usize, len: usize) removeError!void {
                    try Bytes.removeRange(&self.source, self.length, pos, len);
                    self.length -= len;
                }

                /// Removes a byte from the `Buffer` instance by the `visual position`.
                /// - `removeVisualError.InvalidPosition` **_if the `pos` is invalid._**
                /// - `removeVisualError.OutOfRange` **_if the `pos` is greater than `self.length`._**
                ///
                /// Returns the removed slice.
                pub fn removeVisual(self: *Self, pos: usize) removeVisualError![]const u8 {
                    const removed_slice = try Bytes.removeVisual(&self.source, self.length, pos);
                    self.length -= removed_slice.len;
                    return removed_slice;
                }

                /// Removes a `range` of bytes from the `Buffer` instance by the `visual position`.
                /// - `removeVisualError.InvalidPosition` **_if the `pos` is invalid._**
                /// - `removeVisualError.OutOfRange` **_if the `pos` is greater than `self.length`._**
                ///
                /// Returns the removed slice.
                pub fn removeVisualRange(self: *Self, pos: usize, len: usize) removeVisualError![]const u8 {
                    const removed_slice = try Bytes.removeVisualRange(&self.source, self.length, pos, len);
                    self.length -= removed_slice.len;
                    return removed_slice;
                }

                /// Removes the last grapheme cluster at the `Buffer` instance,
                /// Returns the removed slice.
                pub inline fn pop(self: *Self) ?[]const u8 {
                    const len = Bytes.pop(self.source[0..self.length]);
                    if(len == 0) return null;

                    self.length -= len;
                    return self.source[self.length..self.length+len];
                }

                /// Removes the first grapheme cluster at the `Buffer` instance,
                /// Returns the number of removed bytes.
                pub inline fn shift(self: *Self) usize {
                    const len = Bytes.shift(self.source[0..self.length]);
                    self.length -= len;
                    return len;
                }

            // └──────────────────────────────────────────────────────────────┘


            // ┌──────────────────────────── Find ────────────────────────────┐

                /// Finds the `position` of the **first** occurrence of `target`.
                pub fn find(self: Self, target: []const u8) ?usize {
                    return Bytes.find(self.source[0..self.length], target);
                }

                /// Finds the `visual position` of the **first** occurrence of `target`.
                pub fn findVisual(self: Self, target: []const u8) !?usize {
                    return Bytes.findVisual(self.source[0..self.length], target);
                }

                /// Finds the `position` of the **last** occurrence of `target`.
                pub fn rfind(self: Self, target: []const u8) ?usize {
                    return Bytes.rfind(self.source[0..self.length], target);
                }

                /// Finds the `visual position` of the **last** occurrence of `target`.
                pub fn rfindVisual(self: Self, target: []const u8) ?usize {
                    return Bytes.rfindVisual(self.source[0..self.length], target);
                }

                /// Returns `true` **if contains `target`**.
                pub fn includes(self: Self, target: []const u8) bool {
                    return Bytes.includes(self.source[0..self.length], target);
                }

                /// Returns `true` **if starts with `target`**.
                pub fn startsWith(self: Self, target: []const u8) bool {
                    return Bytes.startsWith(self.source[0..self.length], target);
                }

                /// Returns `true` **if ends with `target`**.
                pub fn endsWith(self: Self, target: []const u8) bool {
                    return Bytes.endsWith(self.source[0..self.length], target);
                }

            // └──────────────────────────────────────────────────────────────┘


            // ┌──────────────────────────── Case ────────────────────────────┐

                /// Converts all (ASCII) letters to lowercase.
                pub fn toLower(self: *Self) void {
                    Bytes.toLower(self.source[0..self.length]);
                }

                /// Converts all (ASCII) letters to uppercase.
                pub fn toUpper(self: *Self) void {
                    Bytes.toUpper(self.source[0..self.length]);
                }

                // Converts all (ASCII) letters to titlecase.
                pub fn toTitle(self: *Self) void {
                    Bytes.toTitle(self.source[0..self.length]);
                }

            // └──────────────────────────────────────────────────────────────┘


            // ┌──────────────────────────── Count ───────────────────────────┐

                /// Returns the total number of written bytes, stopping at the first null byte.
                pub fn countWritten(self: Self) usize {
                    return self.length;
                }

                /// Returns the total number of visual characters, stopping at the first null byte.
                pub fn countVisual(self: Self) usize {
                    return Bytes.countVisual(self.source[0..self.length]) catch unreachable;
                }

            // └──────────────────────────────────────────────────────────────┘


            // ┌────────────────────────── Iterator ──────────────────────────┐

                /// Creates an iterator for traversing the UTF-8 bytes.
                /// - `utf8.Iterator.Error` **_if the initialization failed._**
                pub fn iterator(self: Self) utf8.Iterator.Error!utf8.Iterator {
                    return try utf8.Iterator.init(self.source[0..self.length]);
                }

            // └──────────────────────────────────────────────────────────────┘


            // ┌──────────────────────────── Utils ───────────────────────────┐

                /// Returns a copy of the `Buffer` instance.
                pub fn clone(self: Self) Self {
                    return .{
                        .source = Bytes.unsafeInit(array_size, self.source[0..self.length]),
                        .length = self.length
                    };
                }

                /// Reverses the order of the characters **_(considering unicode)_**.
                pub fn reverse(self: *Self) void {
                    if (self.length == 0) return;
                    const original_data = self.clone();
                    var utf8_iterator = utf8.Iterator.unsafeInit(original_data.source[0..original_data.length]);
                    var i: usize = self.length;

                    while (utf8_iterator.nextGraphemeCluster()) |gc| {
                        i -= gc.len;
                        @memcpy(self.source[i..i + gc.len], gc);
                        if (i == 0) break; // to avoid underflow.
                    }
                }

            // └──────────────────────────────────────────────────────────────┘

        };
    }

// ╚══════════════════════════════════════════════════════════════════════════════════╝



// ╔══════════════════════════════════════ MAKE ══════════════════════════════════════╗

    pub const initError = Bytes.initError;
    pub const initCapacityError = Bytes.initCapacityError;

    /// Initializes a `Buffer` of a pre-specified `size`.
    /// - `initCapacityError.ZeroSize` _if the `size` is 0._
    pub fn initCapacity(comptime size: usize) initCapacityError!Buffer(size) {
        return .{
            .source = try Bytes.initCapacity(size),
            .length = 0
        };
    }

    /// Initializes a `Buffer` of a pre-specified `size` and `value`.
    /// - `initError.ZeroSize` **_if the length of `value` is 0._**
    /// - `initError.OutOfRange` **_if the length of `value` exceeds `size`._**
    pub fn init(comptime size: usize, value: []const u8) initError!Buffer(size) {
        return .{
            .source = try Bytes.init(size, value),
            .length = Bytes.countWritten(value)
        };
    }

// ╚══════════════════════════════════════════════════════════════════════════════════╝