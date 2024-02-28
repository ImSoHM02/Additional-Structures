require "prefabutil"

local assets =
{
	Asset("ANIM", "anim/compost_box.zip"),
	Asset("ATLAS", "images/inventoryimages/compost_box.xml"),
	Asset("ANIM", "anim/explode.zip"),
}

local prefabs =
{
	"collapse_small",
	"explode_small"
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
	if inst.components.container then inst.components.container:DropEverything() end
	SpawnPrefab("collapse_small").Transform:SetPosition(inst.Transform:GetWorldPosition())
	inst.SoundEmitter:PlaySound("dontstarve/common/destroy_wood")
	if inst.flies then 
		inst.flies:Remove() inst.flies = nil 
	end	
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
		if inst.flies then 
			inst.flies:Remove() inst.flies = nil 
		end	
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

local function itemtest(inst, item, slot)
	return (item.components.edible and item.components.perishable) or 
	item.prefab == "spoiled_food" or 
	item.prefab == "rottenegg" or 
	item.prefab == "heatrock" or 
	item:HasTag("frozen") or
	item:HasTag("icebox_valid")
end
--[[
local function OnExplodeFn(inst)
    local pos = Vector3(inst.Transform:GetWorldPosition())
    inst.SoundEmitter:KillSound("hiss")
    inst.SoundEmitter:PlaySound("dontstarve/common/blackpowder_explo")
	
	if inst.flies then 
		inst.flies:Remove() inst.flies = nil 
	end	

    local explode = SpawnPrefab("explode_small")
    local pos = inst:GetPosition()
    explode.Transform:SetPosition(pos.x, pos.y, pos.z)

    --local explode = PlayFX(pos,"explode", "explode", "small")
    explode.AnimState:SetBloomEffectHandle( "shaders/anim.ksh" )
    explode.AnimState:SetLightOverride(1)
end
]]

--Sanity stuff below. There is probably a much easier way to do this.
local modname = KnownModIndex:GetModActualName("Additional Structures")
local cbsanityaura = GetModConfigData("cbsanityaura", modname)

local function fn(Sim)
	local inst = CreateEntity()
    inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()
	
	MakeObstaclePhysics(inst, .3)
			
	inst.MiniMapEntity:SetIcon("compost_box.tex")
	
	inst:AddTag("compost")
	inst:AddTag("structure")
	
	--[[
	inst:AddComponent("explosive")
    inst.components.explosive:SetOnExplodeFn(OnExplodeFn)
    inst.components.explosive.explosivedamage = TUNING.GUNPOWDER_DAMAGE
	]]

    inst.AnimState:SetBank("compost_box")
    inst.AnimState:SetBuild("compost_box")
    inst.AnimState:PlayAnimation("close")

    MakeSnowCoveredPristine(inst)

    inst:ListenForEvent("onbuilt", onbuilt)

    if not TheWorld.ismastersim then
        return inst
    end

    inst.entity:SetPristine()
    
    inst:AddComponent("sanityaura")
    if cbsanityaura == 0 then
			inst.components.sanityaura.aura = 0
		elseif cbsanityaura == 1 then
			inst.components.sanityaura.aura = -TUNING.SANITYAURA_SMALL
		elseif cbsanityaura == 2 then
			inst.components.sanityaura.aura = -TUNING.SANITYAURA_MED
		elseif cbsanityaura == 3 then
			inst.components.sanityaura.aura = -TUNING.SANITYAURA_LARGE
	end

    inst:AddComponent("inspectable")

    inst:AddComponent("lootdropper")

	inst:AddComponent("preserver")
	inst.components.preserver:SetPerishRateMultiplier(TUNING.PERISH_COMPOST_BOX_MULT)

	inst:AddComponent("container")
    inst.components.container:WidgetSetup("compost_box")
    inst.components.container.onopenfn = onopen
    inst.components.container.onclosefn = onclose
    inst.components.container.skipclosesnd = true
    inst.components.container.skipopensnd = true

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(4)
    inst.components.workable:SetOnFinishCallback(onhammered)
    inst.components.workable:SetOnWorkCallback(onhit) 
	
	MakeLargeBurnable(inst, 6+ math.random()*6)
	MakeLargePropagator(inst)
	
    return inst
end

STRINGS.RECIPE_DESC.COMPOST_BOX 						= "Speeds up spoilage."

STRINGS.CHARACTERS.GENERIC.DESCRIBE.COMPOST_BOX 		= "Smells awful!"
STRINGS.CHARACTERS.WILLOW.DESCRIBE.COMPOST_BOX 			= "How would I love to set that on fire!"
STRINGS.CHARACTERS.WOLFGANG.DESCRIBE.COMPOST_BOX 		= "Is box of yuck!"
STRINGS.CHARACTERS.WENDY.DESCRIBE.COMPOST_BOX 			= "It is what we all are destined to become."
STRINGS.CHARACTERS.WX78.DESCRIBE.COMPOST_BOX 			= "AIR HAZARD DETECTED"
STRINGS.CHARACTERS.WICKERBOTTOM.DESCRIBE.COMPOST_BOX 	= "It helps speed up the spoiling process."
STRINGS.CHARACTERS.WOODIE.DESCRIBE.COMPOST_BOX 			= "Phew, that stinks!"
STRINGS.CHARACTERS.WAXWELL.DESCRIBE.COMPOST_BOX 		= "Great, a box full of rot to make more rot."

return	Prefab("compost_box", fn, assets, prefabs),
		MakePlacer("compost_box_placer", "compost_box", "compost_box", "closed") 
