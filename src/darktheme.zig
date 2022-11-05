const std = @import("std");

const HKEY_CURRENT_USER = @intToPtr(std.os.windows.HKEY, @as(i64, 0x80000001));
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

pub fn isDark() bool {
    var bufSize: std.os.windows.DWORD = @sizeOf(std.os.windows.DWORD);
    var light: std.os.windows.DWORD = undefined;
    var hKey: std.os.windows.HKEY = undefined;
    _ = std.os.windows.advapi32.RegOpenKeyExW(HKEY_CURRENT_USER, std.unicode.utf8ToUtf16LeStringLiteral("Software\\Microsoft\\Windows\\CurrentVersion\\Themes\\Personalize"), 0, KEY_READ, &hKey);
    _ = RegQueryValueExW(hKey, std.unicode.utf8ToUtf16LeStringLiteral("SystemUsesLightTheme"), null, null, @ptrCast(*std.os.windows.BYTE, &light), &bufSize);

    return if (light == 0) true else false;
}

pub fn setDarkWindow(hwnd: std.os.windows.HWND) void {
    var dark: i32 = 1;
    _ = DwmSetWindowAttribute(hwnd, DWMWA_USE_IMMERSIVE_DARK_MODE, &dark, @sizeOf(i32));
}
