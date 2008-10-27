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
				desc = {
					name = "Test",
					type = "description",
					order = 0,
				}
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
	t:SetFont(STANDARD_TEXT_FONT, 14)
	t:SetShadowColor(0, 0, 0, 1)
	t:SetShadowOffset(1, -1)

	t:SetPoint("TOP", buff, "BOTTOM", 0, -2)

	buff.modules.duration = t
end

function Duration:GenerateOptions(name)
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
		}
	}

	conf.options.plugins.duration.duration.args[name] = t
end

function Duration:Register(module, defaults)
	local name = tostring(module)
	if self.registry[name] then return end

	self.registry[name] = module
	module.modules.duration = true

	self:GenerateOptions(name)

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
	else
		-- all
		for name, module in pairs(self.registry) do
			for index, buff in ipairs(module.icons) do
				local d = buff.modules.duration
				local db = self.db.profile[name]
				local font, size, flag = db.font, db.size, db.flag
				local x, y = db.x, db.y
				local p, a, m = unpack(Bollo.Points[db.point])

				d:ClearAllPoints()
				d:SetPoint(p, buff, a, x, y * m)
				d:SetFont(font, size, flag)
				self:Print(font)
			end
		end
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
