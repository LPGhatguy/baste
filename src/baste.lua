local path = {}

--[[
	Normalize the given path by removing unnecessary slashes, `.`, and `..`.
]]
function path.normalize(input)
	return (input
		-- Normalize \ and / to /
		:gsub("[/\\]+", "/")
		-- Remove trailing slashes
		:gsub("/+$", "")
		-- Handle .
		:gsub("^%./", "")
		:gsub("/%.$", "/")
		:gsub("/%./", "/")
		-- Handle ..
		:gsub("[^/]+/%.%./", ""))
end

--[[
	Returns everything except the last node in the path. This will be the folder
	containing the input path.

	When used in combination with path.leaf and path.join, it's possible to
	reconstruct a path with the same semantic meaning as the original input:

	`input` vs `path.join(path.withoutLeaf(input), path.leaf(input))`
]]
function path.withoutLeaf(input)
	input = path.normalize(input)

	return (input:match("^(.+)/[^/]+$")) or "."
end

--[[
	Get the file extension of the given path, or nil if there isn't one.
]]
function path.extension(input)
	return (input:match("%.([^./]-)$"))
end

--[[
	Joins together the given list of path fragments.

	Only the first path fragment is allowed to be an absolute path, but this
	isn't verified.
]]
function path.join(...)
	return path.normalize(table.concat({...}, "/"))
end

-- Handle environment changes between 5.1 and 5.2+
-- Can we feature test this instead of version checking?
local loadWithEnv
if _VERSION == "Lua 5.1" then
	loadWithEnv = function(filename, env)
		local chunk, err = loadfile(filename)

		if not chunk then
			return false, err
		end

		setfenv(chunk, env)

		return chunk
	end
else
	loadWithEnv = function(filename, env)
		return loadfile(filename, "bt", env)
	end
end

--[[
	Determines if the error message hints at not being able to open a file.
	It should hold for Lua 5.1, 5.2, 5.3, and LuaJIT 2.0 and 5.1.

	This check is based on https://www.lua.org/source/5.1/lauxlib.c.html

	This leads me to believe that loadfile should be replaced with loadstring
	and correct chunk naming.
]]
local function isOpenError(err)
	return err:find("^cannot open") or err:find("^cannot read") or err:find("^cannot reopen")
end

local loadedModules = {}
local moduleResults = {}

--[[
	Because of tail-call optimization, trying to get the file location of a
	chunk whose contents are just a return statement fails.

	Using an 'import function factory' solves thie problem by injecting the
	file's path into the generated function. This also reduces the number of
	debug library calls.
]]
local function makeImport(current)
	return function(modulePath)
		if type(modulePath) ~= "string" then
			local message = "Bad argument #1 to import, expected string but got %s"
			error(string.format(message, type(modulePath)), 2)
		end

		current = current or debug.getinfo(2, "S").source:sub(2)

		-- Relative import!
		if modulePath:sub(1, 1) == "." then
			local currentDirectory = path.withoutLeaf(current)
			local relativeModulePath = path.join(currentDirectory, modulePath)

			local pathsToTry = {relativeModulePath}

			if not path.extension(modulePath) then
				table.insert(pathsToTry, relativeModulePath .. ".lua")
				table.insert(pathsToTry, path.join(relativeModulePath, "init.lua"))
			end

			-- TODO: Plug-in point for adding additional paths to try

			-- Have we loaded this module before?
			for _, target in ipairs(pathsToTry) do
				if loadedModules[target] then
					return moduleResults[target]
				end
			end

			-- Let's try to load from these paths!
			for _, target in ipairs(pathsToTry) do
				-- Hand-craft an environment for the module we're loading
				-- The module won't be able to iterate over globals!
				local env = setmetatable({
					import = makeImport(target),
				}, {
					__index = _G,
					__newindex = _G,
				})

				-- TODO: Plug-in point for adding extra loaders

				local chunk, err = loadWithEnv(target, env)

				if chunk then
					loadedModules[target] = true

					local result = chunk()

					moduleResults[target] = result

					return result
				else
					if not isOpenError(err) then
						error(err, 2)
					end
				end
			end

			-- We didn't find any modules.
			local message = string.format("Couldn't import %q, tried:\n\t%s",
				modulePath,
				table.concat(pathsToTry, "\n\t")
			)

			error(message, 2)
		else
			-- TODO: check `baste_modules` folder (or similar)
			return require(modulePath)
		end
	end
end

return {
	import = makeImport(),
}