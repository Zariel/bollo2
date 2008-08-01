local Bollo = LibStub("AceAddon-3.0"):GetAddon("Bollo")
local prototype = CreateFrame("Button", nil, UIParent)
Bollo.IconPrototype = prototype

function prototype:Setup(db)
	local size = db.size
	self:SetHeight(size)
	self:SetWidth(size)
	self:SetScale(db.scale)
end

function prototype:SetID(id)
	local base = self.base or "HELPFUL"
	self.id = GetPlayerBuff(id, base)

	local icon = GetPlayerBuffTexture(self.id)
	self:SetNormalTexture(icon)
end

function prototype:SetBase(base)
	self.base = base
end

local cache = setmetatable({}, {__mode = "k"})
function Bollo:NewIcon()
	local f = next(cache)
	if f then
		cache[f] = nil
	else
		f = setmetatable(CreateFrame("Button", nil, UIParent), {__index = prototype})
	end

	f:Show()

	return f
end

function Bollo:DelIcon(f)
	f:Hide()

	f.id = 0
	f.base = nil

	cache[f] = true
end
