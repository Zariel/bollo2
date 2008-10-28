local Bollo = LibStub("AceAddon-3.0"):GetAddon("Bollo2")
local count = Bollo:NewModule("Count")
count.registry = {}

function count:OnInitialize()
	local defaults = {
		profile = {
			["*"] = {
				font = STANDARD_TEXT_FONT,
				fontSize = 18,
				style = "none",
				point = "TOP",
				x = 0,
				y = 2,
			},
			enabled = true
		}
	}

	self.db = Bollo.db:RegisterNamespace("Count", defaults)

	local conf = Bollo:GetModule("Config")
	local t = {
		count = {
			name = "Count",
			type = "group",
			childGroups = "tab",
			args = {
			},
		}
	}

	conf.options.plugins.count = t

	--self:SetEnabledState(self.db.profile.enabled)
end

function count:OnEnable()
	Bollo.RegisterCallback(self, "PostUpdateIcon")
end

function count:ButtonCreated(event, button)
	local f = button:CreateFontString(nil, "OVERLAY")
	f:SetFont(self.db.profile[button.name].font, self.db.profile[button.name].fontSize)
	f:SetShadowColor(0, 0, 0, 1)
	f:SetShadowOffset(1, -1)
	f:SetPoint("CENTER")

	button.modules.count = f
end

function count:PostUpdateIcon(event, button)
	local count = button:GetCount()
	if count and count > 0 then
		if not button.modules.count then
			self:ButtonCreated(event, button)
		end
		button.modules.count:SetText(count)
		button.modules.count:Show()
	elseif button.modules.count and button.modules.count:IsShown() then
		button.modules.count:Hide()
	end
end

function count:Register(module, defaults)
	local name = tostring(module)
	if self.registry[name] then return end

	self.registry[name] = module
	module.modules.count = true

	self:GenerateOptions(name)

	for i, b in ipairs(module.icons) do
		self:ButtonCreated("init", b)
	end
end

function count:GenerateOptions(name)
	local conf = Bollo:GetModule("Config")

	local set = function(info, val)
		local k = info[# info]
		self.db.profile[name][k] = val
		self:UpdateConfig(name)
	end

	local get = function(info)
		return self.db.profile[name][info[# info]]
	end

	local t = {
		name = name,
		type = "group",
		set = set,
		get = get,
		args = {
			font = conf:GetFont(self.db.profile[name], name, self),
			point = {
				type = "group",
				name = "point",
				guiInline = true,
				args = {
					point = {
						name = "point",
						type = "select",
						values = {
							TOP = "TOP",
							RIGHT = "RIGHT",
							BOTTOM = "BOTTOM",
							LEFT = "LEFT",
							CENTER = "CENTER",
						},
						order = 10,
					},
					x = {
						name = "x",
						type = "range",
						min = -15,
						max = 15,
						step = 1,
						order = 20
					},
					y = {
						name = "y",
						type = "range",
						min = -15,
						max = 15,
						step = 1,
						order = 30,
					}
				}
			}
		}
	}

	conf.options.plugins.count.count.args[name] = t
end

function count:UpdateConfig(name)
	if name then
		for i, icon in ipairs(self.registry[name].icons) do
			if icon.modules.count then
				local c = icon.modules.count
				db = self.db.profile[name]
				local font, size, flag = db.font, db.size, db.flag
				local x, y = db.x, db.y
				local p, a, m = unpack(Bollo.Points[db.point])

				c:ClearAllPoints()
				c:SetPoint(p, buff, a, x, y * m)
				c:SetFont(font, size, flag)
			end
		end
	else
		for name, module in pairs(self.registry) do
			self:UpdateConfig(name)
		end
		return
	end
end
