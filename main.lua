local mod =
  RegisterMod(
    "Angel Laser Preview",
    1
  )

local seenEntities = {}
local lastBossStatus = {}

local function IsAngel(entity)
  return
    entity.Type
      == EntityType.ENTITY_URIEL
    or entity.Type
      == EntityType.ENTITY_GABRIEL
end

local function ResetDebugData()
  seenEntities = {}
  lastBossStatus = {}
end

local function GetSpawnerText(entity)
  local spawner =
    entity.SpawnerEntity

  if not spawner then
    return "none"
  end

  return string.format(
    "%d.%d.%d",
    spawner.Type,
    spawner.Variant,
    spawner.SubType
  )
end

local function LogNewEntity(entity)
  local key =
    GetPtrHash(entity)

  if seenEntities[key] then
    return
  end

  seenEntities[key] = true

  local sprite =
    entity:GetSprite()

  print(
    string.format(
      "[Angel Debug] NEW"
        .. " type=%d"
        .. " variant=%d"
        .. " subtype=%d"
        .. " spawner=%s"
        .. " anm2=%s"
        .. " anim=%s"
        .. " frame=%d",
      entity.Type,
      entity.Variant,
      entity.SubType,
      GetSpawnerText(entity),
      sprite:GetFilename(),
      sprite:GetAnimation(),
      sprite:GetFrame()
    )
  )
end

local function LogBossStatus(boss)
  local sprite =
    boss:GetSprite()

  local key =
    GetPtrHash(boss)

  local animation =
    sprite:GetAnimation()

  local overlay =
    sprite:GetOverlayAnimation()

  local signature =
    tostring(boss.State)
      .. "|"
      .. animation
      .. "|"
      .. overlay

  if lastBossStatus[key]
      == signature then
    return
  end

  lastBossStatus[key] =
    signature

  print(
    string.format(
      "[Angel Debug] BOSS"
        .. " type=%d"
        .. " state=%d"
        .. " stateFrame=%d"
        .. " anim=%s"
        .. " frame=%d"
        .. " overlay=%s",
      boss.Type,
      boss.State,
      boss.StateFrame,
      animation,
      sprite:GetFrame(),
      overlay
    )
  )
end

local function OnPostUpdate()
  local entities =
    Isaac.GetRoomEntities()

  local hasAngel = false

  for _, entity
    in ipairs(entities) do

    if IsAngel(entity) then
      hasAngel = true
      break
    end
  end

  if not hasAngel then
    return
  end

  for _, entity
    in ipairs(entities) do

    if IsAngel(entity) then
      LogBossStatus(entity)

    elseif entity.Type
        == EntityType.ENTITY_EFFECT
      or entity.Type
        == EntityType.ENTITY_LASER then

      LogNewEntity(entity)
    end
  end
end

mod:AddCallback(
  ModCallbacks.MC_POST_UPDATE,
  OnPostUpdate
)

mod:AddCallback(
  ModCallbacks.MC_POST_NEW_ROOM,
  ResetDebugData
)

print(
  "[Angel Debug] Inspector loaded"
)