local baste = require("baste")

describe("Baste", function()
	it("is a module", function()
		assert.is.table(baste)
	end)

	it("should be able to load relative modules", function()
		local simple = baste.import("./simple")

		assert.equal(simple, "foo")
	end)

	it("should load relative modules with explicit file extensions", function()
		local simple = baste.import("./simple.lua")

		assert.equal(simple, "foo")
	end)

	it("should load modules in folders", function()
		local folder_module = baste.import("./folder_module")

		assert.equal(folder_module.bar, "bar")
	end)

	it("should cache and normalize module names", function()
		-- Look at all these ways to refer to the same module!
		local a = baste.import("./object")
		local b = baste.import("./object.lua")
		local c = baste.import("../import/object")
		local d = baste.import("../import/object.lua")

		assert.equal(a, b)
		assert.equal(b, c)
		assert.equal(c, d)
	end)

	it("should be able to load absolute modules", function()
		local io = baste.import("io")

		assert.not_nil(io)
	end)

	it("should give access to globals", function()
		local uses_global = baste.import("./uses_global")

		assert.is.number(uses_global)
	end)

	it("should propagate nested imports correctly", function()
		local chain_first = baste.import("./chain_first")

		assert.is.table(chain_first)
		assert.equal(chain_first.value, "bar")
	end)

	it("should throw errors with malformed invocation", function()
		assert.has.errors(function()
			baste.import()
		end)

		assert.has.errors(function()
			baste.import(5)
		end)

		assert.has.errors(function()
			baste:import()
		end)

		assert.has.errors(function()
			baste:import("./foo")
		end)
	end)

	it("should throw errors if no files were found", function()
		assert.has.errors(function()
			baste.import("./nope this does not exist sorry")
		end)

		assert.has.errors(function()
			baste.import("./another_folder")
		end)
	end)

	it("should propagate errors from module loading", function()
		assert.has.errors(function()
			baste.import("./throws_error")
		end)

		assert.has.errors(function()
			baste.import("./malformed")
		end)
	end)
end)