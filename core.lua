local bollo = CreateFrame("Frame")
bollo:SetScript("OnEvent", function(self, event, ...)
	return self[event](...)
end)
bollo:RegisterEvent("PLAYER_AURAS_CHANGED")
bollo:RegisterEvent("PLAYER_ENTERING_WORLD")
--

local icons = {}

local print = function(...)
	local str
	for i = 1, select("#", ...) do
		str = str .. tostring(select(i, ...))
	end
	return ChatFrame1:AddMessage(str)
end

local SortFunc = function(a, b)
	return b.timeLeft or 0 > a.timeLeft or 0
end

local SortBuffs = function()
	table.sort(icons, SortFunc)
	for i, buff in ipairs(icons) do
		if buff:IsShown() then
			local index = buff:GetID()
			buff:ClearAllPoints()
			buff:SetPoint("TOP", UIParent, "TOP")
			if i > 1 then
				buff:SetPoint("RIGHT", icons[i - 1], "LEFT", - 10, 0)
			else
				buff:SetPoint("RIGHT", UIParent, "RIGHT", - 5, - 5)
			end
		end
	end
end

local OnEnter = function(self)
	if self:IsVisible() then
		GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT")
		if self.debuff then
			GameTooltip:SetUnitDebuff("player", self:GetID())
		else
			GameTooltip:SetUnitBuff("player", self:GetID())
		end
	end
end

local OnLeave = function(self)
	GameTooltip:Hide()
end

local SetBuff
do
	local name, rank, texture, count, debuffType, duration, timeLeft
	SetBuff = function(self, index)
		self:SetID(index)
		if self.debuff then
			name, rank, texture, count, debuffType, duration, timeLeft = UnitDeBuff("player", index)
		else
			name, rank, texture, count, duration, timeLeft = UnitBuff("player", index)
		end
		if name then
			self.icon:SetTexture(texture)
			if count and count > 1 then
				self.count:SetText(count)
			else
				self.count:Hide()
			end
			if self.debuff and debuffType then
				local col = DebuffTypeColor[debuffType or "none"]
				self.border:SetVertexColor(col.r, col.g, col.b)
			else
				self.border:SetVertexColor(0.8, 0.8, 0.8)
			end
			self.timeLeft = timeLeft
			self:Show()
			return true
		else
			self:Hide()
			return false
		end
	end
end

local CreateIcon = function(index, debuff)
	local button = CreateFrame("Button")
	button:SetHeight(20)
	button:SetWidth(20)
	button:EnableMouse(true)
	button:SetID(index)
	button:SetScript("OnEnter", OnEnter)
	button:SetScript("OnLeave", OnLeave)

	local icon = button:CreateTexture(nil, "BACKGROUND")
	icon:SetAllPoints(button)

	local count = button:CreateFontString(nil, "OVERLAY")
	count:SetFontObject(NumberFontNormal)
	count:SetPoint("TOPLEFT", button, "TOPLEFT", 2, -2)

	local duration = button:CreateFontString(nil, "OVERLAY")
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

	button.SetBuff = SetBuff

	table.insert(icons, button)

	return button
end

local UpdateIcons = function(index)
	-- Buff
	local icon = icons[index] or CreateIcon(index, false)
	local buff = icon:SetBuff(index)
	return buff
end

bollo.PLAYER_AURAS_CHANGED = function()
	for i = 1, 40 do
		local fin = UpdateIcons(i)
		if not fin then break end
	end
	SortBuffs()
end

bollo.PLAYER_ENTERING_WORLD = function()
	bollo.PLAYER_AURAS_CHANGED()
end
