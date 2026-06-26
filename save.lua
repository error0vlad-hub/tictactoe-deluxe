-- Statistics persistence

local config = require("config")

local save = {}

local DEFAULT_STATS = {
    pvai_x_wins = 0,
    pvai_o_wins = 0,
    pvai_draws = 0,
    pvp_x_wins = 0,
    pvp_o_wins = 0,
    pvp_draws = 0,
    total_games = 0,
    ai_games = 0,
    pvp_games = 0,
}

local stats = nil

local function serialize(tbl, indent)
    indent = indent or 0
    local lines = {}
    local pad = string.rep("  ", indent)
    for k, v in pairs(tbl) do
        if type(v) == "number" then
            lines[#lines + 1] = pad .. k .. "=" .. tostring(v)
        elseif type(v) == "string" then
            lines[#lines + 1] = pad .. k .. "=\"" .. v:gsub("\"", "\\\"") .. "\""
        elseif type(v) == "table" then
            lines[#lines + 1] = pad .. k .. "={"
            for _, sub in ipairs(serialize(v, indent + 1)) do
                lines[#lines + 1] = sub
            end
            lines[#lines + 1] = pad .. "}"
        end
    end
    return lines
end

local function deserialize(content)
    local env = {}
    local fn, err = load(content, "stats", "t", env)
    if not fn then
        return nil, err
    end
    local ok, runErr = pcall(fn)
    if not ok then
        return nil, runErr
    end
    return env
end

function save.load()
    if stats then
        return stats
    end

    stats = {}
    for k, v in pairs(DEFAULT_STATS) do
        stats[k] = v
    end

    if not fs.exists(config.STATS_FILE) then
        return stats
    end

    local file = fs.open(config.STATS_FILE, "r")
    if not file then
        return stats
    end

    local content = file.readAll()
    file.close()

    if content and #content > 0 then
        for line in content:gmatch("[^\r\n]+") do
            local key, value = line:match("^(%w+)=(%d+)$")
            if key and value and stats[key] ~= nil then
                stats[key] = tonumber(value)
            end
        end
    end

    return stats
end

function save.get()
    return save.load()
end

function save.persist()
    if not stats then
        save.load()
    end

    local file = fs.open(config.STATS_FILE, "w")
    if not file then
        return false, "Could not open stats file for writing"
    end

    for k, _ in pairs(DEFAULT_STATS) do
        file.write(k .. "=" .. tostring(stats[k] or 0) .. "\n")
    end
    file.close()
    return true
end

function save.recordResult(mode, winner)
    save.load()
    stats.total_games = stats.total_games + 1

    if mode == config.MODE_PVAI then
        stats.ai_games = stats.ai_games + 1
        if winner == config.PLAYER_X then
            stats.pvai_x_wins = stats.pvai_x_wins + 1
        elseif winner == config.PLAYER_O then
            stats.pvai_o_wins = stats.pvai_o_wins + 1
        elseif winner == "draw" then
            stats.pvai_draws = stats.pvai_draws + 1
        end
    elseif mode == config.MODE_PVP then
        stats.pvp_games = stats.pvp_games + 1
        if winner == config.PLAYER_X then
            stats.pvp_x_wins = stats.pvp_x_wins + 1
        elseif winner == config.PLAYER_O then
            stats.pvp_o_wins = stats.pvp_o_wins + 1
        elseif winner == "draw" then
            stats.pvp_draws = stats.pvp_draws + 1
        end
    end

    save.persist()
end

function save.reset()
    stats = {}
    for k, v in pairs(DEFAULT_STATS) do
        stats[k] = v
    end
    save.persist()
end

return save
