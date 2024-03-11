require "prefabutil"

local assets =
{
	Asset("ANIM", "anim/crate_material.zip"),
}

local prefabs =
{
	"collapse_small",
}

local function onopen(inst)
	inst.AnimState:PlayAnimation("open")
	inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_open")	
end 

local function onclose(inst) 
	inst.AnimState:PlayAnimation("close")
	inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_close")		
end

local function onhammered(inst, worker)
    if inst.components.container ~= nil then
        inst.components.container:DropEverything()
    end
    local fx = SpawnPrefab("collapse_small")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("wood")
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

local function fn(Sim)
	local inst = CreateEntity()

    inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	inst.entity:AddMiniMapEntity()
	inst.entity:AddNetwork()
	
	MakeObstaclePhysics(inst, .3)
		
	inst.MiniMapEntity:SetIcon("crate_material.tex")
	
	inst:AddTag("structure")
	inst:AddTag("chest")

    inst.AnimState:SetBank("crate_material")
    inst.AnimState:SetBuild("crate_material")
    inst.AnimState:PlayAnimation("close")
    
	MakeSnowCoveredPristine(inst)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:ListenForEvent("onbuilt", onbuilt)
    MakeSnowCovered(inst)

    inst:AddComponent("inspectable")

	inst:AddComponent("container")
    inst.components.container:WidgetSetup("crate_material")
    inst.components.container.onopenfn = onopen
    inst.components.container.onclosefn = onclose
    inst.components.container.skipclosesnd = true
    inst.components.container.skipopensnd = true

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(4)
    inst.components.workable:SetOnFinishCallback(onhammered)
    inst.components.workable:SetOnWorkCallback(onhit)
	
    return inst
end

STRINGS.NAMES.CRATE_MATERIAL 							= "Pitcrate"
STRINGS.RECIPE_DESC.CRATE_MATERIAL 						= "For storing the most basic of materials."

STRINGS.CHARACTERS.GENERIC.DESCRIBE.CRATE_MATERIAL 		= "Now I can dump my items without worry."
STRINGS.CHARACTERS.WILLOW.DESCRIBE.CRATE_MATERIAL 		= "It's dark inside. It needs fire!"
STRINGS.CHARACTERS.WOLFGANG.DESCRIBE.CRATE_MATERIAL 	= "Is dirty hole."
STRINGS.CHARACTERS.WENDY.DESCRIBE.CRATE_MATERIAL 		= "It's deep and dark as my soul."
STRINGS.CHARACTERS.WX78.DESCRIBE.CRATE_MATERIAL 		= "MATERIAL STORAGE UNIT"
STRINGS.CHARACTERS.WICKERBOTTOM.DESCRIBE.CRATE_MATERIAL = "A protective way to store refined items."
STRINGS.CHARACTERS.WOODIE.DESCRIBE.CRATE_MATERIAL 		= "It's a hole in the ground."
STRINGS.CHARACTERS.WAXWELL.DESCRIBE.CRATE_MATERIAL 		= "Why did I not think of this before?"

return	Prefab("crate_material", fn, assets, prefabs),
		MakePlacer("crate_material_placer", "crate_material", "crate_material", "closed") 
