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

Compare the default `LUA_PATH`/`package.path` across Lua versions:

| Lua Version | `package.path`                        |
|:----------- |:------------------------------------- |
| 5.1         | `./?.lua;[system-paths]`              |
| 5.2         | `[system-paths];./?.lua`              |
| 5.3         | `[system-paths];./?.lua;./?/init.lua` |
| LuaJIT      | `./?.lua;[system-paths]`              |
| LÖVE        | `./?.lua;./?/init.lua;[system-paths]` |

Creating a package that's compatible with all these is a headache!

Furthermore, if you want to make a package that users can drop into their codebase wherever, you have to resort to crazy pattern matching, like:

```lua
local modules  = (...):gsub('%.[^%.]+$', '') .. "."
local utils    = require(modules .. "utils")
```
(taken from [here](https://github.com/excessive/cpml/blob/e3cafd6c2fc46fbc4a52763e8662226301fbfacf/modules/color.lua#L4))

Instead of what you actually want to write:

```lua
local utils = import("./utlis")
```

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
* Broad support:
	* Lua 5.1, 5.2, 5.3
	* LuaJIT 2.0+
	* LÖVE 0.10.0+

## Usage
Put `src/baste.lua` somewhere in your project and load it using `require`.

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