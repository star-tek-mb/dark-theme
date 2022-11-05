# Overview

Query system dark/light theme preference.

# Platform

 - [x] Windows (tested)
 - [x] Linux (tested)
 - [x] MacOS (tested)

# API

```zig
const darktheme = @import("darktheme.zig");

// get bool value of system preference
var isDark = darktheme.isDark();

// windows only
// apply dark borders to window
darktheme.setDarkWindow(hwnd);
```

# Credits

Thanks to [cryptocode](https://github.com/cryptocode) for testing out MacOS code
