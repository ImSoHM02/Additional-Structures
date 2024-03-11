require "prefabutil"

local assets =
{
	Asset("ANIM", "anim/crate_metal.zip"),	
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
	inst.components.lootdropper:DropLoot()
    inst.components.container:DropEverything()
    local fx = SpawnPrefab("collapse_small")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("metal")
    inst:Remove()
end

local function onhit(inst, worker)
	inst.AnimState:PlayAnimation("hit")
	inst.AnimState:PushAnimation("closed", false)
	inst.components.container:Close()
end

local function onbuilt(inst)
	inst.AnimState:PlayAnimation("place")
	inst.AnimState:PushAnimation("closed", false)
end

local function fn()
	local inst = CreateEntity()

    inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()
		
	inst.MiniMapEntity:SetIcon("crate_metal.tex")
	
	inst:AddTag("structure")
	inst:AddTag("chest")

    inst.AnimState:SetBank("crate_metal")
    inst.AnimState:SetBuild("crate_metal")
    inst.AnimState:PlayAnimation("closed")
    
    MakeSnowCoveredPristine(inst)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")
	inst:AddComponent("container")
    inst.components.container:WidgetSetup("crate_metal")
    inst.components.container.onopenfn = onopen
    inst.components.container.onclosefn = onclose
    inst.components.container.skipclosesnd = true
    inst.components.container.skipopensnd = true

    inst:AddComponent("lootdropper")
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(8)
    inst.components.workable:SetOnFinishCallback(onhammered)
    inst.components.workable:SetOnWorkCallback(onhit)
	
    inst:ListenForEvent("onbuilt", onbuilt)
    MakeSnowCovered(inst)

    return inst
end

STRINGS.RECIPE_DESC.CRATE_METAL 						= "A fireproof metal box."

STRINGS.CHARACTERS.GENERIC.DESCRIBE.CRATE_METAL 		= "How can such a small box be so complex?"
STRINGS.CHARACTERS.WILLOW.DESCRIBE.CRATE_METAL 			= "How boring."
STRINGS.CHARACTERS.WOLFGANG.DESCRIBE.CRATE_METAL 		= "Crate fears no fire."
STRINGS.CHARACTERS.WENDY.DESCRIBE.CRATE_METAL 			= "A puzzling box."
STRINGS.CHARACTERS.WX78.DESCRIBE.CRATE_METAL 			= "THIS BROTHER DEFENDS FROM FIRE"
STRINGS.CHARACTERS.WICKERBOTTOM.DESCRIBE.CRATE_METAL 	= "A fully automatic storage container."
STRINGS.CHARACTERS.WOODIE.DESCRIBE.CRATE_METAL 			= "It weighs a ton!"
STRINGS.CHARACTERS.WAXWELL.DESCRIBE.CRATE_METAL 		= "A fine example of workmanship."

return	Prefab("crate_metal", fn, assets, prefabs),
		MakePlacer("crate_metal_placer", "crate_metal", "crate_metal", "closed") 
