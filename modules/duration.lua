local Bollo = LibStub("AceAddon-3.0"):GetAddon("Bollo")
local Duration = Bollo:NewModule("Duration", "AceConsole-3.0")

local registered = {}

function Duration:OnEnable()
	Bollo.RegisterCallback(self, "OnUpdate")

	self.db = Bollo.db:RegisterNamespace("Duration", defaults)
end

function Duration:PostCreateIcon(event, buff)
	if buff.modules.duration then return end

	local t = buff:CreateFontString(nil, "OVERLAY")
	t:SetFont(STANDARD_TEXT_FONT, 14)
	t:ClearAllPoints()
	t:SetPoint("TOP", buff, "BOTTOM", 0, -2)

	buff.modules.duration = t
end

function Duration:Register(module)
	if registered[tostring(module)] then return end

	registered[tostring(module)] = module

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

function Duration:UpdateConfig()
end

function Duration:OnUpdate()
	for name, module in pairs(registered) do
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
					GameTooltip["SetUnit" .. (buff.base == "HELPFUL" and "Buff" or "Debuff")]("player", buff.id)
				end
			end
		end
	end
end
