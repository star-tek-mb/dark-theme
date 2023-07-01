const std = @import("std");
const builtin = @import("builtin");

const HKEY_CURRENT_USER = @as(std.os.windows.HKEY, @ptrFromInt(@as(i64, 0x80000001)));
const KEY_QUERY_VALUE = 0x0001;
const KEY_ENUMERATE_SUB_KEYS = 0x0008;
const KEY_NOTIFY = 0x0010;
const KEY_READ = KEY_QUERY_VALUE | KEY_ENUMERATE_SUB_KEYS | KEY_NOTIFY;
const DWMWA_USE_IMMERSIVE_DARK_MODE = 20;

extern "advapi32" fn RegQueryValueExW(
    hKey: std.os.windows.HKEY,
    lpValueName: std.os.windows.LPCWSTR,
    lpReserved: ?*std.os.windows.DWORD,
    lpType: ?*std.os.windows.DWORD,
    lpData: ?*std.os.windows.BYTE,
    lpcbData: ?*std.os.windows.DWORD,
) callconv(std.os.windows.WINAPI) std.os.windows.LSTATUS;

extern "dwmapi" fn DwmSetWindowAttribute(
    hWnd: std.os.windows.HWND,
    dwAttribute: std.os.windows.DWORD,
    pvAttribute: *const anyopaque,
    cbAttribute: std.os.windows.DWORD,
) callconv(std.os.windows.WINAPI) std.os.windows.HRESULT;

pub fn isDark() !bool {
    switch (builtin.os.tag) {
        .windows => {
            var bufSize: std.os.windows.DWORD = @sizeOf(std.os.windows.DWORD);
            var light: std.os.windows.DWORD = undefined;
            var hKey: std.os.windows.HKEY = undefined;
            var status = std.os.windows.advapi32.RegOpenKeyExW(HKEY_CURRENT_USER, std.unicode.utf8ToUtf16LeStringLiteral("Software\\Microsoft\\Windows\\CurrentVersion\\Themes\\Personalize"), 0, KEY_READ, &hKey);
            if (status != 0) {
                return error.QueryError;
            }
            status = RegQueryValueExW(hKey, std.unicode.utf8ToUtf16LeStringLiteral("SystemUsesLightTheme"), null, null, @as(*std.os.windows.BYTE, @ptrCast(&light)), &bufSize);
            if (status != 0) {
                return error.QueryError;
            }

            return if (light == 0) true else false;
        },
        .linux => {
            var buffer: [4096]u8 = undefined;
            var fba = std.heap.FixedBufferAllocator.init(&buffer);
            var allocator = fba.allocator();
            var exec = std.ChildProcess.exec(.{
                .allocator = allocator,
                .argv = &.{
                    "sh",
                    "-c",
                    "dbus-send --print-reply=literal --reply-timeout=1000 --dest=org.freedesktop.portal.Desktop /org/freedesktop/portal/desktop org.freedesktop.portal.Settings.Read string:'org.freedesktop.appearance' string:'color-scheme'",
                },
                .max_output_bytes = 4096,
            }) catch return error.QueryError;
            defer {
                allocator.free(exec.stdout);
                allocator.free(exec.stderr);
            }
            if (exec.stdout.len > 0) {
                // correct output is
                //    variant       variant          uint32 1
                // parse last character, skip '\n' character
                var val = exec.stdout[exec.stdout.len - 2] - '0';
                if (val == 1) {
                    return true;
                } else {
                    return false;
                }
            } else {
                return error.QueryError;
            }
        },
        .macos => {
            var buffer: [4096]u8 = undefined;
            var fba = std.heap.FixedBufferAllocator.init(&buffer);
            var allocator = fba.allocator();
            var exec = std.ChildProcess.exec(.{
                .allocator = allocator,
                .argv = &.{
                    "defaults",
                    "read",
                    "-g",
                    "AppleInterfaceStyle",
                },
                .max_output_bytes = 4096,
            }) catch return error.QueryError;
            defer {
                allocator.free(exec.stdout);
                allocator.free(exec.stderr);
            }
            if (exec.stdout.len >= 4 and std.mem.eql(u8, "Dark", exec.stdout[0..4])) {
                return true;
            } else {
                return false;
            }
        },
        else => @compileError("unsupported"),
    }
}

pub fn setDarkWindow(hwnd: std.os.windows.HWND) void {
    var dark: i32 = 1;
    _ = DwmSetWindowAttribute(hwnd, DWMWA_USE_IMMERSIVE_DARK_MODE, &dark, @sizeOf(i32));
}
