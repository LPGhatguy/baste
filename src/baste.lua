local path = {}

function path.normalize(input)
	return input
		:gsub("[/\\]+", "/")
		:gsub("/+$", "")
end

function path.leaf(input)
	input = path.normalize(input)

	return input:match("[^/]+$")
end

function path.withoutLeaf(input)
	input = path.normalize(input)

	return input:match("^(.+)/[^/]+$") or "."
end

function path.join(...)
	return path.normalize(table.concat({...}, "/"))
end

-- This will be useful for 5.2+ compatibility!
local function loadWithEnv(filename, env)
	local chunk, err = loadfile(filename)

	if not chunk then
		return false, err
	end

	setfenv(chunk, env)

	return chunk
end

local function makeEnvironment()
	return setmetatable({}, {
		__index = _G,
		__newindex = _G,
	})
end

--[[
	Because of tail-call optimization, trying to get the file location of a
	chunk whose contents are just a return statement fails.

	Using an 'import function factory' solves thie problem by injecting the
	file's path into the generated function. This also reduces the number of
	debug library calls.
]]
local function makeImport(current)
	return function(module)
		current = current or debug.getinfo(2, "S").source:sub(2)

		if module:sub(1, 1) == "." then
			local dir = path.withoutLeaf(current)

			-- '../' and './' are okay here
			local target = path.join(dir, module .. ".lua")

			local env = makeEnvironment()
			env.import = makeImport(target)

			local chunk, err = loadWithEnv(target, env)

			if not chunk then
				error(err, 2)
			end

			return chunk()
		else
			-- wow, so intense
			return require(module)
		end
	end
end

return {
	import = makeImport(),
}