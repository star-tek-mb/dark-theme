const std = @import("std");
const darktheme = @import("darktheme.zig");

pub fn main() !void {
    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    try stdout.print("Dark theme preference is {}\n", .{darktheme.isDark()});

    try bw.flush(); // don't forget to flush!
}
