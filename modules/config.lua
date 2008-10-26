local Bollo = LibStub("AceAddon-3.0"):GetAddon("Bollo2")
local Config = Bollo:NewModule("Config", "AceConsole-3.0")
local db

local options = {
	type = "group",
	name = "Bollo",
	get = function(info)
		return db[info[#info]]
	end,
	set = function(info, val)
		db[info[#info]] = val
		Config:UpdateConfig()
	end,
	args = {
		icons = {
			type = "group",
			name = "Icons",
			order = 10,
			args = {}
		},
	},
	plugins = {},
}

local SML = LibStub("LibSharedMedia-3.0", true)

local fonts = setmetatable({
	[STANDARD_TEXT_FONT] = "Default",
}, {
	__call = function(self)
		if SML then
			for k, v in ipairs(SML:List("font")) do
				self[SML:Fetch("font", v)] = v
			end
		end
		return self
	end
})

if SML then
	for k, v in ipairs(SML:List("font")) do
		fonts[SML:Fetch("font", v)] = v
	end
end

function Config:GenerateOptions(name, module)
	self.count = self.count or 0 + 10
	local get = function(info)
		return module.db.profile[info[#info]]
	end
	local set = function(info, val)
		module.db.profile[info[#info]] = val
		self:UpdateConfig(name)
	end
	local t = {
		["type"] = "group",
		["name"] = name,
		["set"] = set,
		["get"] = get,
		["order"] = self.count,
		["args"] = {
			lock_desc = {
				name = "Lock the anchor frame",
				type = "description",
				order = 9,
			},
			lock = {
				name = "Lock",
				type = "toggle",
				get = function()
					return not module.icons.bg:IsShown()
				end,
				set = function(info, state)
					if state then
						module.icons.bg:Hide()
						module:DisableSetupConfig()
					else
						module.icons.bg:Show()
						module:EnableSetupConfig()
					end
				end,
				order = 10,
			},
			perRow_desc = {
				name = "Set the max buffs per row to display",
				type = "description",
				order = 19,
			},
			perRow = {
				name = "Per Row",
				type = "range",
				min = 1,
				max = 40,
				step = 1,
				order = 20
			},
			max_desc = {
				name = "Set the max buffs to display",
				type = "description",
				order = 29,
			},
			max = {
				name = "Max",
				type = "range",
				min = 1,
				max = 40,
				step = 1,
				order = 30
			},
			size = {
				name = "Size",
				type = "range",
				min = 1,
				max = 100,
				step = 1,
				order = 40,
			},
			scale = {
				name = "Scale",
				type = "range",
				min = 0.1,
				max = 4,
				step = 0.1,
				order = 50,
			},
			spacing = {
				name = "Horizontal Spacing",
				type = "range",
				min = -100,
				max = 300,
				step = 1,
				order = 60,
			},
			growthX = {
				name = "GrowthX",
				type = "select",
				values = {
					LEFT = "LEFT",
					RIGHT = "RIGHT",
				},
				order = 65
			},
			growthY = {
				name = "GrowthY",
				type = "select",
				values = {
					DOWN = "DOWN",
					UP = "UP",
				},
				order = 67
			},
			rowSpacing = {
				name = "Row Spacing",
				type = "range",
				min = 0,
				max = 300,
				step = 1,
				order = 70,
			},
			color = {
				name = "Border Color",
				type = "color",
				order = 80,
				hasAlpha = true,
				set = function(info, r, g, b, a)
					local t = module.db.profile[info[#info]]
					t.r = r
					t.g = g
					t.b = b
					t.a = a
					self:UpdateConfig(name)
				end,
				get = function(info)
					local t = module.db.profile[info[#info]]
					return t.r, t.g, t.b, t.a
				end,
				disabled = function()
					return not module.db.profile.borderColor
				end,
			},
			borderColor = {
				type = "toggle",
				name = "Border Color",
				tristate = true,
				order = 90,
			},
		}
	}

	self.options.args.icons.args[name] = t

	return t
end

function Config:OnInitialize()
	db = Bollo.db.profile

	options.plugins.profiles = {profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(Bollo.db)}

	LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable("Bollo2", options)

	self:RegisterChatCommand("bollo", function() LibStub("AceConfigDialog-3.0"):Open("Bollo2") end )

	self.options = options
end

function Config:UpdateConfig(name)
	if not name or name == "Bollo" then
		Bollo:UpdateConfig()
	elseif name == "all" then
		for _, module in ipairs(Bollo.registry) do
			if module.UpdateConfig then
				module:UpdateConfig()
			end
		end
	else
		for _, mod in ipairs(Bollo.registry) do
			if mod.name == name then
				if mod.UpdateConfig then
					mod:UpdateConfig()
					break
				end
			end
		end
	end
end

function Config:GetFont(db, name)
	local t = {
		name = "Font",
		type = "group",
		args = {
			font = {
				type = "select",
				name = "font",
				values = fonts(),
				get = function(info)
					return db.font
				end,
				set = function(info, val)
					db[info[# info]] = val
					self:UpdateConfig(name)
				end,
				order = 10,
			}
		}
	}

	return t
end
