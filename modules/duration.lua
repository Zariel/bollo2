local bollo = LibStub("AceAddon-3.0"):GetAddon("Bollo")

local duration = bollo:NewModule("Duration")

function duration:OnInitialize()
	local defaults = {
		profile = {
			["Description"] = "Show buff and debuff durations",
			["Point"] = "TOP",
			["font"] = STANDARD_TEXT_FONT,
			["fontSize"] = 9,
			["fontStyle"] = "OUTLINE",
			["x"] = 0,
			["y"] = 0,
		}
	}
	self.db =  bollo.db:RegisterNamespace("Bollo-Duration", defaults)

	bollo.RegisterCallback(duration, "PostCreateIcon")
end

local GetPoint = function(point)
	local anchor, relative
	if point == "TOP" then
		relative = "TOP"
		anchor = "BOTTOM"
	elseif point == "BOTTOM" then
		relative = "BOTTOM"
		anchor = "TOP"
	end
	return anchor, relative
end

function duration:PostCreateIcon(event, parent, button)
	local duration = button:CreateFontString(nil, "OVERLAY")
	local font, size, flag = self.db.profile.font, self.db.profile.fontSize, self.db.profile.fontStyle
	local point = self.db.profile.Point
	local x, y = self.db.profile.x, self.db.profile.y

	local anchor, relative = GetPoint(point)

	duration:SetFont(font, size, flag)
	duration:ClearAllPoints()
	duration:SetPoint(anchor, button, relative, x, y)
	button.duration = duration
end

function duration:OnEnable()
	self:OnUpdate()
end

function duration:OnUpdate()
	self.frame = CreateFrame("Frame")
	local timer = 0
	self.frame:SetScript("OnUpdate", function(self, elapsed)
		timer = timer + elapsed
		if timer > 0.25 then
			for i, buff in ipairs(bollo.buffs) do
				if not buff:IsShown() then break end
				local timeLeft = buff:GetTimeLeft()
				if timeLeft and timeLeft > 0 then
					buff.duration:SetFormattedText(SecondsToTimeAbbrev(timeLeft))
					buff.duration:Show()
				else
					buff.duration:Hide()
				end
			end

			for i, buff in ipairs(bollo.debuffs) do
				if not buff:IsShown() then break end
				local timeLeft = buff:GetTimeLeft()

				if timeLeft and timeLeft > 0 then
					buff.duration:SetFormattedText(SecondsToTimeAbbrev(timeLeft))
					buff.duration:Show()
				else
					buff.duration:Hide()
				end
			end
			timer = 0
		end
	end)
end
