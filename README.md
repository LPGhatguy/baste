<h1 align="center">Baste</h1>
<div align="center">
	<a href="https://travis-ci.org/LPGhatguy/baste">
		<img src="https://api.travis-ci.org/LPGhatguy/baste.svg?branch=master" />
	</a>
	<a href="https://coveralls.io/github/LPGhatguy/baste?branch=master">
		<img src="https://coveralls.io/repos/github/LPGhatguy/baste/badge.svg?branch=master" />
	</a>
</div>

<div align="center">
	Predictable module system for Lua
</div>

<div>&nbsp;</div>

## Problem
Implementing relative require in vanilla Lua is problematic, usually requiring pasting a pattern at the top of each file. It falls apart further when using `init.lua` files, requiring different patterns.

The `LUA_PATH` environment variable introduces another layer of configuration complexity and platform compatibility nightmare. Because of these issues, you need [layers upon layers of hacks](http://leafo.net/guides/customizing-the-luarocks-tree.html) to make the module system convenient. Even when the module system is made convenient, it's hard to tell where modules will be loaded from on any given system executing your code!

Some tools try to work around this insanity:
* LuaRock's default paths and setup
* [Penlight's `require_here`](http://stevedonovan.github.io/Penlight/api/libraries/pl.app.html#require_here)

## Solution
*Baste* is a module system that doesn't have these problems. It also:

* Has no dependencies
* Is simple to use, with no per-file boilerplate
* Can be used for libraries or applications without leaking (no globals by default!)
* Distinguishes relative and absolute imports
* Works predictably in any environment (including Windows!)
* Supports Lua 5.1, 5.2, 5.3, and LuaJIT 2.0+.

## Usage
Put `src/baste.lua` somewhere in your project where it can be loaded by conventional means.

Use `baste.import(path)` to load your first module. Any modules loaded by Baste will have access to a new function called `import` that functions the same way as `baste.import`.

Your root module might look like:
```lua
local baste = require("baste")

-- Load and run `src/main.lua`
baste.import("./src/main")
```

And then in `src/main.lua`, you can write code like:
```lua
local GameState = import("./GameState")
local Something = import("./Entities/Something")
```

## License
Baste is available under the MIT license. See [LICENSE.md](LICENSE.md) for details.