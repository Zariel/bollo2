local Bollo = LibStub("AceAddon-3.0"):GetAddon("Bollo")

local new = function(c)
	local o = {}
	local mt = {__index = c}
	setmetatable(o, mt)
	return o
end

local class = function(parent)
	local c = { new = new }
	local mt = {__index = parent}
	setmetatable(c, mt)
	return c
end

-- Buff prototype
local IconPrototype = CreateFrame("Button", nil, UIParent)
local prototype = {}

do
	local cache = setmetatable({}, {__mode = "k"})
	local new = function()
		local f = next(cache)
		if f then
			cache[f] = nil
		else
			f = setmetatable(CreateFrame("Button", nil, UIParent), {__index = IconPrototype})
		end

		return f
	end

	local del = function(f)
		f:SetParent(UIParent)
		f:Hide()
		f:ClearAllPoints()

		cache[f] = true
	end

	function prototype:CreateIcon()
		local b = class(new())
		return b
	end

	function prototype:RemoveIcon(icon)
		return del(icon)
	end
end

local BuffProto = new(IconPrototype)
local DebuffProto = new(IconPrototype)

function BuffProto:Setup()
	self:SetScript("OnMouseUp", function(self, button)
		if button == "RightButton" then
			CancelPlayerBuff(self:GetID())
		end
	end)
end

function prototype:SetType(kind)
	if kind == "buff" then
		setmetatable(self, BuffProto)
		self:Setup()
	end
end


Bollo.Auras = class(prototype)
Bollo.Class = class
