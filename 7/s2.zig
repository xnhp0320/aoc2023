const std = @import("std");
const fs = std.fs;
const print = std.debug.print;

const label = [_]u8{'J', '2', '3', '4', '5', '6', '7', '8', '9', 'T', 'Q', 'K', 'A'};

const Record = struct {
    hand : []u8,
    bid : usize,
};

fn cmp(_:void, a:u8, b:u8) bool {
    const ra = std.mem.indexOf(u8, &label, &[_]u8{a}).?;
    const rb = std.mem.indexOf(u8, &label, &[_]u8{b}).?;
    if (ra < rb) {
        return true;
    } else {
        return false;
    }
}

fn rank(hand: []u8) usize {
    var sorted:[5]u8 = undefined;
    var i:usize = 0;
    var sorted_size:usize = 0;
    var j_cnt:u8 = 0;

    while (i < 5) : ( i += 1) {
        if (hand[i] != 'J') {
            sorted[sorted_size] = hand[i];
            sorted_size += 1;
        } else {
            j_cnt += 1;
        }
    }

    if (sorted_size == 0) {
        return 6;
    }

    std.sort.block(u8, sorted[0..sorted_size], {}, cmp); 
    var r:[5]u8 = [_]u8{0} ** 5;

    i = 1;
    var j:usize = 0;
    r[j] = 1;

    while (i < sorted_size) : (i += 1) {
        if (sorted[i] == sorted[i-1]) {
            r[j] +=1;
        } else {
            j += 1;
            r[j] = 1;
        }
    }
    std.sort.block(u8, &r, {}, std.sort.desc(u8));
    r[0] += j_cnt;
    //print ("{d} {c}\n", .{r, hand});

    if (j == 0)
        return 6;

    if (j == 1) {
        if (r[0] == 4) {
            return 5;
        } else {
            return 4;
        }
    }

    if (j == 2) {
        if (r[0] == 3 and r[1] == 1)
            return 3;

        if (r[0] == 2 and r[1] == 2)
            return 2;

        unreachable;
    }

    if (j == 3) {
        return 1;
    }

    return 0;
}

fn handCmp(_: void, a: Record, b: Record) bool {
    const ra = rank(a.hand);
    const rb = rank(b.hand);
    if (ra < rb) {
        return true;
    } else if (ra > rb) {
        return false; 
    } else {
        var i:usize = 0;
        while (i < 5 ) : ( i += 1) {
            const rla = std.mem.indexOf(u8, &label, &[_]u8{a.hand[i]}).?;
            const rlb = std.mem.indexOf(u8, &label, &[_]u8{b.hand[i]}).?;
            if (rla < rlb) {
                return true;
            } else if (rla > rlb) {
                return false;
            }
        }
    }

    unreachable;
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const file = try fs.cwd().openFile("input", .{});
    defer file.close();

    const rdr = file.reader();

    var list = std.ArrayList(Record).init(allocator);
    defer list.deinit();

    while (try rdr.readUntilDelimiterOrEofAlloc(allocator, '\n', 4096)) |line| {
        defer allocator.free(line);
        var it = std.mem.split(u8, line, " ");

        const hand_str = it.next().?;
        const hand = try allocator.alloc(u8, hand_str.len);
        @memcpy(hand, hand_str);

        const bid = try std.fmt.parseInt(usize, it.next().?, 10);
        try list.append(Record{.hand = hand, .bid = bid});
    }

    const s = try list.toOwnedSlice();
    defer allocator.free(s);
    defer {
        for (s) |*r| {
            allocator.free(r.hand);
        }
    }
    
    std.sort.block(Record, s, {}, handCmp); 
    var bid:usize = 0;
    for (s, 1 .. ) |*r, i| {
        print ("{c} {}\n", .{ r.hand, r.bid});
        bid += r.bid * i; 
    }
    print ("{}\n", .{bid});
}

