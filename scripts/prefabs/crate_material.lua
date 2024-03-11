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
    if inst.components.burnable ~= nil and inst.components.burnable:IsBurning() then
        inst.components.burnable:Extinguish()
    end
    inst.components.lootdropper:DropLoot()
    if inst.components.container ~= nil then
        inst.components.container:DropEverything()
    end
    local fx = SpawnPrefab("collapse_small")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("wood")
    inst:Remove()
end

local function onhit(inst, worker)
    if not inst:HasTag("burnt") then
        if inst.components.container ~= nil then
            inst.components.container:DropEverything()
            inst.components.container:Close()
        end
        inst.AnimState:PlayAnimation("hit")
        inst.AnimState:PushAnimation("closed", false)
    end
end

local function onbuilt(inst)
	inst.AnimState:PlayAnimation("place")
	inst.AnimState:PushAnimation("closed", false)
end

local function onsave(inst, data)
    if inst.components.burnable ~= nil and inst.components.burnable:IsBurning() or inst:HasTag("burnt") then
        data.burnt = true
    end
end

local function onload(inst, data)
    if data ~= nil and data.burnt and inst.components.burnable ~= nil then
        inst.components.burnable.onburnt(inst)
    end
end

local function fn()
	local inst = CreateEntity()

    inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	inst.entity:AddMiniMapEntity()
	inst.entity:AddNetwork()
		
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

    inst:AddComponent("inspectable")
	inst:AddComponent("container")
    inst.components.container:WidgetSetup("crate_material")
    inst.components.container.onopenfn = onopen
    inst.components.container.onclosefn = onclose
    inst.components.container.skipclosesnd = true
    inst.components.container.skipopensnd = true

    inst:AddComponent("lootdropper")
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(4)
    inst.components.workable:SetOnFinishCallback(onhammered)
    inst.components.workable:SetOnWorkCallback(onhit)

    MakeMediumBurnable(inst, nil, nil, true)
    MakeSmallPropagator(inst)

    inst:ListenForEvent("onbuilt", onbuilt)
    MakeSnowCovered(inst)

    inst.OnSave = onsave
    inst.OnLoad = onload

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
