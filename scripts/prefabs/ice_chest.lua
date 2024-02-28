require "prefabutil"

local assets =
{
	Asset("ANIM", "anim/ice_chest.zip"),
}

local prefabs =
{
	"collapse_small",
}

local function onopen(inst)
    inst.AnimState:PlayAnimation("open")
    inst.SoundEmitter:PlaySound("dontstarve/common/icebox_open")
end

local function onclose(inst)
    inst.AnimState:PlayAnimation("close")
    inst.SoundEmitter:PlaySound("dontstarve/common/icebox_close")
end

local function onhammered(inst, worker)
    inst.components.lootdropper:DropLoot()
    inst.components.container:DropEverything()
    local fx = SpawnPrefab("collapse_small")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("metal")
    inst:Remove()
end

local function onhit(inst, worker)
    inst.AnimState:PlayAnimation("hit")
    inst.components.container:DropEverything()
    inst.AnimState:PushAnimation("closed", false)
    inst.components.container:Close()
end

local function onbuilt(inst)
    inst.AnimState:PlayAnimation("place")
    inst.AnimState:PushAnimation("closed", false)
    inst.SoundEmitter:PlaySound("dontstarve/common/icebox_craft")
end

local function itemtest(inst, item, slot)
	return (item.components.edible and item.components.perishable) or 
	item.prefab == "spoiled_food" or 
	item.prefab == "rottenegg" or 
	item.prefab == "heatrock" or 
	item:HasTag("frozen") or
	item:HasTag("icebox_valid") or
	item:HasTag("saltbox_valid")
end

local function fn()
	local inst = CreateEntity()
	
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    MakeObstaclePhysics(inst, .3)

	inst.MiniMapEntity:SetIcon("ice_chest.tex")
	
	inst:AddTag("fridge")
    inst:AddTag("structure")

    inst.AnimState:SetBank("ice_chest")
    inst.AnimState:SetBuild("ice_chest")
    inst.AnimState:PlayAnimation("close")
    
    inst.SoundEmitter:PlaySound("dontstarve/common/ice_box_LP", "idlesound")

    MakeSnowCoveredPristine(inst)

    inst:ListenForEvent("onbuilt", onbuilt)

    if not TheWorld.ismastersim then
        return inst
    end

    inst.entity:SetPristine()


    inst:AddComponent("inspectable")

    inst:AddComponent("lootdropper")

	inst:AddComponent("preserver")
	inst.components.preserver:SetPerishRateMultiplier(TUNING.PERISH_ICE_CHEST_MULT)

    inst:AddComponent("container")
    inst.components.container:WidgetSetup("ice_chest")
    inst.components.container.onopenfn = onopen
    inst.components.container.onclosefn = onclose
    inst.components.container.skipclosesnd = true
    inst.components.container.skipopensnd = true

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(6)
    inst.components.workable:SetOnFinishCallback(onhammered)
    inst.components.workable:SetOnWorkCallback(onhit) 	
	
    return inst
end

STRINGS.RECIPE_DESC.ICE_CHEST                           = "It's like a box full of snow."

STRINGS.CHARACTERS.GENERIC.DESCRIBE.ICE_CHEST           = "Smells like winter."
STRINGS.CHARACTERS.WILLOW.DESCRIBE.ICE_CHEST            = "Not something I prefer being next to."
STRINGS.CHARACTERS.WOLFGANG.DESCRIBE.ICE_CHEST          = "Is big enough to store much food."
STRINGS.CHARACTERS.WENDY.DESCRIBE.ICE_CHEST             = "It may be cold as my heart."
STRINGS.CHARACTERS.WX78.DESCRIBE.ICE_CHEST              = "CONTINUE, MY COLD BROTHER"
STRINGS.CHARACTERS.WICKERBOTTOM.DESCRIBE.ICE_CHEST      = "Stores more supplies than a regular Ice Box."
STRINGS.CHARACTERS.WOODIE.DESCRIBE.ICE_CHEST            = "Ahhhh. Closer to home as it can get."
STRINGS.CHARACTERS.WAXWELL.DESCRIBE.ICE_CHEST           = "A small snow storm in a box."

return	Prefab("ice_chest", fn, assets, prefabs),
		MakePlacer("ice_chest_placer", "ice_chest", "ice_chest", "closed") 
