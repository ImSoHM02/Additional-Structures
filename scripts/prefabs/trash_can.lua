require "prefabutil"

local assets =
{
	Asset("ANIM", "anim/trash_can.zip"),
	Asset("ATLAS", "images/inventoryimages/trash_can.xml"),
}

local prefabs =
{
	"collapse_small",
}

local function onopen(inst)
	inst.AnimState:PlayAnimation("open")
	inst.SoundEmitter:PlaySound("dontstarve/common/cookingpot_open", "open")
end 

local function onclose(inst) 
	inst.AnimState:PlayAnimation("close")
	inst.SoundEmitter:PlaySound("dontstarve/common/cookingpot_close", "close")	
end 

local function onhammered(inst, worker)
	if inst:HasTag("fire") and inst.components.burnable then
		inst.components.burnable:Extinguish()
	end
	inst.components.lootdropper:DropLoot()
	if inst.components.container then inst.components.container:DropEverything() end
	SpawnPrefab("collapse_small").Transform:SetPosition(inst.Transform:GetWorldPosition())
	inst.SoundEmitter:PlaySound("dontstarve/common/destroy_metal")
	inst:Remove()
end

local function onhit(inst, worker)
	inst.AnimState:PlayAnimation("hit")
	inst.AnimState:PushAnimation("closed", false)
	if inst.components.container then 
		inst.components.container:DropEverything() 
		inst.components.container:Close()
	end
end

local function onbuilt(inst)
	inst.AnimState:PlayAnimation("place")
	inst.AnimState:PushAnimation("closed", false)
end

local function itemtest(inst, item, slot)
		if item:HasTag("irreplaceable") or
		item.prefab == "lighter" or
		item.prefab == "abigail_flower" or
		item.prefab == "balloons_empty" or
		item.prefab == "waxwelljournal" or
		item.prefab == "lucy"
		then
			return false
		end
	return true
end

local function fn(Sim)
	local inst = CreateEntity()
    inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()
	
	MakeObstaclePhysics(inst, .1)
		

	inst.MiniMapEntity:SetIcon("trash_can.tex")
	
	inst:AddTag("structure")
	inst:AddTag("chest")
	
    inst.AnimState:SetBank("trash_can")
    inst.AnimState:SetBuild("trash_can")
    inst.AnimState:PlayAnimation("close")

    MakeSnowCoveredPristine(inst)

    inst:ListenForEvent("onbuilt", onbuilt)

    if not TheWorld.ismastersim then
        return inst
    end

    inst.entity:SetPristine()

    
    inst:AddComponent("inspectable")
	inst:AddComponent("container")
    inst.components.container:WidgetSetup("trash_can")
    inst.components.container.onopenfn = onopen
    inst.components.container.onclosefn = onclose
    inst.components.container.skipclosesnd = true
    inst.components.container.skipopensnd = true

    inst:AddComponent("lootdropper")
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(2)
    inst.components.workable:SetOnFinishCallback(onhammered)
    inst.components.workable:SetOnWorkCallback(onhit)
	
    return inst
end

STRINGS.RECIPE_DESC.TRASH_CAN 							= "What goes in does not come out."

STRINGS.CHARACTERS.GENERIC.DESCRIBE.TRASH_CAN 			= "It's a bottomless pit-in-a-can."
STRINGS.CHARACTERS.WILLOW.DESCRIBE.TRASH_CAN 			= "How deep does this go?"
STRINGS.CHARACTERS.WOLFGANG.DESCRIBE.TRASH_CAN 			= "Is good for useless junk."
STRINGS.CHARACTERS.WENDY.DESCRIBE.TRASH_CAN 			= "I can see only darkness within."
STRINGS.CHARACTERS.WX78.DESCRIBE.TRASH_CAN 				= "DELETES UNWANTED ITEMS"
STRINGS.CHARACTERS.WICKERBOTTOM.DESCRIBE.TRASH_CAN 		= "A container to dispose of unneeded items."
STRINGS.CHARACTERS.WOODIE.DESCRIBE.TRASH_CAN 			= "Junk goes in."
STRINGS.CHARACTERS.WAXWELL.DESCRIBE.TRASH_CAN 			= "Keeps the place clean and orderly."

return	Prefab("trash_can", fn, assets, prefabs),
		MakePlacer("trash_can_placer", "trash_can", "trash_can", "closed") 
