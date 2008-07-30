local Bollo = LibStub("AceAddon-3.0"):GetAddon("Bollo")
local class = Bollo.class

local UnitBuff = UnitBuff

local IconPrototype = CreateFrame("Button", nil, UIParent)
local BuffProto = class(IconPrototype)
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
			f.modules = {}
		end

		f:SetType(type)
		f:Setup()

		Bollo.events:Fire("PostCreateIcon", f)

		return f
	end

	local del = function(f)
		f:Hide()
		f:SetID(0)
		f:SetNormalTexture("")
		f:ClearAllPoints()
		for k, v in pairs(f.modules) do

			v:Hide()
			v:ClearAllPoints()
		end

		cache[f] = true
	end

	function prototype:CreateIcon(type)
		return new(type)
	end

	function prototype:RemoveIcon(icon)
		return del(icon)
	end
end

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
			CancelPlayerBuff(self.name)
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

function BuffProto:GetBuff()
	local name, rank = UnitBuff("player", self:GetID())
	self.name, self.rank = name, rank
	return name, rank
end

function BuffProto:GetTimeLeft()
	local timeleft = tonumber(math.floor((select(6, UnitBuff("player", self:GetID())) or 0) + 0.5))
	self.timeleft = timeleft
	return timeleft
end

function BuffProto:Update(id)
	local name, rank, icon, count, duration, timeleft = UnitBuff("player", id)

	if not name or name == "" then
		self:SetID(0)
		return true
	end

	self:SetID(id)

	self.name = name
	self.rank = rank
	self.icon = icon
	self.duration = duration
	self.timeleft = timeleft or 0

	self:SetNormalTexture(icon)

	self:Show()
end

function IconPrototype:SetType(kind)
	if kind == "buff" then
		setmetatable(self, {__index = BuffProto})
		self.type = kind
	end
end

function prototype:CreateBackground(name)
	if self.bg then return self.bg end

	local bg = CreateFrame("Frame", nil, UIParent)
	bg:SetHeight(75)
	bg:SetWidth(300)
	bg:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT")

	return setmetatable({
		bg = bg
	},{
		__tostring = function() return name end
	})
end

Bollo.Auras = class(prototype)
