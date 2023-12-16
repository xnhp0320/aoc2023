const std = @import("std");
const fs = std.fs;
const print = std.debug.print;

const RangeMap = struct {
    dest: usize,
    src: usize,
    range: usize,
};

const Range = struct {
    begin: usize,
    len : usize,
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
    //print("{}\n", .{std.math.maxInt(usize)});
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const file = try fs.cwd().openFile("input", .{});
    defer file.close();

    const rdr = file.reader();
    var line_no: usize = 0;

    var seeds = std.ArrayList(Range).init(allocator);
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
            while (it.rest().len > 0) {
                try seeds.append(Range{ .begin = std.fmt.parseInt(usize, it.next().?, 10) catch unreachable,
                                        .len = std.fmt.parseInt(usize, it.next().?, 10) catch unreachable});
            }

            //for (seeds.items) |*value| {
            //    print("seed {}\n", .{value.*});
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

    const seed2soil_slice = try seed2soilmap.toOwnedSlice();
    std.sort.block(RangeMap, seed2soil_slice, {}, cmp); 
    defer allocator.free(seed2soil_slice);

    const soil2fertilizer_slice = try soil2fertilizermap.toOwnedSlice();
    std.sort.block(RangeMap, soil2fertilizer_slice, {}, cmp); 
    defer allocator.free(soil2fertilizer_slice);

    const fertilizer2water_slice = try fertilizer2watermap.toOwnedSlice();
    std.sort.block(RangeMap, fertilizer2water_slice, {}, cmp); 
    defer allocator.free(fertilizer2water_slice);

    const water2light_slice = try water2lightmap.toOwnedSlice();
    std.sort.block(RangeMap, water2light_slice, {}, cmp); 
    defer allocator.free(water2light_slice);

    const light2temperature_slice = try light2temperaturemap.toOwnedSlice();
    std.sort.block(RangeMap, light2temperature_slice, {}, cmp); 
    defer allocator.free(light2temperature_slice);

    const temperature2humidity_slice = try temperature2humiditymap.toOwnedSlice(); 
    std.sort.block(RangeMap, temperature2humidity_slice, {}, cmp); 
    defer allocator.free(temperature2humidity_slice);

    const humidity2location_slice = try humidity2locationmap.toOwnedSlice();
    std.sort.block(RangeMap, humidity2location_slice, {}, cmp); 
    defer allocator.free(humidity2location_slice);


    for (seeds.items) |*r| {
        var scan = r.begin;
        while (scan <= r.begin + r.len - 1)  {
            var mapped = scan;
            var skip = r.len - (scan - r.begin);
            print("skip init is {d}\n", .{skip});

            mapped = mapTo(mapped, seed2soil_slice, &skip);
            mapped = mapTo(mapped, soil2fertilizer_slice, &skip);
            mapped = mapTo(mapped, fertilizer2water_slice, &skip);
            mapped = mapTo(mapped, water2light_slice, &skip);
            mapped = mapTo(mapped, light2temperature_slice, &skip);
            mapped = mapTo(mapped, temperature2humidity_slice, &skip);
            mapped = mapTo(mapped, humidity2location_slice, &skip);
            print("scan {} location {d} skip {d}\n", .{scan, mapped, skip});

            if (mapped < lowest)
                lowest = mapped;
            scan += skip;
        }
        print("seed {} location {d}\n", .{r, lowest});
    }

    print ("lowest {d}\n", .{lowest});
}

fn cmp(_ : void, a: RangeMap, b: RangeMap) bool {
    if (a.src < b.src) {
        return true;
    } else {
        return false;
    }
}

fn mapTo(src: usize, map: []RangeMap, skip: *usize) usize {
    var i:usize = 0;
    while (i < map.len) : ( i += 1 ) {
        const range = &map[i];
        if (src > range.src + range.range - 1) {
            continue;
        }

        if (src < range.src) {
            const skip_range = range.src - src;
            skip.* = if (skip_range > skip.*) skip.* else skip_range;
            return src;
        }

        if (src >= range.src and src <= range.src + range.range - 1) {
            const skip_range = range.src + range.range - src;
            skip.* = if (skip_range > skip.*) skip.* else skip_range;
            //print ("skip {d} range {}\n", .{skip.*, range});
            return src - range.src + range.dest;
        }
    }
    return src;
}
