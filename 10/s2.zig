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

fn scan(m : *std.ArrayList([]u8), s: Pos, p: Pos, d: dir, path: *std.ArrayList(Pos)) !void {
    var i = p[0];
    var j = p[1];
    var md = d;
    var step:usize = 1;
    //print ("search {} {} {} {c}\n", .{i, j, md, m.items[i][j]});

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
            print ("step {}\n", .{ step});
            return;
        }

        try path.append(.{i, j});

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
        //print ("{} {} {} {c}\n", .{ i, j, md, m.items[i][j]});
        step += 1;
    }

}

fn cmp(_:void, a:Pos, b: Pos) bool {
    return a[1] < b[1]; 
}

fn do(m : *std.ArrayList([]u8)) !void {
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

    var path = std.ArrayList(Pos).init(allocator);
    try path.append(s);
    try scan(m, s, .{i+1, j}, .down, &path);
    print ("path is {}\n", .{path.items.len});

    var map = std.AutoHashMap(usize, std.ArrayList(Pos)).init(allocator); 
    for (path.items) |p| {
        var ret = try map.getOrPut(p[0]);
        if (!ret.found_existing) {
            ret.value_ptr.* = std.ArrayList(Pos).init(allocator);
        } 
        try ret.value_ptr.append(p);
    }

    var it = map.keyIterator();
    while (it.next()) |k| {
        std.sort.block(Pos, map.get(k.*).?.items, {}, cmp);
    }
    for (map.get(138).?.items) |p| {
        print ("{} {} {c}\n", .{ p[0], p[1], m.items[p[0]][p[1]] });
    }


    var area:usize = 0;
    i = 0;
    while (i < m.items.len): (i += 1) {
        if (map.get(i)) |ret| {
            j = ret.items[0][1] + 1;
            next: while (j < m.items[i].len) : (j += 1) {
                var idx:usize = ret.items.len;
                while (idx > 0) {
                    idx -= 1;
                    const p = ret.items[idx];
                    if (p[1] == j) {
                        continue :next;
                    }

                    if (j > p[1]) {
                        var cross:usize = 0;
                        var prev:?u8 = null; 

                        for (0 .. idx + 1) |x| {
                            const pj = ret.items[x][1];
                            if (m.items[i][pj] == '-') {
                                continue;
                            }

                            if (m.items[i][pj] == '|') {
                                cross += 1;
                                prev = null;
                                continue;
                            }

                            if (prev) |_| {
                                if (m.items[i][pj] == 'J') {
                                    if (prev.? == 'F') { 
                                        cross += 1;
                                    }
                                    if (prev.? == 'L') {
                                        cross += 2;
                                    }
                                } else if (m.items[i][pj] == '7') {
                                    if (prev.? == 'F') { 
                                        cross += 2;
                                    }
                                    if (prev.? == 'L') {
                                        cross += 1;
                                    }
                                }
                                prev = null;
                                continue;
                            }
                            prev = m.items[i][pj];
                        }
                        if (cross % 2 == 1) {
                            //print("{}\n", .{ i });
                            area += 1;
                        }
                        continue :next;
                    }
                }
            }
        }
    }

    print ("area is {}\n", .{ area });
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
    
    try do(&m);
}
