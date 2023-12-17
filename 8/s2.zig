const std = @import("std");
const fs = std.fs;
const print = std.debug.print;

const Road = struct {
    left: []u8,
    right : []u8,
};

fn parseRoad(allocator: std.mem.Allocator, lr: []const u8) !Road {
    var it = std.mem.split(u8, lr, ", ");
    var left = it.next().?;
    left = left[1..left.len];

    var right = it.next().?;
    right = right[0 .. right.len - 1];

    return .{ .left = try allocator.dupe(u8, left),
              .right = try allocator.dupe(u8, right) };
}

fn travel(map: *std.StringHashMap(Road), ins: []const u8,
          entries: [][]const u8, allocator: std.mem.Allocator) !void {

    print ("{d} {s}\n", .{entries.len, entries});
    var value = std.ArrayList(usize).init(allocator);

    for (entries) |*k| {
        var s:usize = 0;
        var i:usize = 0;

        while (true) {
            s += 1;
            const r = map.get(k.*).?;
            if (ins[i] == 'L') {
                k.* = r.left;
            } else {
                k.* = r.right;
            }
            //print ("{c} {c}\n", .{ins[i], k.*}); 

            if (std.mem.endsWith(u8, k.*, "Z")) {
                try value.append(s);
                break;
            }

            i += 1;
            i %= ins.len;
        }
    }
    const r = try value.toOwnedSlice();
    var i:usize = 1;
    var x:usize = r[0];
    //var y:usize = r[0];

    print ("{any}\n", .{r});
    while( i < r.len) : ( i += 1) {  
        x = std.math.gcd(x, r[i]);
    }
    print ("{d}\n", .{x});

    for (r) |v| {
        print ("{d}\n", .{ v / x });
    }
}

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    var allocator = arena.allocator();

    const file = try fs.cwd().openFile("input", .{});
    defer file.close();

    const rdr = file.reader();
    var ins_read = false;
    var ins:[]const u8 = undefined;

    var map = std.StringHashMap(Road).init(allocator);
    var entries = std.ArrayList([]const u8).init(allocator);

    while (try rdr.readUntilDelimiterOrEofAlloc(allocator, '\n', 4096)) |line| {

        if (line.len == 0)
            continue;

        if (!ins_read) {
            ins = try allocator.dupe(u8, line);
            ins_read = true;
        } else {
            var it = std.mem.split(u8, line, " = ");
            const node = it.next().?;
            const lr = it.next().?;
            const n = try allocator.dupe(u8, node);
            try map.put(n, try parseRoad(allocator, lr));

            if (std.mem.endsWith(u8, n, "A")) {
                try entries.append(n);
            }
        }
    }
    print ("{c} {d}\n", .{ ins, ins.len });

    //var it = map.iterator();
    //while (it.next()) |kv| {
    //    print ("{s} {c} {c}\n", .{ kv.key_ptr.*, kv.value_ptr.left, kv.value_ptr.right });
    //}

    try travel(&map, ins, try entries.toOwnedSlice(), allocator);
}
