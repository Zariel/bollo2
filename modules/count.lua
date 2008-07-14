local bollo = LibStub("AceAddon-3.0"):GetAddon("Bollo")
local Count = bollo:NewModule("Count")

local SML = LibStub("LibSharedMedia-3.0")

do
	local fonts = {}
	function Count:GetFonts()
		for k, v in ipairs(SML:List("font")) do
			fonts[SML:Fetch("font", v)] = v
		end
		return fonts
	end
end

function Count:PostSetBuff(event, buff, index, filter)
	local count = buff:GetCount()
	if count > 1 then
		buff.count:SetText(count)
		buff.count:Show()
	else
		buff.count:Hide()
	end
end

function Count:PostCreateIcon(event, parent, buff)
	local f = buff:CreateFontString(nil, "OVERLAY")

	local font, size, flag = self.db.profile.font, self.db.profile.fontSize, self.db.profile.fontStyle
	local point = self.db.profile.point
	local x, y = self.db.profile.x, self.db.profile.y
	local anchor, relative, mod = bollo:GetPoint(point)
	local col = self.db.profile.color

	f:SetFont(font, size, flag)
	f:SetTextColor(col.r, col.g, col.b, col.a)
	f:ClearAllPoints()
	f:SetPoint(anchor, buff, relative, mod * x, y)

	buff.count = f
end

function Count:OnInitialize()
	local defaults = {
		profile = {
			["Description"] = "Shows count of buffs/debuffs",
			["font"] = STANDARD_TEXT_FONT,
			["fontStyle"] = "OUTLINE",
			["fontSize"] = 9,
			["x"] = 0,
			["y"] = 0,
			["point"] = "CENTER",
			["color"] = {
				r = 1,
				g = 1,
				b = 1,
				a = 1,
			},
		}
	}

	self.db = bollo.db:RegisterNamespace("Bollo-Count", defaults)

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
							name = "Display application of buffs",
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
							name = "Set Where to show the count",
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
								["CENTER"] = "CENTER",
							}
						},
						xDesc = {
							name = "Set the X position of the count",
							type = "description",
							order = 5,
						},
						x = {
							order = 7,
							name = "X position",
							type = "range",
							min = -10,
							max = 10,
							step = 1,
						},
						yDesc = {
							name = "Set the Y position of the count",
							type = "description",
							order = 7,
						},
						y = {
							order = 8,
							name = "Y Position",
							type = "range",
							min = -10,
							max = 10,
							step = 1,
						},
						fontDesc = {
							name = "Set the font",
							type = "description",
							order = 8,
						},
						fonts = {
							name = "Fonts",
							guiInline = true,
							type = "group",
							order = 9,
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

	self:SetEnabledState(self.db.profile.enabled)
end

function Count:OnEnable()
	bollo.RegisterCallback(self, "PostCreateIcon")
	bollo.RegisterCallback(self, "PostSetBuff")
	SML.RegisterCallback(self, "LibSharedMedia_Registered", "GetFonts")
	self:GetFonts()

	for k, v in ipairs(bollo.buffs) do
		self:PostCreateIcon(nil, bollo.buffs, v)
		self:PostSetBuff(nil, v)
		v.count:Show()
	end
	for k, v in ipairs(bollo.debuffs) do
		self:PostCreateIcon(nil, bollo.debuffs, v)
		self:PostSetBuff(nil, v)
		v.count:Show()
	end
end

function Count:OnDisable()
	bollo.UnregisterCallback(self, "PostCreateIcon")
	bollo.UnregisterCallback(self, "PostSetBuff")
	SML.UnregisterCallback(self, "LibSharedMedia_Registered", "GetFonts")

	for k, v in ipairs(bollo.buffs) do
		v.count:Hide()
	end
	for k, v in ipairs(bollo.debuffs) do
		v.count:Hide()
	end
end

function Count:UpdateDisplay()
	for i, buff in ipairs(bollo.buffs) do
		if not buff.text then break end
		local font, size, flag = self.db.profile.font, self.db.profile.fontSize, self.db.profile.fontStyle
		local point = self.db.profile.point
		local x, y = self.db.profile.x, self.db.profile.y
		local col = self.db.profile.color

		local anchor, relative, mod = bollo:GetPoint(point)

		buff.count:SetFont(font, size, flag)
		buff.count:ClearAllPoints()
		buff.count:SetPoint(anchor, buff, relative, mod * x, y)
		buff.count:SetTextColor(col.r, col.g, col.b, col.a)
	end
	for i, buff in ipairs(bollo.debuffs) do
		if not buff.text then break end
		local font, size, flag = self.db.profile.font, self.db.profile.fontSize, self.db.profile.fontStyle
		local point = self.db.profile.point
		local x, y = self.db.profile.x, self.db.profile.y
		local col = self.db.profile.color

		local anchor, relative, mod = bollo:GetPoint(point)

		buff.count:SetFont(font, size, flag)
		buff.count:ClearAllPoints()
		buff.count:SetPoint(anchor, buff, relative, mod * x, y)
		buff.count:SetTextColor(col.r, col.g, col.b, col.a)
	end
end
