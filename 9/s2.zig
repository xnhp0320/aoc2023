const std = @import("std");
const fs = std.fs;
const print = std.debug.print;

var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
const allocator = arena.allocator();

fn get_prev(l: *std.ArrayList(i32)) !i32 {
    var ln = std.ArrayList(i32).init(allocator);
    var i:usize = 1;
    var end = true;
    const p:i32 = l.items[1] - l.items[0];

    while (i < l.items.len) : ( i += 1) {
        try ln.append(l.items[i] - l.items[i-1]);
        if (end) {
            if (p != l.items[i] - l.items[i-1]) {
                end = false;
            }
        }
    }

    if (!end) {
        const x = try get_prev(&ln);
        return l.items[0] - x;
    } else {
        return l.items[0] - p;
    }
}

pub fn main() !void {
    defer arena.deinit();

    const file = try fs.cwd().openFile("input", .{});
    defer file.close();

    const rdr = file.reader();
    var sum:isize = 0; 

    while (try rdr.readUntilDelimiterOrEofAlloc(allocator, '\n', 4096)) |line| {
        var it = std.mem.split(u8, line, " ");
        var l = std.ArrayList(i32).init(allocator);
        while (it.next()) |v| {
            try l.append(try std.fmt.parseInt(i32, v, 10));
        }
        //for (l.items) |v| {
        //    print ("{}\n", .{v});
        //}
        sum += try get_prev(&l); 
    }
    print ("{}\n", .{ sum });
}
