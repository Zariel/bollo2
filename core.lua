local bollo = LibStub("AceAddon-3.0"):NewAddon("Bollo", "AceEvent-3.0", "AceConsole-3.0")

local ipairs = ipairs
local pairs = pairs

local GetPlayerBuffName = GetPlayerBuffName
local GetPlayerBuff = GetPlayerBuff
local DebuffTypeColor = DebuffTypeColor
local GetPlayerBuffDispelType = GetPlayerBuffDispelType
local GetPlayerBuffApplications = GetPlayerBuffApplications
local DebuffTypeColor = DebuffTypeColor

function bollo:OnInitialize()
	local defaults = {
		profile = {
			["growth-x"] = "LEFT",
			["growth-y"] = "DOWN",
			["size"] = 20,
			["spacing"] = 2,
		},
	}
	self.db = LibStub("AceDB-3.0"):New("BolloDB", defaults, "profile")
	self.events = LibStub("CallbackHandler-1.0"):New(bollo)
end

function bollo:OnEnable()
	self.buffs = {}
	self.debuffs = {}

	local bf = _G["BuffFrame"]
	bf:UnregisterAllEvents()
	bf:Hide()
	bf:SetScript("OnUpdate", nil)
	bf:SetScript("OnEvent", nil)
	_G.BuffButton_OnUpdate = nil

	local bbg = CreateFrame("Frame")
	bbg:SetWidth(250)
	bbg:SetHeight(75)
	bbg:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", -10, -10)
	self.buffs.bg = bbg

	local dbg = CreateFrame("Frame")
	dbg:SetWidth(250)
	dbg:SetHeight(75)
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
			self.info.count = count or 0

			self:Show()
		else
			self:Hide()
		end

		local buff = self
		bollo.events:Fire("PostSetBuff", buff)
	end

	local GetBuff = function(self)
		return self.info.buff, self.info.rank, self.info.count
	end

	local GetTimeLeft = function(self)
		local id = self:GetID()
		if select(2, GetPlayerBuff(id)) > 0 then
			return 0
		else
			return GetPlayerBuffTimeLeft(id) or 0
		end
	end

	local OnEnter = function(self)
		if self:IsVisible() then
			GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT")
			GameTooltip:SetPlayerBuff(self:GetID())
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
		count:SetFont(STANDARD_TEXT_FONT, 10, "OUTLINE")
		count:SetPoint("TOPLEFT", button, "TOPLEFT", 2, -2)

		local border = button:CreateTexture(nil, "OVERLAY")
		border:SetTexture("Interface\\Buttons\\UI-Debuff-Overlays")
		border:SetAllPoints(button)
		border:SetTexCoord(.296875, .5703125, 0, .515625)

		button.count = count
		button.icon = icon
		button.debuff = debuff
		button.border = border
		button.timeLeft = 0

		button.SetBuff = SetBuff
		button.GetBuff = GetBuff
		button.GetTimeLeft = GetTimeLeft

		table.insert(parent, button)

		bollo.events:Fire("PostCreateIcon", parent, button)

		return button
	end
end

local SortFunc = function(a, b)
	if not a then
		a = 0
	else
		a = a:GetTimeLeft()
	end
	if not b then
		b = 0
	else
		b = b:GetTimeLeft()
	end
	return a > b
end

function bollo:SortBuffs(icons, max)
--	table.sort(icons, SortFunc)
	local offset = 0
	local growthx = self.db.profile["growth-x"] == "LEFT" and -1 or 1
	local growthy = self.db.profile["growth-y"] == "DOWN" and -1 or 1
	local size = self.db.profile.size + (self.db.profile.spacing or 0)
	local perCol = math.floor(icons.bg:GetWidth() / size + 0.5)
	local perRow = math.floor(icons.bg:GetHeight() / size + 0.5)
	local rows = 0
	--for i = 1, max do
	for i, buff in ipairs(icons) do
		if buff:IsShown() then
			buff:ClearAllPoints()

			if offset == perCol then
				row = row + 1
			end

			buff:SetPoint("TOPRIGHT", icons.bg, "TOPRIGHT", (offset * size * growthx), rows * size * growthy)
			offset = offset + 1
		end
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
		icon:SetID(0)
		icon:Hide()
		return false
	end
end

-- Blatently copied from oUF
function bollo:PLAYER_AURAS_CHANGED()
	local max = 1
	for i = 1, 40 do
		if not self:UpdateIcons(i, self.buffs, "HELPFUL") then
			for a = i,  #self.buffs do
				self.buffs[a]:Hide()
			end
			break
		end
		max = max + 1
	end
	self:SortBuffs(self.buffs, max - 1)
	max = 1
	for i = 1, 40 do
		if not self:UpdateIcons(i, self.debuffs, "HARMFUL") then
			for a = i,  #self.debuffs do
				self.debuffs[a]:Hide()
			end
			break
		end
		max = max + 1
	end
	self:SortBuffs(self.debuffs, max - 1)
end
