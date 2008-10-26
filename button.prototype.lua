local Bollo = LibStub("AceAddon-3.0"):GetAddon("Bollo2")
local prototype = CreateFrame("Button", nil, UIParent)
Bollo.IconPrototype = prototype

local GetTime = GetTime
local UnitAura = UnitAura

local Base = {
	HELPFUL = "Buff",
	HARMFUL = "Debuff",
	TEMP = "Weapon",
}

function prototype:GetName()
	if not self.name then
		self:SetName(true)
	end

	return self.name
end

function prototype:SetName(temp)
	local name
	if temp or not self.base then
		name = "BolloBuff" .. 1
	else
		name = "Bollo" .. Base[self.base] .. self.id
	end

	self.name = name
end

function prototype:Setup(db)
	local size = db.size
	self:SetHeight(size)
	self:SetWidth(size)
	self:SetScale(db.scale)
	self.Icon:ClearAllPoints()
	self.Icon:SetAllPoints(self)
	self.Border:ClearAllPoints()
	self.Border:SetAllPoints(self.Icon)

	if db.borderColor ~= nil then
		self.Border:ClearAllPoints()
		self.Border:SetPoint("TOP", 0, 2)
		self.Border:SetPoint("RIGHT", 2, 0)
		self.Border:SetPoint("BOTTOM", 0, -2)
		self.Border:SetPoint("LEFT", -2, 0)

		if db.borderColor then
			local col = db.color
			self.Border:SetVertexColor(col.r, col.g, col.b, col.a)
			self.Border:Show()
			self.Border.col = col
		else
			local col = DebuffTypeColor[select(5, UnitAura("player", self.id, self.base)) or "none"]
			self.Border:SetVertexColor(col.r, col.g, col.b, col.a)
			self.Border:Show()
			self.Border.col = "dispell"
		end
	else
		self.Border:Hide()
		self.Border.col = nil
	end
end

function prototype:SetID(id)
	local base = self.base or "HELPFUL"
	self.id = id

	local _, _, icon, _, debuffType = UnitAura("player", self.id, base)
	self:SetNormalTexture(icon)

	if self.Border.col then
		if type(self.Border.col) == "table" then
			local col = self.Border.col
			self.Border:SetVertexColor(col.r, col.g, col.b, col.a)
		else
			local col = DebuffTypeColor[debuffType or "none"]
			self.Border:SetVertexColor(col.r, col.g, col.b, col.a)
		end
		self.Border:Show()
	elseif self.Border:IsShown() then
		self.Border:Hide()
	end

	Bollo.events:Fire("PostUpdateIcon", self)
end

function prototype:GetCount()
	return select(4, UnitAura("player", self.id, self.base))
end

function prototype:GetTimeleft()
	if not self.id then return 666 end      -- Assume config
	if not UnitAura("player", self.id, self.base) then
		return nil
	else
	        local _, _, _, _, _, _, expirationTime = UnitAura("player", self.id, self.base)
		return expirationTime and expirationTime> 0 and math.floor(expirationTime - GetTime() + 0.5)
	end
end

function prototype:SetBase(base)
	self.base = base
end

do
	local OnEnter = function(self)
		if self:IsShown() then
			GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT")
			GameTooltip:SetUnitAura("player", self.id, self.base)
		end
	end

	local OnLeave = function(self)
		GameTooltip:Hide()
	end

	local OnMouseUp = function(self, button)
		if button == "RightButton" then
			CancelPlayerBuff(self.id)
		end
	end

	function prototype:Init()
		self:EnableMouse(true)
		self:SetScript("OnMouseUp", OnMouseUp)
		self:SetScript("OnEnter", OnEnter)
		self:SetScript("OnLeave", OnLeave)
	end
end

local cache = setmetatable({}, {__mode = "k"})
function Bollo:NewIcon()
	local f = next(cache)
	if f then
		cache[f] = nil
	else
		f = setmetatable(CreateFrame("Button", nil, UIParent), {__index = prototype})
		f.modules = {}

		local i = f:CreateTexture(nil, "OVERLAY")
		i:SetAllPoints(f)
		i:SetTexture("")

		f.Icon = i

		local b = f:CreateTexture(nil, "OVERLAY")
		b:SetTexture([[Interface\Buttons\UI-Debuff-Overlays]])
		b:SetPoint("TOP", 0, 2)
		b:SetPoint("RIGHT", 2, 0)
		b:SetPoint("BOTTOM", 0, -2)
		b:SetPoint("LEFT", -2, 0)
		b:SetTexCoord(0.296875, 0.5703125, 0, 0.515625)
		b:Hide()

		f.Border = b

		f:Init()
	end

	f:Show()

	f:SetNormalTexture("")

	f:SetName(true)
	Bollo.events:Fire("ButtonCreated", f)

	return f
end

function Bollo:DelIcon(f)
	f:Hide()

	f.id = 0
	f.base = nil

	cache[f] = true
end
