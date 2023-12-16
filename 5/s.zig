const std = @import("std");
const fs = std.fs;
const print = std.debug.print;

const RangeMap = struct {
    dest: usize,
    src: usize,
    range: usize,
};

const MapType = enum {
    seed,
    seed2soil,
    soil2fertilizer,
    fertilizer2water,
    water2light,
    light2temperature,
    temperature2humidity,
    humidity2location,
};

fn strlen(str:[]const u8) usize {
    return std.mem.sliceTo(str, 0).len;
}

fn beginWith(str:[]const u8, needle:[]const u8) bool {
    return (str.len >= needle.len) and
            std.mem.eql(u8, str[0 .. needle.len], needle);
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const file = try fs.cwd().openFile("input", .{});
    defer file.close();

    const rdr = file.reader();
    var line_no: usize = 0;

    var seeds = std.ArrayList(usize).init(allocator);
    defer seeds.deinit();

    var seed2soilmap = std.ArrayList(RangeMap).init(allocator);
    defer seed2soilmap.deinit();

    var soil2fertilizermap = std.ArrayList(RangeMap).init(allocator);
    defer soil2fertilizermap.deinit();

    var fertilizer2watermap = std.ArrayList(RangeMap).init(allocator);
    defer fertilizer2watermap.deinit();

    var water2lightmap = std.ArrayList(RangeMap).init(allocator);
    defer water2lightmap.deinit();

    var light2temperaturemap = std.ArrayList(RangeMap).init(allocator);
    defer light2temperaturemap.deinit();

    var temperature2humiditymap = std.ArrayList(RangeMap).init(allocator);
    defer temperature2humiditymap.deinit();

    var humidity2locationmap = std.ArrayList(RangeMap).init(allocator);
    defer humidity2locationmap.deinit();

    var map_type:MapType = undefined;
    var list: *std.ArrayList(RangeMap) = undefined;

    while (try rdr.readUntilDelimiterOrEofAlloc(allocator, '\n', 4096)) |line| {
        defer allocator.free(line);
        line_no += 1;

        if (line.len > 0) {
            if (beginWith(line, "seeds: ")) {
                map_type = .seed;
            }

            if (beginWith(line, "seed-to-soil map:")) {
                map_type = .seed2soil;
                list = &seed2soilmap;
                continue;
            }

            if (beginWith(line, "soil-to-fertilizer map:")) {
                map_type = .soil2fertilizer;
                list = &soil2fertilizermap;
                continue;
            }

            if (beginWith(line, "fertilizer-to-water map:")) {
                map_type = .fertilizer2water;
                list = &fertilizer2watermap;
                continue;
            }

            if (beginWith(line, "water-to-light map:")) {
                map_type = .water2light;
                list = &water2lightmap;
                continue;
            }

            if (beginWith(line, "light-to-temperature map:")) {
                map_type = .light2temperature;
                list = &light2temperaturemap;
                continue;
            }

            if (beginWith(line, "temperature-to-humidity map:")) {
                map_type = .temperature2humidity;
                list = &temperature2humiditymap;
                continue;
            }

            if (beginWith(line, "humidity-to-location map:")) {
                map_type = .humidity2location;
                list = &humidity2locationmap;
                continue;
            }
        } else {
            continue;
        }

        if (map_type == .seed) {
            var it = std.mem.split(u8, line[strlen("seeds: ") .. ], " ");
            while (it.next()) |seed| {
                try seeds.append((std.fmt.parseInt(usize, seed, 10) catch unreachable));
            }

            //for (seeds.items) |value| {
            //    print("seed {d}\n", .{value});
            //}
        } else {
            //print("{} {s}\n", .{map_type, line});
            var it = std.mem.split(u8, line, " ");
            const map = RangeMap{ .dest = try std.fmt.parseInt(usize, it.next().?, 10),
                                  .src = try std.fmt.parseInt(usize, it.next().?, 10),
                                  .range = try std.fmt.parseInt(usize, it.next().?, 10) };

            try list.append(map);
        }
    }

    var lowest:usize = std.math.maxInt(usize);

    for (seeds.items) |seed| {
        var mapped:usize = seed;
        mapped = mapTo(mapped, &seed2soilmap);
        mapped = mapTo(mapped, &soil2fertilizermap);
        mapped = mapTo(mapped, &fertilizer2watermap);
        mapped = mapTo(mapped, &water2lightmap);
        mapped = mapTo(mapped, &light2temperaturemap);
        mapped = mapTo(mapped, &temperature2humiditymap);
        mapped = mapTo(mapped, &humidity2locationmap);
        print("seed {} location {d}\n", .{seed, mapped});
        if (mapped < lowest)
            lowest = mapped;
    }

    print ("lowest {d}\n", .{lowest});
}

fn mapTo(src: usize, map: *std.ArrayList(RangeMap)) usize {
    for (map.items) |*range| {
        if (src >= range.src and src <= range.src + range.range - 1) {
            return src - range.src + range.dest;
        }
    }

    return src;
}
