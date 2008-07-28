local Bollo = LibStub("AceAddon-3.0"):GetAddon("Bollo")
local Duration = Bollo:NewModule("Duration", "AceConsole-3.0")

local registered = {}

function Duration:OnEnable()
	Bollo.RegisterCallback(self, "OnUpdate")
	Bollo.RegisterCallback(self, "PostCreateIcon")
	Bollo.RegisterCallback(self, "PostUpdateBuffPosition")
end


function Duration:PostUpdateBuffPosition(event, icon)
end


function Duration:PostCreateIcon(event, buff)
	if buff.modules.duration then return end

	local t = buff:CreateFontString(nil, "OVERLAY")
	t:SetFont(STANDARD_TEXT_FONT, 14)
	t:SetPoint("TOP", buff, "BOTTOM", 0, -2)
	t:SetPoint("LEFT", buff, "LEFT")
	t:SetPoint("RIGHT", buff, "RIGHT")

	buff.modules.duration = t
end

function Duration:Register(module)
	if registered[module] then return end

	registered[module] = true

	for i, b in ipairs(module.icons) do
		self:PostCreateIcon("init", b)
	end
end

function Duration:OnUpdate()
	for module, state in pairs(registered) do
		if state then
			for index, buff in ipairs(module.icons) do
				if not buff.modules.duration then self:PostCreateIcon("update", buff) end
				local timeleft = buff:GetTimeLeft()
				if timeleft and timeleft > 0 then
					buff.modules.duration:SetFormattedText(SecondsToTimeAbbrev(timeleft))
					buff.modules.duration:Show()
				else
					buff.modules.duration:Hide()
				end
			end
		end
	end
end
