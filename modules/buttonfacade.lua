local Bollo = LibStub("AceAddon-3.0"):GetAddon("Bollo2")
local BF = Bollo:NewModule("ButtonFacade")
local lib = LibStub("LibButtonFacade-1.0", true)

local BaseToName = {
	"HARMFUL" = "Debuff",
	"HELPFUL" = "Buff",
}

function BF:OnInitialize()
	if lib then
		self.db = Bollo.db:RegisterNamespace("Buttonfacade", {})
	end
end

function BF:OnEnable()
	assert(lib, "Buttonfacade module requires LibButtonFacade-1.0")
	Bollo.RegisterCallback(self, "ButtonCreated")
	lib:RegisterSkinCallback("Bollo2", self.UpdateSkin, self)
end

function BF:Register(module, defaults)
	local name = tostring(module)
	if not self.registered[name] then
		self.registered[name] = module

		for i, buff in ipairs(module.icons) do
			self:ButtonCreated(buff)
		end
	end
end

function BF:UpdateSkin(SkinID, Gloss, Backdrop, Group, Button, Colors)
	if Group then
		self.db.profile[Group] = self.db.profile[Group] or {}
		local db = self.db.profile[Group]
		db[1] = SkinID
		db[2] = Gloss
		db[3] = Backdrop
		db[4] = Colors
	end
end

function BF:ButtonCreated(button)
	button.name = BaseToName[button.base]

	local G = lib:Group("Bollo2", button.name)

	G:AddButton(button)

	if self.db.profile[button.name] then
		local db = self.db.profile[button.name]
		G:Skin(unpack(db))
	end
end
