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
					childGroups  = "tab",
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
								sizeDesc = {
									order = 2,
									name = "Set the size of the buffs (height and width)",
									type = "description",
								},
								size = {
									order = 3,
									name = "Size",
									type = "range",
									min = 10,
									max = 100,
									step = 1,
								},
								spacingDesc = {
									order = 4,
									name = "Set the horizontal spacing between buffs",
									type = "description",
								},
								spacing = {
									order = 5,
									name = "Spacing",
									type = "range",
									min = -20,
									max = 20,
									step = 1,
								},
								rowSpacingDesc = {
									order = 5,
									name = "Set the vertical spacing between rows",
									type = "description",
								},
								rowSpace = {
									order = 6,
									name = "Row Spacing",
									type = "range",
									min = 0,
									max = 50,
									step = 1,
								},
								heightDesc = {
									order = 7,
									name = "Set the height of the buff display",
									type = "description",
								},
								height = {
									order = 8,
									name = "Max Height",
									type = "range",
									min = 25,
									max = 600,
									step = 25,
								},
								widthDesc = {
									order = 9,
									name = "Set the width the buff display",
									type = "description",
								},
								width = {
									order = 10,
									name = "Max Width",
									type = "range",
									min = 25,
									max = 600,
									step = 25,
								},
								growthxDesc = {
									order = 11,
									name = "Set the Growth-X",
									type = "description",
								},
								growthx = {
									order = 12,
									name = "Growth X",
									type = "select",
									values = {
										["LEFT"] = "LEFT",
										["RIGHT"] = "RIGHT",
									},
								},
								growthyDesc = {
									order = 13,
									name = "Set the Growth-X",
									type = "description",
								},
								growthy = {
									order = 14,
									name = "Growth X",
									type = "select",
									values = {
										["UP"] = "UP",
										["DOWN"] = "DOWN",
									},
								},
								lockDesc = {
									order = 15,
									name = "Lock or unlock the display",
									type = "description",
								},
								lock = {
									order = 16,
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
								sizeDesc = {
									order = 2,
									name = "Set the size of the debuffs (height and width)",
									type = "description",
								},
								size = {
									order = 3,
									name = "Size",
									type = "range",
									min = 10,
									max = 100,
									step = 1,
								},
								spacingDesc = {
									order = 4,
									name = "Set the horizontal spacing between debuffs",
									type = "description",
								},
								spacing = {
									order = 5,
									name = "Spacing",
									type = "range",
									min = -20,
									max = 20,
									step = 1,
								},
								rowSpacingDesc = {
									order = 5,
									name = "Set the vertical spacing between rows",
									type = "description",
								},
								rowSpace = {
									order = 6,
									name = "Row Spacing",
									type = "range",
									min = 0,
									max = 50,
									step = 1,
								},
								heightDesc = {
									order = 7,
									name = "Set the height of the debuff display",
									type = "description",
								},
								height = {
									order = 8,
									name = "Max Height",
									type = "range",
									min = 25,
									max = 600,
									step = 25,
								},
								widthDesc = {
									order = 9,
									name = "Set the width the debuff display",
									type = "description",
								},
								width = {
									order = 10,
									name = "Max Width",
									type = "range",
									min = 25,
									max = 600,
									step = 25,
								},
								growthx = {
									order = 12,
									name = "Growth X",
									type = "select",
									values = {
										["LEFT"] = "LEFT",
										["RIGHT"] = "RIGHT",
									},
								},
								growthyDesc = {
									order = 13,
									name = "Set the Growth-X",
									type = "description",
								},
								growthy = {
									order = 14,
									name = "Growth X",
									type = "select",
									values = {
										["UP"] = "UP",
										["DOWN"] = "DOWN",
									},
								},
								lockDesc = {
									order = 15,
									name = "Lock or unlock the display",
									type = "description",
								},
								lock = {
									order = 12,
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


function conf:OnInitialize()
	bollo.options = InitCore()
	defaults.plugins = {}
	LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable("Bollo", defaults)
	LibStub("AceConfigDialog-3.0"):AddToBlizOptions("Bollo", nil, nil, "general")
end


function bollo:AddOptions(module)
	if module.options then
		local modName = tostring(module)
		local name = modName:match("Bollo_(.+)")
		LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable(modName, module.options)
		module.bliz = LibStub("AceConfigDialog-3.0"):AddToBlizOptions(modName, name, "Bollo", "general")
	end

end
