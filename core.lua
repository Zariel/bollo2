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

local LCH = LibStub("CallbackHandler-1.0", true)

if not LCH then
	return error("Bollo requires CallbackHandler-1.0")
end

local Bollo = LibStub("AceAddon-3.0"):NewAddon("Bollo")

Bollo.class = class

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
end
