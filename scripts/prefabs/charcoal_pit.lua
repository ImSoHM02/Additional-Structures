
require "prefabutil"

local assets =
{
	Asset("ANIM", "anim/charcoal_pit.zip"),
	Asset("ATLAS", "images/inventoryimages/charcoal_pit.xml"),
}

local prefabs =
{
	"collapse_small",
	"charcoal",
}

local MACHINESTATES =
{
	ON = "_on",
	OFF = "_off",
}

local chance = 1.0
local chance_2 = 0.5

local function spawncharcoal(inst)
	inst:RemoveEventCallback("animover", spawncharcoal)

    local charcoal = SpawnPrefab("charcoal")
	local ash = SpawnPrefab("ash")
	local ash_2 = SpawnPrefab("ash")
    local pt = Vector3(inst.Transform:GetWorldPosition()) + Vector3(0,2,0)
    charcoal.Transform:SetPosition(pt:Get())
    local down = TheCamera:GetDownVec()
    local angle = math.atan2(down.z, down.x) + (math.random()*60)*DEGREES
    local sp = 3 + math.random()
    charcoal.Physics:SetVel(sp*math.cos(angle), math.random()*2+8, sp*math.sin(angle))
	
	if math.random() < chance then
	    local pt_2 = Vector3(inst.Transform:GetWorldPosition()) + Vector3(0,2,0)
	    ash.Transform:SetPosition(pt_2:Get())
		local down_2 = TheCamera:GetDownVec()
		local angle_2 = math.atan2(down_2.y, down_2.x) + (math.random()*60)*DEGREES
		local sp_2 = 3 + math.random()
        ash.Physics:SetVel(sp_2*math.cos(angle_2), math.random()*2+8, sp_2*math.sin(angle_2))
	end

	if math.random() < chance_2 then
	    local pt_3 = Vector3(inst.Transform:GetWorldPosition()) + Vector3(0,2,0)
	    ash_2.Transform:SetPosition(pt_3:Get())
		local down_3 = TheCamera:GetDownVec()
		local angle_3 = math.atan2(down_3.y, down_3.x) + (math.random()*60)*DEGREES
		local sp_3 = 3 + math.random()
        ash_2.Physics:SetVel(sp_3*math.cos(angle_3), math.random()*2+8, sp_3*math.sin(angle_3))
	end
	
	inst.components.fueled:StartConsuming()
	inst.AnimState:PlayAnimation("idle_on", true)
end

local function onhammered(inst, worked)
	inst.components.lootdropper:DropLoot()
	SpawnPrefab("collapse_small").Transform:SetPosition(inst.Transform:GetWorldPosition())
	inst.SoundEmitter:PlaySound("/common/destroy_metal")
	inst:Remove()
end

local function fueltaskfn(inst)
	inst.AnimState:PlayAnimation("use")
--	inst.SoundEmitter:PlaySound("dontstarve/common/cookingpot_rattle")
	inst.components.fueled:StopConsuming() 
	inst:ListenForEvent("animover", spawncharcoal)
end

local function ontakefuelfn(inst)
	inst.SoundEmitter:PlaySound("/common/fireAddFuel")
	inst.components.fueled:StartConsuming()
end

local function fuelupdatefn(inst, dt)
	inst.components.fueled.rate = 1
end

local function onhit(inst, worker)
	inst.AnimState:PlayAnimation("hit"..inst.machinestate)
	inst.AnimState:PushAnimation("idle"..inst.machinestate, true)
	inst:RemoveEventCallback("animover", spawncharcoal)
	if inst.machinestate == MACHINESTATES.ON then
		inst.components.fueled:StartConsuming() 
	end
end

local function fuelsectioncallback(new, old, inst)
	if new == 0 and old > 0 then
		inst.machinestate = MACHINESTATES.OFF
		inst.AnimState:PlayAnimation("turn"..inst.machinestate)
		inst.AnimState:PushAnimation("idle"..inst.machinestate, true)
		inst.SoundEmitter:KillSound("loop")
		inst.Light:Enable(false)
		if inst.fueltask ~= nil then
			inst.fueltask:Cancel()
			inst.fueltask = nil
		end
	elseif new > 0 and old == 0 then
		inst.machinestate = MACHINESTATES.ON
		inst.AnimState:PlayAnimation("turn"..inst.machinestate)
		inst.AnimState:PushAnimation("idle"..inst.machinestate, true)
