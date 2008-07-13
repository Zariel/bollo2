local bollo = LibStub("AceAddon-3.0"):GetAddon("Bollo")

local prototype = CreateFrame("Frame")

--[[
	New
		Create a new icon with border, texture
]]

local New = function()
	local button = CreateFrame("Button", nil, UIParent)
	button:SetHeight(20)
	button:SetWidth(20)

	local icon = button:CreateTexture(nil, "BACKGROUND")
	icon:SetAllPoints(button)

	local border = button:CreateTextire(nil, "OVERLAY")
	border:SetAllPoints(button)

	button.icon = icon
	button.border = border

	setmetatable(button, {__index = prototype})

	bollo.events:Fire("PostCreateIcon", button)
end

--[[
	SetBuff (index, type)
		index - ID of the aura
		filter - buff temp)
		Sets the buff
]]
function prototype:SetBuff(index)

end
