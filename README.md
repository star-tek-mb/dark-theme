# Overview

Query system dark/light theme preference.

# Platform

 - [x] Windows
 - [x] Linux
 - [ ] MacOS

# API

```zig
const darktheme = @import("darktheme.zig");

// get bool value of system preference
var isDark = darktheme.isDark();

// windows only
// apply dark borders to window
darktheme.setDarkWindow(hwnd);
```
