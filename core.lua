local icons = {}
local bollo = CreateFrame("Frame")
bollo:SetScript("OnEvent", function(self, event, ...)
	return self[event](...)
end)
bollo:RegisterEvent("PLAYER_AURAS_CHANGED")
bollo:RegisterEvent("PLAYER_ENTERING_WORLD")

local UpdateDurations
do
	local timer = 0
	UpdateDurations = function(self, elapsed)
		timer = timer + elapsed
		if timer > 0.5 then
			for index, buff in ipairs(icons) do
				local timeLeft = buff:GetTimeLeft()
				if timeLeft > 0 then
					buff.duration:SetText(timeLeft)
					buff.duration:Show()
				else
					buff.duration:Hide()
				end
			end
			timer = 0
		end
	end
end

bollo:SetScript("OnUpdate", UpdateDurations)


--
local print = function(...)
	local str = ""
	for i = 1, select("#", ...) do
		str = str .. " " .. tostring(select(i, ...))
	end
	return ChatFrame1:AddMessage(str)
end

local SortFunc = function(a, b)
	if a and b then
		a:ClearAllPoints()
		b:ClearAllPoints()
		return b:GetTimeLeft() < a:GetTimeLeft()
	else
		return false
	end
end

local SortBuffs = function()
	table.sort(icons, SortFunc)
	for i, buff in ipairs(icons) do
		buff:ClearAllPoints()
		if buff:IsShown() then
			local index = buff:GetID()
			buff:SetPoint("TOP", UIParent, "TOP", 0, -5)
			if i > 1 then
				if icons[i - 1]:IsShown() then
					buff:SetPoint("RIGHT", icons[i - 1], "LEFT", - 4, 0)
				else
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

local OnMouseUp = function(self, button)
	if button == "RightButton" then
		CancelPlayerBuff(self:GetID())
	end
end

local SetBuff, GetBuff, GetTimeLeft
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
			self.buff = name
			self.texture = texture

			self:Show()
		end
	end

	GetBuff = function(self)
		return self.buff, self.texture
	end

	GetTimeLeft = function(self)
		return math.floor(GetPlayerBuffTimeLeft(self:GetID())*100/60)/100 or 0
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

	if not debuff then
		button:SetScript("OnMouseUp", OnMouseUp)
	end

	local icon = button:CreateTexture(nil, "BACKGROUND")
	icon:SetAllPoints(button)

	local count = button:CreateFontString(nil, "OVERLAY")
	count:SetFontObject(NumberFontNormal)
	count:SetPoint("TOPLEFT", button, "TOPLEFT", 2, -2)

	local duration = button:CreateFontString(nil, "OVERLAY")
	duration:SetFontObject(NumberFontNormal)
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

	table.insert(icons, button)

	return button
end

local UpdateIcons = function(index)
	-- Buff
	local name = UnitBuff("player", index)
	local icon = icons[index]
	if name then
		icon = icon or CreateIcon(index, false)
		icon.debuff = false
		icon:SetBuff(index)
		return true
	elseif icon then
		icon:Hide()
		return false
	end
end


bollo.PLAYER_AURAS_CHANGED = function()
	for i = 1, 40 do
		if not UpdateIcons(i) then
			break
		end
	end
	SortBuffs()
end

bollo.PLAYER_ENTERING_WORLD = function()
	-- Break blizzards stuff.
	local bf = _G["BuffFrame"]
	bf:UnregisterAllEvents()
	bf:Hide()
	bf:SetScript("OnUpdate", nil)
	bf:SetScript("OnEvent", nil)

	bollo.PLAYER_AURAS_CHANGED()
end
