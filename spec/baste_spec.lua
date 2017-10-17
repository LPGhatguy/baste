local baste = require("baste")

describe("Baste", function()
	it("is a module", function()
		assert.is.table(baste)
	end)

	it("should be able to load relative modules", function()
		local foo = baste.import("./foo")

		assert.equal(foo, "bar!")
	end)

	it("should be able to load absolute modules", function()
		local io = baste.import("io")

		assert.not_nil(io)
	end)
end)