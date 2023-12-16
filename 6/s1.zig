const std = @import("std");
const print = std.debug.print;


fn solve(t:usize, d:usize) usize {
    var w:usize = 0;
    for ( 1 .. t - 1 ) |holdtime| {
        const dis = (t - holdtime) * holdtime; 
        if (dis > d)
            w += 1;
    }

    return w;
}

pub fn main() !void {
    print("{}\n", .{solve(47, 207)});
    print("{}\n", .{solve(84, 1394)});
    print("{}\n", .{solve(74, 1209)});
    print("{}\n", .{solve(67, 1014)});
    const w = solve(47, 207) * solve(84, 1394) * solve(74, 1209) * solve(67, 1014);
    print("{}\n", .{w});
}
