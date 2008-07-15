local bollo = LibStub("AceAddon-3.0"):GetAddon("Bollo")
local SML = LibStub("LibSharedMedia-3.0")
local duration = bollo:NewModule("Duration")

do
	local fonts = {}
	function duration:GetFonts()
		for k, v in ipairs(SML:List("font")) do
			fonts[SML:Fetch("font", v)] = v
		end
		return fonts
	end
end

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
			["format"] = "M:SS",
			["color"] = {
				r = 1,
				g = 1,
				b = 1,
				a = 1,
			},
		}
	}
	self.db =  bollo.db:RegisterNamespace("Bollo-Duration", defaults)

	if not self.options then
		self.options = {
			name = "Duration",
			type = "group",
			args = {
				general = {
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
						styleDesc = {
							name = "Set the style of display",
							type = "description",
							order = 3,
						},
						format = {
							name = "Style",
							type = "select",
							order = 4,
							values = {
								["M:SS"] = "M:SS",
								["MM"] = "MM",
							}
						},
						pointdesc = {
							name = "Set Where to show the duration",
							type = "description",
							order = 5,
						},
						point = {
							name = "point",
							type = "select",
							order = 6,
							values = {
								["TOP"] = "TOP",
								["BOTTOM"] = "BOTTOM",
							}
						},
						xDesc = {
							name = "Set the X position of the timer",
							type = "description",
							order = 7,
						},
						x = {
							order = 8,
							name = "X position",
							type = "range",
							min = -10,
							max = 10,
							step = 1,
						},
						yDesc = {
							name = "Set the Y position of the timer",
							type = "description",
							order = 9,
						},
						y = {
							order = 10,
							name = "Y Position",
							type = "range",
							min = -10,
							max = 10,
							step = 1,
						},
						fontDesc = {
							name = "Set the font",
							type = "description",
							order = 11,
						},
						fonts = {
							name = "Fonts",
							guiInline = true,
							type = "group",
							order = 12,
							args = {
								fontDesc = {
									name = "Set the font, uses SharedMedia-3.0",
									type = "description",
									order = 1,
								},
								font = {
									order = 2,
									name = "Font",
									type = "select",
									values = self:GetFonts(),
									set = function(info, val)
										local key = info[# info]
										self.db.profile[key] = val
										self:UpdateDisplay()
									end,
									get = function(info)
										local key = self.db.profile[info[# info]]
										return key
									end,
								},
								fontSizeDesc = {
									order = 3,
									type = "description",
									name = "Set the font Size",
								},
								fontSize = {
									order = 4,
									name = "Font Size",
									type = "range",
									min = 4,
									max = 30,
									step = 1,
									get = function(info)
										local key = info[# info]
										return self.db.profile[key]
									end,
									set = function(info, val)
										local key = info[# info]
										self.db.profile[key] = val
										self:UpdateDisplay()
									end,
								},
								fontStyleDesc = {
									order = 5,
									name = "Set the font style (flags)",
									type = "description",
								},
								fontStyle = {
									order = 6,
									name = "Font Style",
									type = "select",
									values = {
										["NONE"] = "NONE",
										["OUTLINE"] = "OUFLINE",
										["THINOUTLINE"] = "THINOUTLINE",
										["THICKOUTLINE"] = "THICKOUTLINE",
									},
								},
								colorDesc = {
									order = 6,
									name = "Set the color of the font",
									type = "description",
								},
								color = {
									type = "color",
									name = "color",
									order = 7,
									hasAlpha = true,
									get = function(info)
										local t = self.db.profile[info[#info]]
										return t.r, t.g, t.b, t.a
									end,
									set = function(info, r, g, b, a)
										local t = self.db.profile[info[#info]]
										t.r = r
										t.g = g
										t.b = b
										t.a = a
										self:UpdateDisplay()
									end,
								},
							},
						},
					},
				},
			},
		}
	end

	bollo:AddOptions(self)
	self:SetEnabledState(self.db.profile.enabled)
end

function duration:UpdateDisplay()
	for i, buff in ipairs(bollo.buffs) do
		if not buff.duration then break end
		local font, size, flag = self.db.profile.font, self.db.profile.fontSize, self.db.profile.fontStyle
		local point = self.db.profile.point
		local x, y = self.db.profile.x, self.db.profile.y
		local col = self.db.profile.color

		local anchor, relative, mod = bollo:GetPoint(point)

		buff.duration:SetFont(font, size, flag)
		buff.duration:ClearAllPoints()
		buff.duration:SetPoint(anchor, buff, relative, mod * x, y)
		buff.duration:SetTextColor(col.r, col.g, col.b, col.a)
	end
	for i, buff in ipairs(bollo.debuffs) do
		if not buff.duration then break end
		local font, size, flag = self.db.profile.font, self.db.profile.fontSize, self.db.profile.fontStyle
		local point = self.db.profile.point
		local x, y = self.db.profile.x, self.db.profile.y
		local col = self.db.profile.color

		local anchor, relative, mod = bollo:GetPoint(point)

		buff.duration:SetFont(font, size, flag)
		buff.duration:ClearAllPoints()
		buff.duration:SetPoint(anchor, buff, relative, mod * x, y)
		buff.duration:SetTextColor(col.r, col.g, col.b, col.a)
	end

end

function duration:PostCreateIcon(event, parent, button)
	local duration = button:CreateFontString(nil, "OVERLAY")
	local font, size, flag = self.db.profile.font, self.db.profile.fontSize, self.db.profile.fontStyle
	local point = self.db.profile.point
	local x, y = self.db.profile.x, self.db.profile.y
	local col = self.db.profile.color

	local anchor, relative, mod = bollo:GetPoint(point)

	duration:SetFont(font, size, flag)
	duration:ClearAllPoints()
	duration:SetPoint(anchor, button, relative, mod * x, y)
	duration:SetTextColor(col.r, col.g, col.b, col.a)
	button.duration = duration
end

function duration:OnEnable()
	SML.RegisterCallback(self, "LibSharedMedia_Registered", "GetFonts")
	self:GetFonts()

	bollo.db.RegisterCallback(self, "OnProfileChanged", "UpdateDisplay")
	bollo.RegisterCallback(self, "PostCreateIcon")
	bollo.RegisterCallback(self, "OnUpdate")
	bollo.RegisterCallback(self, "PostUpdateConfig", "UpdateDisplay")

	for k, v in ipairs(bollo.buffs) do
		self:PostCreateIcon(nil, bollo.buffs, v)
	end
	for k, v in ipairs(bollo.debuffs) do
		self:PostCreateIcon(nil, bollo.debuffs, v)
	end
end

function duration:OnDisable()
	bollo.UnregisterCallback(self, "PostCreateIcon")
	bollo.UnregisterCallback(self, "OnUpdate")
	bollo.UnregisterCallback(self, "PostUpdateConfig")
	SML.UnregisterCallback(self, "LibSharedMedia_Registered")
	bollo.db.UnregisterCallback(self, "OnProfileChanged")

	for k, v in ipairs(bollo.buffs) do
		v.duration:Hide()
	end
	for k, v in ipairs(bollo.debuffs) do
		v.duration:Hide()
	end

end

function duration:FormatTime(type, time)
	local hr, m, s, text
	if type == "M:SS" then
		text = "%d:%02.f"
		if time > 3600 then
			hr = math.floor(time / 3600)
			m = math.floor(math.fmod(time, 3600))
			return text, hr, m
		end

		m = math.floor(time/60)
		s = math.floor(math.fmod(time, 60))
		return text, m, s
	elseif type == "MM" then
		if time > 3600 then
			m = math.floor(time / 3600)
			text = "%dhr"
		elseif time > 60 then
			m = math.floor(mod(time, 3600))
			text = "%dm"
		else
			m = time
			text = "%ds"
		end
		return text, m
	end
end

function duration:OnUpdate()
	for i, buff in ipairs(bollo.buffs) do
		if not buff:IsShown() then break end
		local timeLeft = buff:GetTimeLeft()
		if timeLeft and timeLeft > 0 then
			buff.duration:SetFormattedText(duration:FormatTime(duration.db.profile.format, timeLeft))
			buff.duration:Show()
		else
			buff.duration:Hide()
		end
	end

	for i, buff in ipairs(bollo.debuffs) do
		if not buff:IsShown() then break end
		local timeLeft = buff:GetTimeLeft()

		if timeLeft and timeLeft > 0 then
			buff.duration:SetFormattedText(duration:FormatTime(duration.db.profile.format, timeLeft))
			buff.duration:Show()
		else
			buff.duration:Hide()
		end
	end
end
