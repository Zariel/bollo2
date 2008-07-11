local bollo = DongleStub("Dongle-1.2"):New("Bollo")

function bollo:Initialize()
	defaults = {
		profile = {
			["growth-x"] = "LEFT",
			["growth-y"] = "DOWN",
			["size"] = 20,
			["spacing"] = 2,
		},
	}
	self.db = self:InitializeDB("BolloDB", defaults, profile)
end

function bollo:Enable()
	self.buffs = {}
	self.debuffs = {}

	local bf = _G["BuffFrame"]
	bf:UnregisterAllEvents()
	bf:Hide()
	bf:SetScript("OnUpdate", nil)
	bf:SetScript("OnEvent", nil)

	self.frame = CreateFrame("Frame")
	local timer = 0
	self.frame:SetScript("OnUpdate", function(self, elapsed)
		timer = timer + elapsed
		if timer > 0.25 then
			for index = 1, #bollo.buffs do
				local buff = bollo.buffs[index]
				if not buff:IsShown() then break end
				local timeLeft = buff:GetTimeLeft()

				if timeLeft and timeLeft > 0 then
					buff.duration:SetFormattedText("%.2f", timeLeft)
					buff.duration:Show()
				else
					buff.duration:Hide()
				end

			end
			for index = 1, #bollo.debuffs do
				local buff = bollo.debuffs[index]
				if not buff:IsShown() then break end
				local timeLeft = buff:GetTimeLeft()

				if timeLeft and timeLeft > 0 then
					buff.duration:SetFormattedText("%.2f", timeLeft)
					buff.duration:Show()
				else
					buff.duration:Hide()
				end
			end
			timer = 0
		end
	end)

	local bbg = CreateFrame("Frame")
	bbg:SetWidth(250)
	bbg:SetHeight(50)
	bbg:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", -10, -10)
	self.buffs.bg = bbg

	local dbg = CreateFrame("Frame")
	dbg:SetWidth(250)
	dbg:SetHeight(50)
	dbg:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", -10, -60)
	self.debuffs.bg = dbg

	self:RegisterEvent("PLAYER_AURAS_CHANGED")
	self:PLAYER_AURAS_CHANGED()
end

do
	local name, rank, texture, count, debuffType, duration, timeLeft
	local SetBuff = function(self, index)
		self:SetID(index)
		if self.debuff then
			debuffType = GetPlayerBuffDispelType(index)
		end

		name, rank = GetPlayerBuffName(index)
		texture = GetPlayerBuffTexture(index)
		count = GetPlayerBuffApplications(index)

		if name then
			self.icon:SetTexture(texture)
			if count and count > 1 then
				self.count:Show()
				self.count:SetText(count)
			else
				self.count:Hide()
			end

			if self.debuff and debuffType then
				local col = DebuffTypeColor[debuffType or "none"]
				self.border:SetVertexColor(col.r, col.g, col.b)
				self.border:Show()
			else
				self.border:Hide()
			end

			self.info = self.info or {}
			self.info.buff = name
			self.info.rank = rank
			self.info.ount = count or 0

			self:Show()
		end
	end

	local GetBuff = function(self)
		return self.info.buff, self.info.rank, self.info.count
	end

	local GetTimeLeft = function(self)
		return math.floor(GetPlayerBuffTimeLeft(self:GetID())*100/60)/100 or 0
	end

	local OnEnter = function(self)
		if self:IsVisible() then
			GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT")
			if self.debuff then
				GameTooltip:SetUnitDebuff("player", self:GetID())
			else
				GameTooltip:SetPlayerBuff(self:GetID())
			end
		end
	end

	local OnLeave = function(self)
		return GameTooltip:Hide()
	end

	local OnMouseUp = function(self, button)
		if button == "RightButton" then
			return CancelPlayerBuff(self:GetID())
		end
	end

	function bollo:CreateIcon(index, parent, debuff)
		local button = CreateFrame("Button")
		button:SetHeight(bollo.db.profile.size)
		button:SetWidth(bollo.db.profile.size)
		button:EnableMouse(true)
		button:SetID(index)
		button:SetScript("OnEnter", OnEnter)
		button:SetScript("OnLeave", OnLeave)

		if not debuff then
			button:SetScript("OnMouseUp", OnMouseUp)
		end

		local icon = button:CreateTexture(nil, "BACKGROUND")
		icon:SetAllPoints(button)

		local count = button:CreateFontString(nil, "OVERLAY")
		count:SetFontObject(NumberFontNormal)
		count:SetPoint("TOPLEFT", button, "TOPLEFT", 2, -2)

		local duration = button:CreateFontString(nil, "OVERLAY")
		duration:SetFont(STANDARD_TEXT_FONT, 10, "OUTLINE")
		duration:SetPoint("TOP", button, "BOTTOM", 0, -2)

		local border = button:CreateTexture(nil, "OVERLAY")
		border:SetTexture("Interface\\Buttons\\UI-Debuff-Overlays")
		border:SetAllPoints(button)
		border:SetTexCoord(.296875, .5703125, 0, .515625)

		button.count = count
		button.icon = icon
		button.duration = duration
		button.debuff = debuff
		button.border = border
		button.timeLeft = 0

		button.SetBuff = SetBuff
		button.GetBuff = GetBuff
		button.GetTimeLeft = GetTimeLeft

		table.insert(parent, button)

		return button
	end
end

local SortFunc = function(a, b)
	local c, d
	if not a then
		c = 0
	else
		c = a:GetTimeLeft()
	end
	if not b then
		d = 0
	else
		d = b:GetTimeLeft()
	end
	return c > d
end

function bollo:SortBuffs(icons, max)
	table.sort(icons, SortFunc)
	local offset = 0
	local growthx = self.db.profile["growth-x"] == "LEFT" and -1 or 1
	local growthy = self.db.profile["growth-y"] == "DOWN" and -1 or 1
	local size = self.db.profile.size + (self.db.profile.spacing or 0)
	local perCol = math.floor(icons.bg:GetWidth() / size + 0.5)
	local perRow = math.floor(icons.bg:GetHeight() / size + 0.5)
	local rows = 0
	for i = 1, max do
		local buff = icons[i]
		buff:ClearAllPoints()

		if offset == perCol then
			row = row + 1
		end

		buff:SetPoint("TOPRIGHT", icons.bg, "TOPRIGHT", (offset * size * growthx), rows * size * growthy)
		offset = offset + 1
	end
end

function bollo:UpdateIcons(i, parent, filter)
	local index = GetPlayerBuff(i, filter)
	-- Buff
	local name = GetPlayerBuffName(index)
	local icon = parent[i]

	if name then
		icon = icon or self:CreateIcon(index, parent, filter == "HARMFUL")
		icon:SetBuff(index)
		return true
	elseif icon then
		icon:Hide()
		return false
	end
end

-- Blatently copied from oUF
function bollo:PLAYER_AURAS_CHANGED()
	local max = 1
	for i = 1, 40 do
		if not self:UpdateIcons(i, self.buffs, "HELPFUL") then
			while self.buffs[i] do
				self.buffs[i]:Hide()
				i = i + 1
			end
			break
		end
		max = max + 1
	end
	self:SortBuffs(self.buffs, max - 1)
	max = 0
	for i = 1, 40 do
		if not self:UpdateIcons(i, self.debuffs, "HARMFUL") then
			while self.debuffs[i] do
				self.debuffs[i]:Hide()
				i = 1 + 1
			end
			break
		end
		max = max + 1
	end
	self:SortBuffs(self.debuffs, max - 1)
end
