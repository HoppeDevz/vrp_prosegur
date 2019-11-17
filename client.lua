local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")
func = Tunnel.getInterface("vrp_prosegur")

local spots = {
	["Home"] = {
		startJob = { ['x'] = 7.25, ['y'] = -660.25, ['z'] = 33.45 }
	}
}

local locs = {
    [1] = { ['x'] = -115.81, ['y'] = 6459.32, ['z'] = 32.60 },
    [2] = { ['x'] = -2973.29, ['y'] = 482.35, ['z'] = 18.09 },
    [3] = { ['x'] = 1178.55, ['y'] = 2698.02, ['z'] = 40.35 },
    [4] = { ['x'] = 235.11, ['y'] = 216.83, ['z'] = 114.03 } -- praça
}

giveTruck = false
servico = false
roubavel = false

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1)
        for k,v in pairs(spots) do
            local ped = GetPlayerPed(-1)
            local x,y,z = table.unpack(GetEntityCoords(ped))
            local bowz,cdz = GetGroundZFor_3dCoord(v.startJob.x,v.startJob.y,v.startJob.z)
            local distance = GetDistanceBetweenCoords(v.startJob.x,v.startJob.y,cdz,x,y,z,true)
            if distance < 10 then
                DrawMarker(23,v.startJob.x,v.startJob.y,v.startJob.z-0.9,0,0,0,0,0,0,1.0,1.0,0.5,255,255,0,200,0,0,0,0)
                DrawText3D(v.startJob.x,v.startJob.y,v.startJob.z, "~y~PROSEGUR", 2.0, 7)
                DrawText3D(v.startJob.x,v.startJob.y,v.startJob.z-0.2, "~y~Pressione ~b~E ~y~para trabalhar", 2.0, 1)
            end
            if not giveTruck and distance < 4 and IsControlJustReleased(0, 38) then
                SpawnProsegurTruck(-5.18,-669.99,32.33)
                giveTruck = true
                servico = true
                
                selecionado = parseInt(math.random(1,4))
				CriandoBlip(locs,selecionado)
                
            end    
        end
    end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1)
		if servico then
			local ped = PlayerPedId()
			local x,y,z = table.unpack(GetEntityCoords(ped))
			local bowz,cdz = GetGroundZFor_3dCoord(locs[selecionado].x,locs[selecionado].y,locs[selecionado].z)
            local distance = GetDistanceBetweenCoords(locs[selecionado].x,locs[selecionado].y,cdz,x,y,z,true)   

			if distance <= 30.0 then
				DrawMarker(21,locs[selecionado].x,locs[selecionado].y,locs[selecionado].z+0.30,0,0,0,0,180.0,130.0,2.0,2.0,1.0,240,200,80,20,1,0,0,1)
				if distance <= 2.5 then
					if IsControlJustPressed(0,38) then
						if IsVehicleModel(GetVehiclePedIsUsing(PlayerPedId()),GetHashKey("stockade")) then
                            RemoveBlip(blips)
                            func.giveawards()
							--if selecionado == 52 then
								--selecionado = 1
							--else
								--selecionado = selecionado + 1
							--end
							--emP.checkPayment()
							--CriandoBlip(locs,selecionado)
						end
					end
				end
			end
		end
	end
