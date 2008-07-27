local Bollo = LibStub("AceAddon-3.0"):GetAddon("Bollo")

local UnitBuff = UnitBuff

local class
do
	local new = function(c)
		local o = {}
		local mt = {__index = c}
		setmetatable(o, mt)
		return o
	end

	class = function(parent)
		local c = { new = new }
		local mt = {__index = parent}
		setmetatable(c, mt)
		return c
	end
end

local IconPrototype = CreateFrame("Button", nil, UIParent)

local prototype = {}

do
	local cache = setmetatable({}, {__mode = "k"})
	local new = function(type)
		local f = next(cache)
		if f then
			cache[f] = nil
			f:Show()
		else
			f = setmetatable(CreateFrame("Button", nil, UIParent), {__index = IconPrototype})
		end

		f:SetType(type)
		f:Setup()

		return f
	end

	local del = function(f)
		f:Hide()
		f:SetID(0)
		f:SetNormalTexture("")
		f:ClearAllPoints()

		cache[f] = true
	end

	function prototype:CreateIcon(type)
		return new(type)
	end

	function prototype:RemoveIcon(icon)
		return del(icon)
	end
end

local BuffProto = class(IconPrototype)

do
	local OnEnter = function(self)
		if self:IsShown() then
			GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT")
			GameTooltip:SetUnitBuff("player", self:GetID())
			GameTooltip:Show()
		end
	end

	local OnLeave = function(self)
		if GameTooltip:IsOwned(self) then
			GameTooltip:Hide()
		end
	end

	local OnMouseUp = function(self, button)
		if button == "RightButton" then
			CancelPlayerBuff(self:GetID())
		end
	end

	function BuffProto:Setup()
		self:SetHeight(32)
		self:SetWidth(32)

		self:SetScript("OnEnter", OnEnter)
		self:SetScript("OnLeave", OnLeave)
		self:SetScript("OnMouseUp", OnMouseUp)
	end
end

function BuffProto:SetBuff(index)
	self:SetID(index)
	local name, rank, icon = UnitBuff("player", index)
	self:SetNormalTexture(icon)
end

function BuffProto:GetBuff()
	local n, r = UnitBuff("player", self:GetID())
	return n, r
end

function IconPrototype:SetType(kind)
	if kind == "buff" then
		setmetatable(self, {__index = BuffProto})
		self.type = kind
	end
end

function prototype:CreateBackground()
	if self.bg then return self.bg end

	local bg = CreateFrame("Frame", nil, UIParent)
	bg:SetHeight(75)
	bg:SetWidth(300)
	bg:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT")

	return { bg = bg }
end

Bollo.Auras = class(prototype)
