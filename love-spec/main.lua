-- Paths are kind of messed up here right now.
-- Run this from the parent directory as 'love love-spec'

local baste = require("src.baste")

assert(baste.import("./love-spec/test") == "hello, world!")

os.exit(0)