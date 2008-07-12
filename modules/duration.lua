local bollo = LibStub("AceAddon-3.0"):GetAddon("Bollo")

local duration = bollo:NewModule("Duration")

function duration:OnInitialize()
	local defaults = {
		profile = {
			["Description"] = "Show buff and debuff durations",
			["point"] = "TOP",
			["font"] = STANDARD_TEXT_FONT,
			["fontSize"] = 9,
			["fontStyle"] = "OUTLINE",
			["x"] = 0,
			["y"] = 0,
		}
	}
	self.db =  bollo.db:RegisterNamespace("Bollo-Duration", defaults)

	bollo.RegisterCallback(duration, "PostCreateIcon")
	if not self.options then
		self.options = {
			name = "Duration",
			type = "group",
			args = {
				general = {
					guiInline = true,
					name = self.db.profile.Description,
					type = "group",
					order = 1,
					set = function(info, val)
						local key = info[# info]
						self.db.profile[key] = val
						self:UpdateDisplay()
					end,
					get = function(info)
						local key = info[# info]
						return self.db.profile[key]
					end,
					args = {
						info = {
							name = "Display Duration left of buffs",
							type = "description",
							order = 1,
						},
						enable = {
							name = "Enable",
							type = "toggle",
							get = function(info)
								return self:IsEnabled()
							end,
							set = function(info, key)
								if key then
									self:Enable()
								else
									self:Disable()
								end
								self.db.profile.enabled = key
							end,
							order = 2
						},
						pointdesc = {
							name = "Set Where to show the duration",
							type = "description",
							order = 3,
						},
						point = {
							name = "point",
							type = "select",
							order = 4,
							values = {
								["TOP"] = "TOP",
								["BOTTOM"] = "BOTTOM",
							}
						},
					}
				},
			}
		}
	end

	self:SetEnabledState(self.db.profile.enabled)
end

local GetPoint = function(point)
	local anchor, relative, mod
	if point == "TOP" then
		relative = "TOP"
		anchor = "BOTTOM"
		mod = 1
	elseif point == "BOTTOM" then
		relative = "BOTTOM"
		anchor = "TOP"
		mod = -1
	end
	return anchor, relative, mod
end

function duration:UpdateDisplay()
	for i, buff in ipairs(bollo.buffs) do
		if not buff.duration then break end
		local font, size, flag = self.db.profile.font, self.db.profile.fontSize, self.db.profile.fontStyle
		local point = self.db.profile.point
		local x, y = self.db.profile.x, self.db.profile.y

		local anchor, relative, mod = GetPoint(point)

		buff.duration:SetFont(font, size, flag)
		buff.duration:ClearAllPoints()
		buff.duration:SetPoint(anchor, buff, relative, mod * x, y)
	end
	for i, buff in ipairs(bollo.debuffs) do
		if not buff.duration then break end
		local font, size, flag = self.db.profile.font, self.db.profile.fontSize, self.db.profile.fontStyle
		local point = self.db.profile.point
		local x, y = self.db.profile.x, self.db.profile.y

		local anchor, relative, mod = GetPoint(point)

		buff.duration:SetFont(font, size, flag)
		buff.duration:ClearAllPoints()
		buff.duration:SetPoint(anchor, buff, relative, mod * x, y)
	end

end


function duration:PostCreateIcon(event, parent, button)
	local duration = button:CreateFontString(nil, "OVERLAY")
	local font, size, flag = self.db.profile.font, self.db.profile.fontSize, self.db.profile.fontStyle
	local point = self.db.profile.point
	local x, y = self.db.profile.x, self.db.profile.y

	local anchor, relative, mod = GetPoint(point)

	duration:SetFont(font, size, flag)
	duration:ClearAllPoints()
	duration:SetPoint(anchor, button, relative, mod * x, y)
	button.duration = duration
end

function duration:OnEnable()
	self:OnUpdate()
end

function duration:OnDisable()
	self.frame:SetScript("OnUpdate", nil)
	for k, v in ipairs(bollo.buffs) do
		v.duration:Hide()
	end
	for k, v in ipairs(bollo.debuffs) do
		v.duration:Hide()
	end
end

function duration:OnUpdate()
	self.frame = self.frame or CreateFrame("Frame")
	local timer = 1
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
