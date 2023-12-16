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
    print("{}\n", .{solve(47847467, 207139412091014)});
}
