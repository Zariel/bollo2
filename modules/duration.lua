local Bollo = LibStub("AceAddon-3.0"):GetAddon("Bollo2")
local Duration = Bollo:NewModule("Duration")
Duration.registry = {}

function Duration:OnInitialize()
	local defaults = {
		profile = {
			["*"] = {
				size = 14,
				font = STANDARD_TEXT_FONT,
				point = "TOP",
				x = 0,
				y = -2,
			}
		}
	}

	self.db = Bollo.db:RegisterNamespace("Duration", defaults)

	local conf = Bollo:GetModule("Config")
	local t = {
		duration = {
			name = "Duration",
			type = "group",
			childGroups = "tab",
			args = {
			},
		}
	}

	conf.options.plugins.duration = t
end

function Duration:OnEnable()
	Bollo.RegisterCallback(self, "OnUpdate")
end

function Duration:PostCreateIcon(event, buff)
	if buff.modules.duration then return end

	local t = buff:CreateFontString(nil, "OVERLAY")

	local db = self.db.profile[buff.base]

	local p, a, m = unpack(Bollo.Points[db.point])
	local font, size, flag = db.font, db.size, db.flag
	local x, y = db.x, db.y

	t:SetPoint(a, buff, p, x, y * m)
	t:SetFont(font, size, flag)

	t:SetShadowColor(0, 0, 0, 1)
	t:SetShadowOffset(1, -1)

	buff.modules.duration = t
end

function Duration:GenerateOptions(name, base)
	local conf = Bollo:GetModule("Config")

	local db = self.db.profile[base]

	local set = function(info, val)
		local k = info[# info]
		db[k] = val
		self:UpdateConfig(name)
	end

	local get = function(info)
		return db[info[# info]]
	end

	local t = {
		name = name,
		type = "group",
		set = set,
		get = get,
		args = {
			font = conf:GetFont(db, name, self),
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

	conf.options.plugins.duration.duration.args[name] = t
end

function Duration:Register(module, defaults)
	local name = tostring(module)
	if self.registry[name] then return end

	self.registry[name] = module
	module.modules.duration = true

	self:GenerateOptions(name, module.base)

	for i, b in ipairs(module.icons) do
		self:PostCreateIcon("init", b)
	end
end

function Duration:FormatTime(time)
	local text, m
	if time > 3600 then
		m = math.floor(time / 360 + 0.5) / 10
		text = "%dhr"
	elseif time > 60 then
		m = math.floor(mod(time, 3600) / 60 + 0.5)
		text = "%dm"
	else
		m = time
		text = "%ds"
	end
	return text, m
end

function Duration:UpdateConfig(name)
	if name then
		for index, buff in ipairs(self.registry[name].icons) do
			local d = buff.modules.duration
			local db = self.db.profile[buff.base]
			local font, size, flag = db.font, db.size, db.flag
			local x, y = db.x, db.y
			local p, a, m = unpack(Bollo.Points[db.point])

			d:ClearAllPoints()
			d:SetPoint(a, buff, p, x, y * m)
			d:SetFont(font, size, flag)
		end
	else
		-- all
		for name, module in pairs(self.registry) do
			self:UpdateConfig(name)
		end
		return
	end
end

function Duration:OnUpdate()
	for name, module in pairs(self.registry) do
		if module.modules.duration then
			for index, buff in ipairs(module.icons) do
				if buff:IsShown() then
					if not buff.modules.duration then self:PostCreateIcon("update", buff) end
					local timeleft = buff:GetTimeleft()
					if timeleft and timeleft > 0 then
						buff.modules.duration:SetFormattedText(Duration:FormatTime(timeleft))
						buff.modules.duration:Show()
					elseif module.config then
						buff.modules.duration:SetFormattedText(Duration:FormatTime(666))
						buff.modules.duration:Show()
					else
						buff.modules.duration:Hide()
					end

					if GameTooltip:IsShown() and GameTooltip:IsOwned(buff) then
						if buff.base == "TEMP" then
							GameTooltip:SetInventoryItem("player", buff.id)
						else
							GameTooltip:SetUnitAura("player", buff.id, buff.base)
						end
					end
				end
			end
		end
	end
end
