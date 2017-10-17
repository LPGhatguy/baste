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
	Sane module system for Lua
</div>

<div>&nbsp;</div>

## Problem
Implementing relative require in vanilla Lua is insane, usually requiring pasting a pattern at the top of each file. It falls apart further when using `init.lua` files, requiring different patterns.

The `LUA_PATH` environment variable introduces another layer of configuration complexity and platform compatibility nightmare. Because of all this, you need [layers upon layers of hacks](http://leafo.net/guides/customizing-the-luarocks-tree.html) to make the module system convenient. Even when the module system is made convenient, it's hard to tell where the modules you're requesting are being loaded from!

Some tools try to work around this:
* [Penlight's `require_here`](http://stevedonovan.github.io/Penlight/api/libraries/pl.app.html#require_here)

## Solution?
*Baste* intends to be a replacement module system that:

* Distinguishes relative and absolute imports
* Works predictably, in any environment (including Windows)
* Requires no boilerplate for users

## License
Baste is available under the MIT license. See [LICENSE.md](LICENSE.md) for details.