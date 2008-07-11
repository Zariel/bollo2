local bollo = DongleStub("Dongle-1.2"):New("Bollo")

function bollo:Enable()
	self.icons = {}

	local bf = _G["BuffFrame"]
	bf:UnregisterAllEvents()
	bf:Hide()
	bf:SetScript("OnUpdate", nil)
	bf:SetScript("OnEvent", nil)

	self:RegisterEvent("PLAYER_AURAS_CHANGED")
	self:PLAYER_AURAS_CHANGED()

	self.frame = CreateFrame("Frame")
	local timer = 0
	self.frame:SetScript("OnUpdate", function(self, elapsed)
		timer = timer + elapsed
		if timer > 0.5 then
			local index = 1
			while icons[index]:IsShown() do
				local timeLeft = buff:GetTimeLeft()

				if timeLeft and timeLeft > 0 then
					buff.duration:SetText(timeLeft)
					buff.duration:Show()
				else
					buff.duration:Hide()
				end

				index = index + 1
			end
			timer = 0
		end
	end)
end

local CreateIcon 
do
	local name, rank, texture, count, debuffType, duration, timeLeft
	local SetBuff = function(self, index)
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

	local GetBuff = function(self)
		return self.buff, self.texture
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
				GameTooltip:SetUnitBuff("player", self:GetID())
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

	CreateIcon = function(index, debuff)
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
end

local SortFunc = function(a, b)
	if a and b then
		return a:GetTimeLeft() > b:GetTimeLeft()
	else
		return false
	end
end

local SortBuffs = function(max)
	table.sort(icons, SortFunc)
	local offset = 0
	for i = 1, max do
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

-- Blatently copied from oUF
function bollo:PLAYER_AURAS_CHANGED()
	local max = 0
	for i = 1, 40 do
		if not UpdateIcons(i) then
			while icons[i] do
				icons[i]:Hide()
				i = i + 1
			end
			break
		end
		max = max + 1
	end
	SortBuffs(max - 1)
end
