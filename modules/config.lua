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
					name = "General Settings",
					args = {
						desc = {
							order = 1,
							type = "description",
							name = "Bollo displays Buffs and Debuffs",
						},
						buff = {
							order = 2,
							type = "group",
							set = function(info, val)
								local key = info[# info]
								bollo.db.profile.buff[key] = val
								bollo:UpdateSettings(bollo.buffs)
							end,
							get = function(info)
								local key = info[# info]
								return bollo.db.profile.buff[key]
							end,
							name = "Buff Settings",
							args = {
								desc = {
									order = 1,
									type = "description",
									name = "Settings for Buff display",
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
								rowSpace = {
									order = 4,
									name = "Row Spacing",
									type = "range",
									min = 0,
									max = 50,
									step = 1,
								},
								height = {
									order = 4,
									name = "Max Height",
									type = "range",
									min = 25,
									max = 600,
									step = 25,
								},
								width = {
									order = 5,
									name = "Max Width",
									type = "range",
									min = 25,
									max = 600,
									step = 25,
								},
								lock = {
									order = 6,
									name = "lock",
									type = "toggle",
									set = function(info, key)
										if key then
											bollo.buffs.bg:Hide()
										else
											bollo.buffs.bg:Show()
										end
										bollo.db.profile.buff.lock = key
									end,
									get = function(info)
										return not bollo.buffs.bg:IsShown()
									end,
								},
							}
						},
						debuff = {
							order = 3,
							type = "group",
							set = function(info, val)
								local key = info[# info]
								bollo.db.profile.debuff[key] = val
								bollo:UpdateSettings(bollo.debuffs)
							end,
							get = function(info)
								local key = info[# info]
								return bollo.db.profile.debuff[key]
							end,
							name = "Debuff Settings",
							args = {
								desc = {
									order = 1,
									type = "description",
									name = "Settings for Debuff display",
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
								rowSpace = {
									order = 4,
									name = "Row Spacing",
									type = "range",
									min = 0,
									max = 50,
									step = 1,
								},
								height = {
									order = 4,
									name = "Max Height",
									type = "range",
									min = 25,
									max = 600,
									step = 25,
								},
								width = {
									order = 5,
									name = "Max Width",
									type = "range",
									min = 25,
									max = 600,
									step = 25,
								},
								lock = {
									order = 6,
									name = "lock",
									type = "toggle",
									set = function(info, key)
										if key then
											bollo.debuffs.bg:Hide()
										else
											bollo.debuffs.bg:Show()
										end
										bollo.db.profile.debuff.lock = key
									end,
									get = function(info)
										return not bollo.debuffs.bg:IsShown()
									end,
									},
								}
							},
						},
					}
				}
			}
	end

	return defaults
end


function conf:OnEnable()

	LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable("Bollo", InitCore)
	bollo.options = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("Bollo", nil, nil, "general")

	for name, module in bollo:IterateModules() do
		if module.options then
			LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable(tostring(module), module.options)
			module.bliz = LibStub("AceConfigDialog-3.0"):AddToBlizOptions(tostring(module), name, "Bollo", "general")
		end
	end

end
