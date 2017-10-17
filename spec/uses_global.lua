local sum = 0
local values = {1, 2, 3, 4}

for _, value in ipairs(values) do
	sum = sum + math.sin(value)
end

return sum