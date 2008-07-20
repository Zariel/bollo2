local bollo = LibStub("AceAddon-3.0"):GetAddon("Bollo")
local Dummy = bollo:NewModule("Dummy")

function Dummy:OnEnable()
	self:CreateDummy("buff")
end

function Dummy:CreateDummy(name)
	if not bollo.icons[name] then return end

	for i = #bollo.icons[name], 40 do
		local b = bollo:New(bollo.icons[name)
		b:SetBuff(i, "HELPFUL")
	end
end