--		if not inst.SoundEmitter:PlayingSound("loop") then
--			inst.SoundEmitter:PlaySound("dontstarve/common/cookingpot_rattle", "loop")
--		end
		inst.Light:Enable(true)
		if inst.fueltask == nil then
			inst.fueltask = inst:DoPeriodicTask(TUNING.SEG_TIME, fueltaskfn)
		end
	end
end

local function getstatus(inst)
	local sec = inst.components.fueled:GetCurrentSection()
	if sec == 0 then
		return "OUT"
	elseif sec <= 4 then
		local t = {"VERYLOW","LOW","NORMAL","HIGH"}
		return t[sec]
	end
end

local function onbuilt(inst)
	inst.AnimState:PlayAnimation("place")
	inst.AnimState:PushAnimation("idle"..inst.machinestate)
end

local function fn(Sim)
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	inst.entity:AddMiniMapEntity()
	inst.entity:AddLight()
	inst.entity:AddNetwork()
	
	MakeObstaclePhysics(inst, .4)
	
	inst.MiniMapEntity:SetIcon("charcoal_pit.tex" )
	
	local light = inst.entity:AddLight()
    inst.Light:Enable(false)
	inst.Light:SetRadius(.6)
    inst.Light:SetFalloff(1)
    inst.Light:SetIntensity(.5)
    inst.Light:SetColour(235/255,62/255,12/255)

    inst:AddTag("structure")

	inst.AnimState:SetBank("charcoal_pit")
	inst.AnimState:SetBuild("charcoal_pit")

    MakeSnowCoveredPristine(inst)

    inst:ListenForEvent("onbuilt", onbuilt)

    if not TheWorld.ismastersim then
        return inst
    end

    inst.entity:SetPristine()

	inst:AddComponent("lootdropper")
	inst:AddComponent("fueled")
	inst.components.fueled.maxfuel = TUNING.SEG_TIME
	inst.components.fueled.accepting = true
	inst.components.fueled:SetSections(4)
	inst.components.fueled.ontakefuelfn = ontakefuelfn
	inst.components.fueled:SetUpdateFn(fuelupdatefn)
	inst.components.fueled:SetSectionCallback(fuelsectioncallback)
	inst.components.fueled:InitializeFuelLevel((TUNING.SEG_TIME * 3)/2)
	inst.components.fueled:StartConsuming()
	
	local CanAcceptFuelItem_ = inst.components.fueled.CanAcceptFuelItem
	inst.components.fueled.CanAcceptFuelItem_ = function(self, item)
		return CanAcceptFuelItem_(self, item) and (item.prefab == "log" or item.prefab == "livinglog")
	end

	inst:AddComponent("inspectable")
	inst.components.inspectable.getstatus = getstatus

	inst:AddComponent("workable")
	inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
	inst.components.workable:SetWorkLeft(4)
	inst.components.workable:SetOnFinishCallback(onhammered)
	inst.components.workable:SetOnWorkCallback(onhit)

	inst.machinestate = MACHINESTATES.ON

	return inst
end


STRINGS.RECIPE_DESC.CHARCOAL_PIT 							= "Makes charcoal from logs."

STRINGS.CHARACTERS.GENERIC.DESCRIBE.CHARCOAL_PIT 			= "Smells like a small forest fire."
STRINGS.CHARACTERS.WILLOW.DESCRIBE.CHARCOAL_PIT 			= "What a nice smell."
STRINGS.CHARACTERS.WOLFGANG.DESCRIBE.CHARCOAL_PIT 			= "It make tiny dead trees."
STRINGS.CHARACTERS.WENDY.DESCRIBE.CHARCOAL_PIT 				= "A tree crematory."
STRINGS.CHARACTERS.WX78.DESCRIBE.CHARCOAL_PIT 				= "FIRE CONTAINMENT UNIT"
STRINGS.CHARACTERS.WICKERBOTTOM.DESCRIBE.CHARCOAL_PIT 		= "A convenient way to make charcoal."
STRINGS.CHARACTERS.WOODIE.DESCRIBE.CHARCOAL_PIT 			= "Looking at it makes me sad."
STRINGS.CHARACTERS.WAXWELL.DESCRIBE.CHARCOAL_PIT 			= "I prefer doing the job myself."

return 	Prefab("charcoal_pit", fn, assets, prefabs),
		MakePlacer("charcoal_pit_placer", "charcoal_pit", "charcoal_pit", "idle_off")
