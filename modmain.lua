GLOBAL.setmetatable(
	env,
	{
		__index = function(t, k)
			return GLOBAL.rawget(GLOBAL, k)
		end
	}
)

--Tuning
TUNING.PERISH_ICE_CHEST_MULT = GetModConfigData("icechest_config")
TUNING.PERISH_COMPOST_BOX_MULT = GetModConfigData("compostbox_config")



PrefabFiles = 
{
	"ice_chest",
	"compost_box",
	"crate_material",
	"crate_wooden",
	"crate_metal",
	"trash_can",
	"charcoal_pit",
}

Assets = 
{
	Asset("ATLAS", "images/inventoryimages/ice_chest.xml"),
	Asset("ATLAS", "images/inventoryimages/compost_box.xml"),
	Asset("ATLAS", "images/inventoryimages/crate_material.xml"),
	Asset("ATLAS", "images/inventoryimages/crate_wooden.xml"),
	Asset("ATLAS", "images/inventoryimages/crate_metal.xml"),
	Asset("ATLAS", "images/inventoryimages/trash_can.xml"),
	Asset("ATLAS", "images/inventoryimages/charcoal_pit.xml"),
	Asset("ATLAS", "minimap/ice_chest.xml"),
	Asset("ATLAS", "minimap/compost_box.xml"),
	Asset("ATLAS", "minimap/crate_material.xml"),
	Asset("ATLAS", "minimap/crate_wooden.xml"),
	Asset("ATLAS", "minimap/crate_metal.xml"),
	Asset("ATLAS", "minimap/trash_can.xml"),
	Asset("ATLAS", "minimap/charcoal_pit.xml"),
	Asset("ANIM", "anim/ui_chest_2x2.zip"),
	Asset("ANIM", "anim/ui_chest_3x3.zip"),
	Asset("ANIM", "anim/ui_chest_4x4.zip"),
}

--Widget Setup for Chest UI

local containers = require "containers"

local params = {}

local function Make1x4Chest()
	local chest = {
		widget = {
			slotpos = {},
			animbank = "ui_cookpot_1x4",
			animbuild = "ui_cookpot_1x4",
			pos = GLOBAL.Vector3(200, 0, 0),
			side_align_tip = 160,
			buttoninfo = {
				text = "Destroy",
				position = Vector3(0, -165, 0),
				fn = function(inst)
					if inst.components.container then inst.components.container:DestroyContents() end
				end,
			}
		},
		type = "chest"
	}

	local positions = {GLOBAL.Vector3(0,64+32+8+4,0), GLOBAL.Vector3(0,32+4,0), GLOBAL.Vector3(0,-(32+4),0), GLOBAL.Vector3(0,-(64+32+8+4),0)}
	for i = 1, 4 do
		table.insert(chest.widget.slotpos, positions[i])
	end

	return chest
end


local function Make2x2Chest()
	local chest = {
		widget = {
			slotpos = {},
			animbank = "ui_chest_2x2",
			animbuild = "ui_chest_2x2",
			pos = GLOBAL.Vector3(0, 200, 0),
			side_align_tip = 160
		},
		type = "chest"
	}

	for y = 1, 2, 1 do
		for x = 0, 1 do
			table.insert(chest.widget.slotpos, GLOBAL.Vector3(75*x-75*2+112, 75*y-75*2+75,0))
		end
	end

	return chest
end

local function Make3x3Chest()
	local chest = {
		widget = {
			slotpos = {},
			animbank = "ui_chest_3x3",
			animbuild = "ui_chest_3x3",
			pos = GLOBAL.Vector3(0, 200, 0),
			side_align_tip = 160
		},
		type = "chest"
	}

	for y = 2, 0, -1 do
		for x = 0, 2 do
			table.insert(chest.widget.slotpos, GLOBAL.Vector3(80*x-80*2+80, 80*y-80*2+80,0))
		end
	end

	return chest
end

--3x3 crate  w/ button
--local function Make3x3CrateChest()
--	local chest = {
--		widget = {
--			slotpos = {},
--			animbank = "ui_chest_3x3",
--			animbuild = "ui_chest_3x3",
--			pos = GLOBAL.Vector3(0, 200, 0),
--			side_align_tip = 160,
--			buttoninfo = {
--				text = "Hammer",
--				position = Vector3(0, -135, 0),
--				fn = function(inst)
--				    if inst.components.container ~= nil then
--				        inst.components.container:DropEverything()
--				    end
--				    inst.components.lootdropper:DropLoot()
--				    local fx = SpawnPrefab("collapse_small")
--				    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
--				    fx:SetMaterial("metal")
--				    inst:Remove()
--				end,
--			}
--		},
--		type = "chest"
--	}
--
--	for y = 2, 0, -1 do
--		for x = 0, 2 do
--			table.insert(chest.widget.slotpos, GLOBAL.Vector3(80*x-80*2+80, 80*y-80*2+80,0))
--		end
--	end
--
--	return chest
--end
--

