local QBCore = nil
local ESX = nil
local current_anim_mode = nil
local is_1handed_active = false
local weapon_hash_cache = {}
local unarmed_hash = GetHashKey('WEAPON_UNARMED')
local jerrycan_anim_loaded = false
local bridge_table = nil

CreateThread(function()
    Wait(1000)
    bridge_table = exports['s6la_bridge']:ret_bridge_table()
    if bridge_table and bridge_table.framework == 'qb-core' then
        QBCore = exports['qb-core']:GetCoreObject()
    elseif bridge_table and bridge_table.framework == 'es_extended' then
        ESX = exports['es_extended']:getSharedObject()
    end
    
    local saved_mode = GetResourceKvpString('s6la_1handed_mode')
    if saved_mode then
        current_anim_mode = saved_mode
        is_1handed_active = (saved_mode == '1handed')
    else
        current_anim_mode = 'default'
        is_1handed_active = false
    end
    
    if is_1handed_active then
        RequestAnimSet('move_ped_wpn_jerrycan_generic')
        while not HasAnimSetLoaded('move_ped_wpn_jerrycan_generic') do
            Wait(10)
        end
        jerrycan_anim_loaded = true
    end
    
    for _, weapon_name in ipairs(Config.supported_weapons) do
        weapon_hash_cache[GetHashKey(weapon_name)] = true
    end
end)

local function is_weapon_supported(weapon_hash)
    return weapon_hash_cache[weapon_hash] == true
end

CreateThread(function()
    local last_weapon = nil
    local weapon_clipset_applied = false
    
    while true do
        Wait(100)
        ped = PlayerPedId()
        local current_weapon = GetSelectedPedWeapon(ped)
        
        if current_weapon ~= last_weapon then
            if weapon_clipset_applied then
                ResetPedWeaponMovementClipset(ped)
                weapon_clipset_applied = false
            end
            
            last_weapon = current_weapon
            
            if current_weapon ~= unarmed_hash and is_weapon_supported(current_weapon) then
                if is_1handed_active then
                    if not jerrycan_anim_loaded then
                        RequestAnimSet('move_ped_wpn_jerrycan_generic')
                        while not HasAnimSetLoaded('move_ped_wpn_jerrycan_generic') do
                            Wait(10)
                        end
                        jerrycan_anim_loaded = true
                    end
                    SetPedWeaponMovementClipset(ped, 'move_ped_wpn_jerrycan_generic')
                    weapon_clipset_applied = true
                end
            end
        end
        
        if current_weapon ~= unarmed_hash and is_weapon_supported(current_weapon) then
            if is_1handed_active and not weapon_clipset_applied then
                if not jerrycan_anim_loaded then
                    RequestAnimSet('move_ped_wpn_jerrycan_generic')
                    while not HasAnimSetLoaded('move_ped_wpn_jerrycan_generic') do
                        Wait(10)
                    end
                    jerrycan_anim_loaded = true
                end
                SetPedWeaponMovementClipset(ped, 'move_ped_wpn_jerrycan_generic')
                weapon_clipset_applied = true
            elseif not is_1handed_active and weapon_clipset_applied then
                ResetPedWeaponMovementClipset(ped)
                weapon_clipset_applied = false
            end
        elseif weapon_clipset_applied then
            ResetPedWeaponMovementClipset(ped)
            weapon_clipset_applied = false
        end
    end
end)

exports['ox_lib']:registerContext({
    id = 's6la_runanim_menu',
    title = 'Running Animation',
    options = {
        {
            title = '1 Hand Weapon',
            description = 'Use one-handed running animation',
            onSelect = function()
                current_anim_mode = '1handed'
                is_1handed_active = true
                SetResourceKvp('s6la_1handed_mode', '1handed')
                if not jerrycan_anim_loaded then
                    RequestAnimSet('move_ped_wpn_jerrycan_generic')
                    while not HasAnimSetLoaded('move_ped_wpn_jerrycan_generic') do
                        Wait(10)
                    end
                    jerrycan_anim_loaded = true
                end
                if bridge_table and bridge_table.framework then
                    exports['s6la_bridge']:notify('One-handed animation enabled', 'success', 3000)
                end
            end
        },
        {
            title = 'Default',
            description = 'Use default GTA running animation',
            onSelect = function()
                current_anim_mode = 'default'
                is_1handed_active = false
                SetResourceKvp('s6la_1handed_mode', 'default')
                ResetPedWeaponMovementClipset(PlayerPedId())
                if bridge_table and bridge_table.framework then
                    exports['s6la_bridge']:notify('Default animation enabled', 'success', 3000)
                end
            end
        }
    }
})

RegisterCommand('runanim', function()
    exports['ox_lib']:showContext('s6la_runanim_menu')
end, false)

