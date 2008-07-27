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

local Bollo = LibStub("AceAddon-3.0"):NewAddon("Bollo")
Bollo.class = class

function Bollo:OnEnable()
	local bf = _G["BuffFrame"]
	bf:UnregisterAllEvents()
	bf:Hide()
	bf:SetScript("OnUpdate", nil)
	bf:SetScript("OnEvent", nil)
	_G.BuffButton_OnUpdate = nil
end
