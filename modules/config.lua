--[[
	config.lua
		Adds module configs to interface panels
]]

local bollo = LibStub("AceAddon-3.0"):GetAddon("Bollo")
local conf = bollo:NewModule("Config", "AceConsole-3.0")

local optGet = function(info)
	local key = info[#info]
	return bollo.db.profile[key]
end

local defaults
local InitCore = function()
	if not defaults then
		defaults = {
			type = "group",
			name = "Bollo",
			args = {
				general = {
					order = 1,
					type = "group",
					get = optGet,
					set = function(info, val)
						local key = info[# info]
						bollo.db.profile[key] = val
						bollo:UpdateSettings()
					end,
					name = "General Settings",
					args = {
						desc = {
							order = 1,
							type = "description",
							name = "Bollo displays Buffs and Debuffs",
						},
						size = {
							order = 2,
							name = "Size",
							type = "range",
							min = 10,
							max = 50,
							step = 1,
						},
						spacing = {
							order = 3,
							name = "Spacing",
							type = "range",
							min = -20,
							max = 20,
							step = 1,
						},
					},
				},
			},
		}
	end
	return defaults
end


function conf:OnEnable()
	for name, module in bollo:IterateModules() do
		if module.options then
		end
	end

	LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable("Bollo", InitCore)
	bollo.options = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("Bollo", nil, nil, "general")
end


