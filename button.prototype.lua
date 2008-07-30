local addon = LibStub("AceAddon-3.0"):GetAddon("Bollo")
local iconprototype = addon.class(CreateFrame("Button"))
local prototype = {}
local count = 0

local bases = {
	["buff"] = true,
	["debuff"] = true,
}

local subTypes = {
	"id",
	"name",
	"timeLeft",
	"duration",
	"unit",
	"base",
	"icon",
	"uid",
	"rank",
}

do
	local cache = setmetatable({},{__mode = "k"})
	function prototype:NewIcon()
		local f = next(cache)
		if f then
			cache[f] = nil
		else
			f = CreateFrame("Button", nil, UIParent)
			f.info = {}
		end

		setmetatable(f, {__index = iconprototype})

		for _, v in ipairs(subTypes) do
			f.info[v] = false
		end

		count = count + 1

		return f, count
	end

	function prototype:DelIcon(icon)
		icon:Reset()

		cache[icon] = true

		count = count - 1

		return count
	end
end

function iconprototype:SetUnit(unit)
	if type(unit) ~= "string" then
		return
	end

	self.info.unit = unit
end

function iconprototype:SetID(id)
	if type(id) ~= "number" then
		return
	end

	self.info.id = id
end

function iconprototype:SetBase(base)
	if not bases[base] then
		return
	end

	self.info.base = base
end

function iconprototype:Update()
	if type(self.info.id) ~= "number" then
		return error("ID must be set before update")
	end

	if type(self.info.unit) ~= "string" then
		return error("Unit must be set before update")
	end

	local name, rank, icon, count, duration, timeLeft = UnitBuff(self.info.unit, self.info.id)
	self.info.name = name
	self.info.rank = rank
	self.info.icon = icon
	self.info.count = count
	self.info.duration = duration
	self.info.timeLeft = timeLeft
	self.info.uid = count

	return true
end

function iconprototype:Reset()
	for _, sub in ipairs(subTypes) do
		self.info[sub] = nil
	end

	self:Hide()
	self:ClearAllPoints()

	return true
end

addon.Auras = addon.class(prototype)
