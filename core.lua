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

local new, del
do
	local cache = setmetatable({}, {__mode = "k"})
	new = function()
		local t = next(cache)
		if t then
			cache[t] = nil
		else
			t = {}
		end
		return t
	end

	del = function(t)
		for k, v in pairs(t) do
			if type(v) == "table" then
				del(v)
			end
			t[k] = nil
		end
		cache[t] = true
		return nil
	end
end


local LCH = LibStub("CallbackHandler-1.0", true)
assert(LCH, "Bollo requires CallbackHandler-1.0")

local Bollo = LibStub("AceAddon-3.0"):NewAddon("Bollo2", "AceEvent-3.0")

Bollo.New, Bollo.Del = new, del
Bollo.Class = class

function Bollo:OnInitialize()
	self.events = LCH:New(Bollo)
	self.db = LibStub("AceDB-3.0"):New("BolloDB2", {})

	self.frame = CreateFrame("Frame")

	local timer = 1

	local OnUpdate = function(self, elapsed)
		if timer >= 1 then
			Bollo.events:Fire("OnUpdate")
		else
			timer = timer + elapsed
		end
	end

	function Bollo.events:OnUsed(target, event)
		if event == "OnUpdate" then
			Bollo.frame:SetScript("OnUpdate", OnUpdate)
		end
	end

	function Bollo.events:OnUnuse(target, event)
		if event == "OnUpdate" then
			Bollo.frame:SetScript("OnUpdate", nil)
		end
	end
end

function Bollo:OnEnable()
	local bf = _G["BuffFrame"]
	bf:UnregisterAllEvents()
	bf:Hide()
	bf:SetScript("OnUpdate", nil)
	bf:SetScript("OnEvent", nil)
	_G.BuffButton_OnUpdate = nil

	local defaults = {
		profile = {
			max = 40,
			perRow = 20,
			size = 32,
			spacing = 20,
			rowSpacing = 25,
			growthX = "LEFT",
			growthY = "DOWN",
			scale = 1,
			x = 0,
			y = 0,
			color = {
				r = 0,
				g = 1,
				b = 1,
				a = 0
			},
		},
	}

	self:NewDisplay("Buff", "HELPFUL", defaults)
	Bollo:RegisterEvent("PLAYER_AURAS_CHANGED")
end


function Bollo:PLAYER_AURAS_CHANGED()
	for _, mod in ipairs(self.registry) do
		mod:Update()
	end
end