end)    

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1)
        local ped = PlayerPedId()
        local vehicle = vRP.getNearestVehicle(2) --carro proximo
        local vehicle2 = GetEntityModel(vehicle) -- hash do stockade
        local healthveh = GetEntityHealth(vehicle)
        if vehicle2 ~= 1747439474 then
            vehicle2 = "n/stockade"
       end
        print(vehicle2)
        if vehicle2 == 1747439474 and IsControlJustReleased(0, 38) then
            if healthveh > 1 then
                local x,y,z = table.unpack(GetEntityCoords(ped))
                local cx,cy,cz = table.unpack(GetEntityCoords(vehicle))
                local bowz,cdz = GetGroundZFor_3dCoord(cx,cy,cz)
                local distance = GetDistanceBetweenCoords(cx,cy,cdz,x,y,z,true)
                TriggerEvent("Notify","sucesso","Aguarde 10 segundos para plantar a bomba.")
                Citizen.Wait(10000)

                -- funciona como um update da posição do ped apos 10s
                local x2,y2,z2 = table.unpack(GetEntityCoords(ped))
                local cx2,cy2,cz2 = table.unpack(GetEntityCoords(vehicle))
                local bowz2,cdz2 = GetGroundZFor_3dCoord(cx2,cy2,cz2)
                local distance2 = GetDistanceBetweenCoords(cx2,cy2,cdz2,x2,y2,z2,true)


                if distance2 < 4 then
                    TriggerEvent("Notify","sucesso","Bomba plantada afaste-se do veículo.")
                    Citizen.Wait(9000)
                    AddExplosion(cx+0.4, cy, cz+0.2, 1, 1.0, true, true, true)
                    func.giveDirtMoney()
                    TriggerEvent("Notify","sucesso","Você explodiu o carro forte e ganhou dinheiro sujo.")
                    Citizen.Wait(20000)
                    --DeleteEntity(vehicle2)
                else
                    TriggerEvent("Notify","negado","Você saiu de perto do caminhão.")
                end
            else
                TriggerEvent("Notify","negado","Veículo já roubado.")
            end        
        end
    end         
end)

function DrawText3D(x,y,z, text, scl, font) 
	local onScreen,_x,_y=World3dToScreen2d(x,y,z)
	local px,py,pz=table.unpack(GetGameplayCamCoords())
	local dist = GetDistanceBetweenCoords(px,py,pz, x,y,z, 1)
 
	local scale = (1/dist)*scl
	local fov = (1/GetGameplayCamFov())*100
	local scale = scale*fov
   
	if onScreen then
		SetTextScale(0.0*scale, 1.1*scale)
        SetTextFont(font)
        SetTextProportional(1)
        -- SetTextScale(0.0, 0.55)
        SetTextColour(255, 255, 255, 255)
        SetTextDropshadow(0, 0, 0, 0, 255)
        SetTextEdge(2, 0, 0, 0, 150)
        SetTextDropShadow()
        SetTextOutline()
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x,_y)
	end
end

function SpawnProsegurTruck(x,y,z)
    Citizen.Wait(0)
    local myPed = GetPlayerPed(-1)
    local player = PlayerId()
    local vehicle = GetHashKey('stockade')

    RequestModel(vehicle)

    while not HasModelLoaded(vehicle) do
        Wait(1)
    end
    colors = table.pack(GetVehicleColours(veh))
    extra_colors = table.pack(GetVehicleExtraColours(veh))
    plate = math.random(100, 900)
    local spawned_car = CreateVehicle(vehicle, x,y,z, true, false)
    SetVehicleColours(spawned_car,4,5)
    SetVehicleExtraColours(spawned_car,extra_colors[1],extra_colors[2])
    SetEntityHeading(spawned_car, 317.64)
    SetVehicleOnGroundProperly(spawned_car)
    SetPedIntoVehicle(myPed, spawned_car, - 1)
    SetModelAsNoLongerNeeded(vehicle)
    Citizen.InvokeNative(0xB736A491E64A32CF, Citizen.PointerValueIntInitialized(spawned_car))
    CruiseControl = 0
    DTutOpen = false
    SetEntityVisible(myPed, true)
    SetVehicleDoorsLocked(GetCar(), 4)
    FreezeEntityPosition(myPed, false)
end


function CriandoBlip(locs,selecionado)
	blips = AddBlipForCoord(locs[selecionado].x,locs[selecionado].y,locs[selecionado].z)
	SetBlipSprite(blips,1)
	SetBlipColour(blips,5)
	SetBlipScale(blips,0.4)
	SetBlipAsShortRange(blips,false)
	SetBlipRoute(blips,true)
	BeginTextCommandSetBlipName("STRING")
	AddTextComponentString("Rota PROSEGUR")
	EndTextCommandSetBlipName(blips)
end

function GetCar() 
	return GetVehiclePedIsIn(GetPlayerPed(-1),false) 
end

function drawTxt(text,font,x,y,scale,r,g,b,a)
SetTextFont(font)
SetTextScale(scale,scale)
SetTextColour(r,g,b,a)
SetTextOutline()
SetTextCentre(1)
SetTextEntry("STRING")
AddTextComponentString(text)
DrawText(x,y)
end