local function Make4x4Chest()
	local chest = {
		widget = {
			slotpos = {},
			animbank = "ui_chest_4x4",
			animbuild = "ui_chest_4x4",
			pos = GLOBAL.Vector3(0, 200, 0),
			side_align_tip = 160
		},
		type = "chest"
	}

	for y = 3, 0, -1 do
		for x = 0, 3 do
			table.insert(chest.widget.slotpos, GLOBAL.Vector3(80*x-80*2+40, 80*y-80*2+40,0))
		end
	end

	return chest
end

local old_containers_widgetsetup = containers.widgetsetup
function containers.widgetsetup(container, prefab, data, ...)
	local t = params[prefab or container.inst.prefab]
	if t ~= nil then
		for k, v in pairs(t) do
			container[k] = v
		end
		container:SetNumSlots(container.widget.slotpos ~= nil and #container.widget.slotpos or 0)
	else
		old_containers_widgetsetup(container, prefab, data, ...)
	end
end

--End

params.ice_chest = Make4x4Chest()
AddRecipe2("ice_chest", 
	{
		Ingredient("cutstone", 						5),
		Ingredient("gears", 						5),
		Ingredient("ice",							5),
	}, 
	TECH.SCIENCE_ONE, "ice_chest_placer", {"CONTAINERS"})
	RegisterInventoryItemAtlas("images/inventoryimages/ice_chest.xml", "ice_chest.tex")
	STRINGS.NAMES.ICE_CHEST = "Ice Chest"

params.compost_box = Make2x2Chest()
AddRecipe2("compost_box", 
	{
			Ingredient("spoiled_food", 				20), 
			Ingredient("boards", 					2),
	}, 
	TECH.SCIENCE_ONE, "compost_box_placer", {"GARDENING"})
	RegisterInventoryItemAtlas("images/inventoryimages/compost_box.xml", "compost_box.tex")
	STRINGS.NAMES.COMPOST_BOX = "Compost Box"

params.crate_material = Make4x4Chest() 
AddRecipe2("crate_material", 
	{
			Ingredient("boards", 					2), 
			Ingredient("rope", 						1),
			Ingredient("shovel", 					1),
	}, 
	TECH.SCIENCE_ONE, "crate_material_placer", {"CONTAINERS"})
	RegisterInventoryItemAtlas("images/inventoryimages/crate_material.xml", "crate_material.tex")
	STRINGS.NAMES.CRATE_MATERIAL = "Pitcrate"

params.crate_wooden = Make3x3Chest()
AddRecipe2("crate_wooden", 
	{
		Ingredient("boards", 						6), 
		Ingredient("rope", 							2),
	}, 
	TECH.SCIENCE_ONE, "crate_wooden_placer", {"CONTAINERS"})
	RegisterInventoryItemAtlas("images/inventoryimages/crate_wooden.xml", "crate_wooden.tex")
	STRINGS.NAMES.CRATE_WOODEN = "Wooden Crate"

params.crate_metal = Make3x3Chest()
AddRecipe2("crate_metal", 
	{
		Ingredient("cutstone", 						1), 
		Ingredient("gears", 						1), 
		Ingredient("marble",						2),
	}, 
	TECH.SCIENCE_ONE, "crate_metal_placer", {"CONTAINERS"})
	RegisterInventoryItemAtlas("images/inventoryimages/crate_metal.xml", "crate_metal.tex")
	STRINGS.NAMES.CRATE_METAL = "Metal Crate"

params.trash_can = Make1x4Chest()
AddRecipe2("trash_can", 
	{
		Ingredient("cutstone", 						4),
	}, 
	TECH.SCIENCE_ONE, "trash_can_placer", {"CONTAINERS"})
	RegisterInventoryItemAtlas("images/inventoryimages/trash_can.xml", "trash_can.tex")
	STRINGS.NAMES.TRASH_CAN = "Trash Can"
	

AddRecipe2("charcoal_pit", 
	{
		Ingredient("cutstone", 						2),
		Ingredient("charcoal", 						8),
		Ingredient("rocks", 						12),
	}, 
	TECH.SCIENCE_ONE, "charcoal_pit_placer", {"REFINE"})
	RegisterInventoryItemAtlas("images/inventoryimages/charcoal_pit.xml", "charcoal_pit.tex")
	STRINGS.NAMES.CHARCOAL_PIT = "Charcoal Pit"
	 

--
	AddMinimapAtlas("images/inventoryimages/ice_chest.xml")
	AddMinimapAtlas("images/inventoryimages/compost_box.xml")
	AddMinimapAtlas("images/inventoryimages/crate_material.xml")
	AddMinimapAtlas("images/inventoryimages/crate_wooden.xml")
	AddMinimapAtlas("images/inventoryimages/crate_metal.xml")
	AddMinimapAtlas("images/inventoryimages/trash_can.xml")	
	AddMinimapAtlas("images/inventoryimages/charcoal_pit.xml")	
