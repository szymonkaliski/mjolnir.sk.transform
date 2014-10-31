# mjolnir.sk.transform

Animated window transformations for (Mjolnir)[https://github.com/sdegutis/mjolnir], originall code/idea from [yozlet's pull request](https://github.com/sdegutis/mjolnir/issues/483).

![](/assets/demo.gif)

## Installation

	luarocks  install mjolnir.sk.transform

## Usage

	```lua

	local transform = require "mjolnir.sk.transform"

	hotkey.bind({"cmd","alt"}, "S", function()
		local win = window.focusedwindow()
		local frame = win:frame()
		local animation_time = 0.2

		frame.x = frame.x - 20
		frame.w = frame.w + 40

		transform:setframe(win, frame, animation_time)
	end)

	```

## Functions

```lua
transform:setframe(win, frame, time)
```
Animates win to frame in time. Time is optional, and if not set will default to 0.2.

