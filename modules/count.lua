local bollo = LibStub("AceAddon-3.0"):GetAddon("Bollo2")
local count = bollo:NewModule("Count")

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

	self.db = bollo.db:RegisterNamespace("Count", defaults)

	self:SetEnabledState(self.db.profile.enabled)
end

function count:OnEnable()
	bollo.RegisterCallback(self, "PostUpdateIcon")
end

function count:ButtonCreated(event, button)
	local f = button:CreateFontString(nil, "OVERLAY")
	f:SetFont(self.db.profile[button.base].font, self.db.profile[button.base].fontSize)
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
