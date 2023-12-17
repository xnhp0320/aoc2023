const std = @import("std");
const fs = std.fs;
const print = std.debug.print;

const Road = struct {
    left: []u8,
    right : []u8,
};

fn parseRoad(allocator: std.mem.Allocator, lr: []const u8) Road {
    var it = std.mem.split(u8, lr, ", ");
    var left = it.next().?;
    left = left[1..left.len];

    var right = it.next().?;
    right = right[0 .. right.len - 1];

    return .{ .left = allocator.dupe(u8, left) catch unreachable,
              .right = allocator.dupe(u8, right) catch unreachable};
}

fn travel(map: *std.StringHashMap(Road), ins: []const u8, entry_point: []const u8) usize {
    var i:usize = 0;
    var s:usize = 0;

    var k = &entry_point;

    while (true) {
        s += 1;
        const r = map.get(k.*);
        if (r != null) {
            if (ins[i] == 'L') {
                k = &r.?.left;
            } else {
                k = &r.?.right;
            }
        }
        print ("{c} {c}\n", .{ins[i], k.*}); 

        if (std.mem.eql(u8, k.*, "ZZZ")) {
            break;
        }
        i += 1;
        i %= ins.len;
    }

    return s;
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const file = try fs.cwd().openFile("input", .{});
    defer file.close();

    const rdr = file.reader();
    var ins_read = false;
    var entry_point: []const u8 = undefined;
    defer allocator.free(entry_point);
    var ins:[]const u8 = undefined;
    defer allocator.free(ins);

    var map = std.StringHashMap(Road).init(allocator);
    defer map.deinit();
    defer {
        var it = map.iterator();
        while (it.next()) |kv| {
            const road = kv.value_ptr;
            allocator.free(road.left);
            allocator.free(road.right);
            allocator.free(kv.key_ptr.*);
        }
    }

    while (try rdr.readUntilDelimiterOrEofAlloc(allocator, '\n', 4096)) |line| {
        defer allocator.free(line);

        if (line.len == 0)
            continue;

        if (!ins_read) {
            ins = try allocator.dupe(u8, line);
            ins_read = true;
        } else {
            var it = std.mem.split(u8, line, " = ");
            const node = it.next().?;
            const lr = it.next().?;
            if (entry_point.ptr == undefined) {
                entry_point = allocator.dupe(u8, node) catch unreachable;
            }
            try map.put(allocator.dupe(u8, node) catch unreachable, parseRoad(allocator, lr));
        }
    }
    print ("{c} {d}\n", .{ ins, ins.len });
    print ("{s}\n", .{ entry_point });

    //var it = map.iterator();
    //while (it.next()) |kv| {
    //    print ("{s} {c} {c}\n", .{ kv.key_ptr.*, kv.value_ptr.left, kv.value_ptr.right });
    //}

    print ("{d}\n", .{travel(&map, ins, entry_point)});
}
