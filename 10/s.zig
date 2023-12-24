const std = @import("std");
const fs = std.fs;
const print = std.debug.print;
const Tuple = std.meta.Tuple;

var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
const allocator = arena.allocator();

const dir = enum {
    left,
    right,
    up,
    down,
};

const Pos = Tuple(&[_]type {usize} ** 2); 

fn scan(m : *std.ArrayList([]u8), s: Pos, p: Pos, d: dir) usize {
    var i = p[0];
    var j = p[1];
    var md = d;
    var step:usize = 1;
    print ("search {} {} {} {c}\n", .{i, j, md, m.items[i][j]});

    while (true) {
        if (i >= m.items.len)
            break;

        if (j >= m.items[0].len)
            break;

        if (i == std.math.maxInt(usize))
            break;

        if (j == std.math.maxInt(usize))
            break;

        if (i == s[0] and j == s[1]) {
            return step;
        }

        if (md == .left) {
            switch (m.items[i][j]) {
                'L'  => {
                    i = i -% 1;
                    md = .up;

                },
                '-' => {
                    j = j -% 1;
                },
                'F' => {
                    i = i + 1;
                    md = .down;
                },
                else => {
                    break;
                },
            }
        } else if (md == .right) {
            switch (m.items[i][j]) {
                'J'  => {
                    i = i -% 1;
                    md = .up;
                },
                '-' => {
                    j = j + 1;
                },
                '7' => {
                    i = i + 1;
                    md = .down;
                },
                else => {
                    break;
                }
            }
        } else if (md == .up) {
            switch (m.items[i][j]) {
                '|'  => {
                    i = i -% 1;
                },
                'F' => {
                    j = j + 1;
                    md = .right;
                },
                '7' => {
                    j = j -% 1; 
                    md = .left;
                },
                else => {
                    break;
                }
            }
        } else if (md == .down) {
            switch (m.items[i][j]) {
                '|' => {
                    i = i + 1;
                },
                'J' => {
                    j = j -% 1;
                    md = .left;
                },
                'L' => {
                    j = j + 1;
                    md = .right;
                },
                else => { break; }
            }
        }
        print ("{} {} {} {c}\n", .{ i, j, md, m.items[i][j]});
        step += 1;
    }

    return 0;
}


fn do(m : *std.ArrayList([]u8)) usize {
    var i: usize = 0; 
    var j: usize = 0; 
    
    outer: while (i < m.items.len) : (i += 1) {
        j = 0;
        while (j < m.items[i].len) : (j += 1) {
            if (m.items[i][j] == 'S') {
                break :outer;
            }
        }
    }

    const s: Pos = .{i, j};
    print ("{}\n", .{ s });

    var v:usize = 0;
    v = @max(v, scan(m, s, .{i+1, j}, .down));
    v = @max(v, scan(m, s, .{i, j+1}, .right));
    v = @max(v, scan(m, s, .{i-%1, j}, .up));
    v = @max(v, scan(m, s, .{i, j-%1}, .left));

    return v;
}

pub fn main() !void {
    defer arena.deinit();

    const file = try fs.cwd().openFile("input", .{});
    defer file.close();

    const rdr = file.reader();
    var m = std.ArrayList([]u8).init(allocator);

    while (try rdr.readUntilDelimiterOrEofAlloc(allocator, '\n', 4096)) |line| {
        try m.append(line);
    }
    
    const x = do(&m);
    print ("{}\n", .{ x });
}
