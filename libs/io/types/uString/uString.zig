// ╔══════════════════════════════════════ INIT ══════════════════════════════════════╗

    const std = @import("std");
    const utf8 = @import("../../utils/utf8/utf8.zig");
    const Bytes = @import("../../utils/bytes/bytes.zig");
    const StringContainer = @import("../String/String.zig");

    const Allocator = std.mem.Allocator;
    const AllocatorError = Allocator.Error || error { OutOfMemory };

// ╚══════════════════════════════════════════════════════════════════════════════════╝



// ╔══════════════════════════════════════ CORE ══════════════════════════════════════╗

    /// Manage dynamic utf8 string type.
    pub const uString = struct {

        // ┌──────────────────────────── ---- ────────────────────────────┐

            const Self = @This();

        // └──────────────────────────────────────────────────────────────┘


        // ┌─────────────────────────── Fields ───────────────────────────┐

            /// The mutable UTF-8 encoded bytes.
            source: []u8 = &[_]u8{},

            /// The number of bytes that can be written to `source`.
            capacity: usize = 0,

        // └──────────────────────────────────────────────────────────────┘


        // ┌─────────────────────── Initialization ───────────────────────┐

            pub const initError = AllocatorError || error { ZeroSize };

            /// Initializes a new `uString` instance using `allocator` and `value`.
            /// - `initError.ZeroSize` **_if the length of `value` is 0._**
            /// - `std.mem.Allocator` **_if the allocator returned an error._**
            pub fn init(alloator: Allocator, value: []const u8) initError!Self {
                var self = try Self.initCapacity(alloator, value.len*2);
                Bytes.unsafeAppend(self.allocatedSlice(), value, 0);
                self.source.len = Bytes.countWritten(value);

                return self;
            }

            /// Initializes a new `uString` instance using `allocator` and `size`.
            /// - `initError.ZeroSize` _if the `size` is 0._
            pub fn initCapacity(allocator: Allocator, size: usize) initError!Self {
                if(size == 0) return initError.ZeroSize;

                var self = Self{};
                try self.ensureCapacity(allocator, size);
                return self;
            }

            /// Release all allocated memory.
            pub fn deinit(self: *Self, allocator: Allocator) void {
                allocator.free(self.allocatedSlice());
                self.* = undefined;
            }

        // └──────────────────────────────────────────────────────────────┘


        // ┌─────────────────────────── Insert ───────────────────────────┐

            pub const insertError       = AllocatorError || Bytes.insertError;
            pub const insertVisualError = AllocatorError || Bytes.insertVisualError;

            /// Inserts a `slice` into the `uString` instance at the specified `position` by **real position**.
            /// - `insertError.OutOfRange` **_if the `pos` is greater than `self.source.len`._**
            ///
            /// Modifies the `uString` instance in place **_if `slice` length is greater than 0_.**
            pub fn insert(self: *Self, allocator: Allocator, slice: []const u8, pos: usize) insertError!void {
                if (slice.len == 0) return;
                if (pos > self.source.len) return insertError.OutOfRange;
                try self.ensureCapacity(allocator, slice.len);
                Bytes.unsafeInsert(self.allocatedSlice(), slice, self.length(), pos);
                self.source.len += slice.len;
            }

            /// Inserts a `byte` into the `uString` instance at the specified `position` by **real position**.
            /// - `insertError.OutOfRange` **_if the `pos` is greater than `self.source.len`._**
            ///
            /// Modifies the `uString` instance in place.
            pub fn insertOne(self: *Self, allocator: Allocator, byte: u8, pos: usize) insertError!void {
                if (pos > self.source.len) return insertError.OutOfRange;
                try self.ensureCapacity(allocator, 1);
                Bytes.unsafeInsertOne(self.allocatedSlice(), byte, self.length(), pos);
                self.source.len += 1;
            }

            /// Inserts a `slice` into the `uString` instance at the specified `visual position`.
            /// - `insertVisualError.OutOfRange` **_if the `pos` is greater than `self.source.len`._**
            /// - `insertVisualError.InvalidPosition` **_if the `pos` is invalid._**
            ///
            /// Modifies the `uString` instance in place **_if `slice` length is greater than 0_.**
            pub fn insertVisual(self: *Self, allocator: Allocator, slice: []const u8, pos: usize) insertVisualError!void {
                if (pos > self.source.len) return insertVisualError.OutOfRange;
                const real_pos = utf8.utils.getRealPosition(self.writtenSlice(), pos) catch return insertVisualError.InvalidPosition;
                try self.ensureCapacity(allocator, slice.len);
                Bytes.unsafeInsert(self.allocatedSlice(), slice, self.length(), real_pos);
                self.source.len += slice.len;
            }

            /// Inserts a `byte` into the `uString` instance at the specified `visual position`.
            /// - `insertVisualError.OutOfRange` **_if the `pos` is greater than `self.source.len`._**
            /// - `insertVisualError.InvalidPosition` **_if the `pos` is invalid._**
            ///
            /// Modifies the `uString` instance in place.
            pub fn insertVisualOne(self: *Self, allocator: Allocator, byte: u8, pos: usize) insertVisualError!void {
                if (pos > self.source.len) return insertVisualError.OutOfRange;
                const real_pos = utf8.utils.getRealPosition(self.writtenSlice(), pos) catch return insertVisualError.InvalidPosition;
                try self.ensureCapacity(allocator, 1);
                Bytes.unsafeInsertOne(self.allocatedSlice(), byte, self.length(), real_pos);
                self.source.len += 1;
            }

            /// Appends a `slice` into the `uString` instance.
            ///
            /// Modifies the `uString` instance in place **_if `slice` length is greater than 0_.**
            pub fn append(self: *Self, allocator: Allocator, slice: []const u8) insertError!void {
                if (slice.len == 0) return;
                try self.ensureCapacity(allocator, slice.len);
                Bytes.unsafeAppend(self.allocatedSlice(), slice, self.length());
                self.source.len += slice.len;
            }

            /// Appends a `byte` into the `uString` instance.
            ///
            /// Modifies the `uString` instance in place.
            pub fn appendOne(self: *Self, allocator: Allocator, byte: u8) insertError!void {
                try self.ensureCapacity(allocator, 1);
                Bytes.unsafeAppendOne(self.allocatedSlice(), byte, self.length());
                self.source.len += 1;
            }

            /// Prepends a `slice` into the `uString` instance.
            ///
            /// Modifies the `uString` instance in place **_if `slice` length is greater than 0_.**
            pub fn prepend(self: *Self, allocator: Allocator, slice: []const u8) insertError!void {
                if (slice.len == 0) return;
                try self.ensureCapacity(allocator, slice.len);
                Bytes.unsafePrepend(self.allocatedSlice(), slice, self.length());
                self.source.len += slice.len;
            }

            /// Prepends a `byte` into the `uString` instance.
            ///
            /// Modifies the `uString` instance in place.
            pub fn prependOne(self: *Self, allocator: Allocator, byte: u8) insertError!void {
                try self.ensureCapacity(allocator, 1);
                Bytes.unsafePrependOne(self.allocatedSlice(), byte, self.length());
                self.source.len += 1;
            }

        // └──────────────────────────────────────────────────────────────┘


        // ┌─────────────────────────── Remove ───────────────────────────┐

            pub const removeError       = Bytes.removeError;
            pub const removeVisualError = Bytes.removeVisualError;

            /// Removes a byte from the `uString` instance.
            /// - `removeError.OutOfRange` **_if the `pos` is greater than `self.source.len`._**
            ///
            /// Modifies the `uString` instance in place.
            pub fn remove(self: *Self, pos: usize) removeError!void {
                try Bytes.remove(self.allocatedSlice(), self.length(), pos);
                self.source.len -= 1;
            }

            /// Removes a `range` of bytes from the `uString` instance.
            /// - `insertVisualError.InvalidPosition` **_if the `pos` is invalid._**
            /// - `removeError.OutOfRange` **_if the `pos` is greater than `self.source.len`._**
            ///
            /// Modifies the `uString` instance in place.
            pub fn removeRange(self: *Self, pos: usize, len: usize) removeError!void {
                try Bytes.removeRange(self.allocatedSlice(), self.length(), pos, len);
                self.source.len -= len;
            }

            /// Removes a byte from the `uString` instance by the `visual position`.
            /// - `removeVisualError.InvalidPosition` **_if the `pos` is invalid._**
            /// - `removeVisualError.OutOfRange` **_if the `pos` is greater than `self.source.len`._**
            ///
            /// Returns the removed slice.
            pub fn removeVisual(self: *Self, pos: usize) removeVisualError![]const u8 {
                const removed_slice = try Bytes.removeVisual(self.allocatedSlice(), self.length(), pos);
                self.source.len -= removed_slice.len;
                return removed_slice;
            }

            /// Removes a `range` of bytes from the `uString` instance by the `visual position`.
            /// - `removeVisualError.InvalidPosition` **_if the `pos` is invalid._**
            /// - `removeVisualError.OutOfRange` **_if the `pos` is greater than `self.source.len`._**
            ///
            /// Returns the removed slice.
            pub fn removeVisualRange(self: *Self, pos: usize, len: usize) removeVisualError![]const u8 {
                const removed_slice = try Bytes.removeVisualRange(self.allocatedSlice(), self.length(), pos, len);
                self.source.len -= removed_slice.len;
                return removed_slice;
            }

            /// Removes the last grapheme cluster at the `uString` instance,
            /// Returns the removed slice.
            pub inline fn pop(self: *Self) ?[]const u8 {
                const len = Bytes.pop(self.writtenSlice());
                if(len == 0) return null;

                self.source.len -= len;
                return self.allocatedSlice()[self.source.len..self.source.len+len];
            }

            /// Removes the first grapheme cluster at the `uString` instance,
            /// Returns the number of removed bytes.
            pub inline fn shift(self: *Self) usize {
                const len = Bytes.shift(self.allocatedSlice()[0..self.source.len]);
                self.source.len -= len;
                return len;
            }

        // └──────────────────────────────────────────────────────────────┘


        // ┌──────────────────────────── Find ────────────────────────────┐

            /// Finds the `position` of the **first** occurrence of `target`.
            pub fn find(self: Self, target: []const u8) ?usize {
                return Bytes.find(self.writtenSlice(), target);
            }

            /// Finds the `visual position` of the **first** occurrence of `target`.
            pub fn findVisual(self: Self, target: []const u8) !?usize {
                return Bytes.findVisual(self.writtenSlice(), target);
            }

            /// Finds the `position` of the **last** occurrence of `target`.
            pub fn rfind(self: Self, target: []const u8) ?usize {
                return Bytes.rfind(self.writtenSlice(), target);
            }

            /// Finds the `visual position` of the **last** occurrence of `target`.
            pub fn rfindVisual(self: Self, target: []const u8) ?usize {
                return Bytes.rfindVisual(self.writtenSlice(), target);
            }

            /// Returns `true` **if contains `target`**.
            pub fn includes(self: Self, target: []const u8) bool {
                return Bytes.includes(self.writtenSlice(), target);
            }

            /// Returns `true` **if starts with `target`**.
            pub fn startsWith(self: Self, target: []const u8) bool {
                return Bytes.startsWith(self.writtenSlice(), target);
            }

            /// Returns `true` **if ends with `target`**.
            pub fn endsWith(self: Self, target: []const u8) bool {
                return Bytes.endsWith(self.writtenSlice(), target);
            }

        // └──────────────────────────────────────────────────────────────┘


        // ┌──────────────────────────── Case ────────────────────────────┐

            /// Converts all (ASCII) letters to lowercase.
            pub fn toLower(self: *Self) void {
                if(self.source.len > 0)
                Bytes.toLower(self.allocatedSlice()[0..self.source.len]);
            }

            /// Converts all (ASCII) letters to uppercase.
            pub fn toUpper(self: *Self) void {
                if(self.source.len > 0)
                Bytes.toUpper(self.allocatedSlice()[0..self.source.len]);
            }

            // Converts all (ASCII) letters to titlecase.
            pub fn toTitle(self: *Self) void {
                if(self.source.len > 0)
                Bytes.toTitle(self.allocatedSlice()[0..self.source.len]);
            }

        // └──────────────────────────────────────────────────────────────┘


        // ┌──────────────────────────── Count ───────────────────────────┐

            /// Returns the total number of written bytes, stopping at the first null byte.
            pub fn countWritten(self: Self) usize {
                return self.source.len;
            }

            /// Returns the total number of visual characters, stopping at the first null byte.
            pub fn countVisual(self: Self) usize {
                return Bytes.countVisual(self.writtenSlice()) catch unreachable;
            }

        // └──────────────────────────────────────────────────────────────┘


        // ┌────────────────────────── Iterator ──────────────────────────┐

            /// Creates an iterator for traversing the UTF-8 bytes.
            /// - `utf8.Iterator.Error` **_if the initialization failed._**
            pub fn iterator(self: Self) utf8.Iterator.Error!utf8.Iterator {
                return try utf8.Iterator.init(self.writtenSlice());
            }

        // └──────────────────────────────────────────────────────────────┘


        // ┌──────────────────────────── Utils ───────────────────────────┐

            /// Returns the length of the source.
            pub inline fn length(self: Self) usize {
                return self.writtenSlice().len;
            }

            /// Returns a slice representing the entire allocated memory range.
            pub fn allocatedSlice(self: Self) []u8 {
                return self.source.ptr[0..self.capacity];
            }

            /// Returns a slice containing only the written part.
            pub fn writtenSlice(self: Self) []const u8 {
                return if(self.source.len > 0 )self.source.ptr[0..self.source.len] else "";
            }

            /// Returns a copy of the `uString` instance.
            pub fn clone(self: Self, allocator: Allocator) AllocatorError!Self {
                var new_string : Self = .{};
                try new_string.ensureCapacity(allocator, self.capacity);
                Bytes.unsafeAppend(new_string.allocatedSlice(), self.writtenSlice(), 0);
                new_string.source.len = self.source.len;
                return new_string;
            }

            /// Reverses the order of the characters **_(considering unicode)_**.
            pub fn reverse(self: *Self, allocator: Allocator) AllocatorError!void {
                if (self.source.len == 0) return;
                var original_data = try self.clone(allocator);
                defer original_data.deinit(allocator);

                var utf8_iterator = utf8.Iterator.unsafeInit(original_data.writtenSlice());
                var i: usize = self.source.len;

                while (utf8_iterator.nextGraphemeCluster()) |gc| {
                    i -= gc.len;
                    @memcpy(self.allocatedSlice()[i..i + gc.len], gc);
                    if (i == 0) break; // to avoid underflow.
                }
            }

            /// Converts the `uString` to a `uString`, taking ownership of the memory.
            pub fn toManaged(self: *Self, allocator: Allocator) StringContainer.String {
                return .{ .source = self.source, .capacity = self.capacity, .allocator = allocator, .length = self.source.len };
            }

        // └──────────────────────────────────────────────────────────────┘


        // ┌───────────────────────── Internal ───────────────────────────┐

            /// If the current capacity is less than `new_capacity`, this function will
            /// modify the array so that it can hold exactly `new_capacity` source.
            /// Invalidates element pointers if additional memory is needed.
            fn ensureCapacity(self: *Self, allocator: Allocator, extra_capacity: usize) AllocatorError!void {
                const new_capacity = try StringContainer.addOrOom(self.source.len, extra_capacity);

                if (self.capacity >= new_capacity) return;

                // Here we avoid copying allocated but unused bytes by
                // attempting a resize in place, and falling back to allocating
                // a new buffer and doing our own copy. With a realloc() call,
                // the allocator implementation would pointlessly copy our
                // extra capacity. referance: std.ArrayListUnmanaged.
                const old_memory = self.allocatedSlice();
                if (allocator.resize(old_memory, new_capacity)) {
                    self.capacity = new_capacity;
                } else {
                    const new_memory = try allocator.alloc(u8, new_capacity);
                    @memcpy(new_memory[0..self.source.len], self.source);
                    allocator.free(old_memory);
                    self.source.ptr = new_memory.ptr;
                    self.capacity = new_memory.len;
                }
            }

        // └──────────────────────────────────────────────────────────────┘
    };

// ╚══════════════════════════════════════════════════════════════════════════════════╝