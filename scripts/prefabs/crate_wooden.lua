require "prefabutil"

local assets =
{
	Asset("ANIM", "anim/crate_wooden.zip"),
	Asset("ATLAS", "images/inventoryimages/crate_wooden.xml"),
}

local prefabs =
{
	"collapse_small",
}

local function onopen(inst)
	if not inst:HasTag("burnt") then
		inst.AnimState:PlayAnimation("open")
		inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_open")	
	end
end 

local function onclose(inst) 
	if not inst:HasTag("burnt") then
		inst.AnimState:PlayAnimation("close")
		inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_close")		
	end
end 

local function onhammered(inst, worker)
	if inst:HasTag("fire") and inst.components.burnable then
		inst.components.burnable:Extinguish()
	end
	inst.components.lootdropper:DropLoot()
	if 
		inst.components.container then inst.components.container:DropEverything() 
	end
	
	SpawnPrefab("collapse_small").Transform:SetPosition(inst.Transform:GetWorldPosition())
	inst.SoundEmitter:PlaySound("dontstarve/common/destroy_wood")
	inst:Remove()
end

local function onhit(inst, worker)
	if not inst:HasTag("burnt") then
		inst.AnimState:PlayAnimation("hit")
		inst.AnimState:PushAnimation("closed", false)
		if inst.components.container then 
			inst.components.container:DropEverything() 
			inst.components.container:Close()
		end
	end
end

local function onsave(inst, data)
	if inst:HasTag("burnt") or inst:HasTag("fire") then
        data.burnt = true
    end
end

local function onload(inst, data)
	if data and data.burnt then
        inst.components.burnable.onburnt(inst)
    end
end

local function onbuilt(inst)
	inst.AnimState:PlayAnimation("place")
	inst.AnimState:PushAnimation("closed", false)
end

local function fn(Sim)
	local inst = CreateEntity()

    inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()
	
	MakeObstaclePhysics(inst, .3)
			
	inst.MiniMapEntity:SetIcon("crate_wooden.tex")
	
	inst:AddTag("structure")
	inst:AddTag("chest")

    inst.AnimState:SetBank("crate_wooden")
    inst.AnimState:SetBuild("crate_wooden")
    inst.AnimState:PlayAnimation("close")

    MakeSnowCoveredPristine(inst)

    inst:ListenForEvent("onbuilt", onbuilt)

    if not TheWorld.ismastersim then
        return inst
    end

    inst.entity:SetPristine()
    
    inst:AddComponent("inspectable")

    inst:AddComponent("container")
    inst.components.container:WidgetSetup("crate_wooden")
    inst.components.container.onopenfn = onopen
    inst.components.container.onclosefn = onclose
    inst.components.container.skipclosesnd = true
    inst.components.container.skipopensnd = true

    inst:AddComponent("lootdropper")
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(6)
    inst.components.workable:SetOnFinishCallback(onhammered)
    inst.components.workable:SetOnWorkCallback(onhit) 
	
	MakeMediumBurnable(inst, nil, nil, true)
	MakeLargePropagator(inst)

    return inst
end

STRINGS.NAMES.CRATE_WOODEN 									= "Wooden Crate"
STRINGS.RECIPE_DESC.CRATE_WOODEN 							= "Now we are talking storage."

STRINGS.CHARACTERS.GENERIC.DESCRIBE.CRATE_WOODEN 			= "No key required."
STRINGS.CHARACTERS.WILLOW.DESCRIBE.CRATE_WOODEN 			= "Tempting to burn."
STRINGS.CHARACTERS.WOLFGANG.DESCRIBE.CRATE_WOODEN 			= "Wolfgang sees large box for many items."
STRINGS.CHARACTERS.WENDY.DESCRIBE.CRATE_WOODEN 				= "A box full of treasure... or junk."
STRINGS.CHARACTERS.WX78.DESCRIBE.CRATE_WOODEN 				= "LARGE STORAGE UNIT"
STRINGS.CHARACTERS.WICKERBOTTOM.DESCRIBE.CRATE_WOODEN 		= "An ordinary storage container for items."
STRINGS.CHARACTERS.WOODIE.DESCRIBE.CRATE_WOODEN 			= "I can store ma' junk in here."
STRINGS.CHARACTERS.WAXWELL.DESCRIBE.CRATE_WOODEN 			= "A box made of junk, for junk."

return	Prefab("crate_wooden", fn, assets, prefabs),
		MakePlacer("crate_wooden_placer", "crate_wooden", "crate_wooden", "closed") 
