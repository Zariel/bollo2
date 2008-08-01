local Bollo = LibStub("AceAddon-3.0"):GetAddon("Bollo")
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
			lock = {
				name = "Lock",
				type = "toggle",
				get = function()
					return not module.icons.bg:IsShown()
				end,
				set = function(info, state)
					if state then
						module.icons.bg:Hide()
					else
						module.icons.bg:Show()
					end
				end,
				order = 10,
			},
			height = {
				name = "Height",
				type = "range",
				min = 10,
				max = 1000,
				step = 5,
				order = 20,
				set = function(info, val)
					local key = info[#info]
					module.db.profile[key] = val
					module.icons.bg:SetHeight(val)
					self:UpdateConfig(name)
				end,
				get = function()
					return module.icons.bg:GetHeight()
				end,
			},
			width = {
				name = "Width",
				type = "range",
				min = 10,
				max = 1000,
				step = 5,
				order = 30,
				set = function(info, val)
					local key = info[#info]
					module.db.profile[key] = val
					module.icons.bg:SetWidth(val)
					self:UpdateConfig(name)
				end,
				get = function()
					return module.icons.bg:GetWidth()
				end,
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
			rowSpacing = {
				name = "Row Spacing",
				type = "range",
				min = 0,
				max = 300,
				step = 1,
				order = 70,
			},

		}
	}

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
		for name, module in Bollo:IterateModules() do
			if module.UpdateConfig then
				module:UpdateConfig()
			end
		end
	else
		local mod = Bollo:GetModule(name, true)
		if mod.UpdateConfig then
			mod:UpdateConfig()
		end
	end
end
