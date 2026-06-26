-- Main game logic for Tic Tac Toe Deluxe

local config = require("config")
local ui = require("ui")
local ai = require("ai")
local animation = require("animation")
local save = require("save")

local tictactoe = {}

local speaker = nil
local monitorName = nil

local state = {
    screen = "menu",
    mode = nil,
    board = {},
    currentPlayer = config.PLAYER_X,
    gameOver = false,
    winner = nil,
    winLine = nil,
    waitingForAI = false,
    menuHover = nil,
}

local function playSound(soundKey)
    if not speaker then
        return
    end
    local snd = config.sounds[soundKey]
    if snd then
        pcall(function()
            speaker.playNote(snd.instrument, snd.volume, snd.pitch)
        end)
    end
end

local function newBoard()
    local board = {}
    for i = 1, 9 do
        board[i] = config.EMPTY
    end
    return board
end

local function resetGameState(mode)
    state.mode = mode
    state.board = newBoard()
    state.currentPlayer = config.PLAYER_X
    state.gameOver = false
    state.winner = nil
    state.winLine = nil
    state.waitingForAI = false
    state.screen = "game"
end

local function getTurnLabel()
    if state.gameOver then
        return nil
    end
    if state.mode == config.MODE_PVAI then
        if state.currentPlayer == config.PLAYER_X then
            return "Your turn (X)"
        else
            return "AI thinking..."
        end
    end
    return nil
end

local function redrawGame(pulseCell)
    ui.drawGameScreen(
        state.mode,
        state.board,
        state.currentPlayer,
        state.gameOver,
        state.winner,
        getTurnLabel(),
        pulseCell
    )
end

local function checkGameEnd()
    local winner, winLine = ai.checkWinner(state.board)
    if winner then
        state.gameOver = true
        state.winner = winner
        state.winLine = winLine
        save.recordResult(state.mode, winner)

        if winner == "draw" then
            playSound("draw")
            animation.flashBorder(ui.getMonitor(), 2, config.colors.draw)
        elseif winner == config.PLAYER_X then
            playSound("win")
        else
            if state.mode == config.MODE_PVAI then
                playSound("lose")
            else
                playSound("win")
            end
        end

        if winLine then
            redrawGame()
            animation.playWinLine(ui.getMonitor(), winLine, function()
                redrawGame()
            end)
        end
        redrawGame()
        return true
    end
    return false
end

local function placeMarker(cellIndex, player)
    if state.board[cellIndex] ~= config.EMPTY then
        return false
    end
    state.board[cellIndex] = player

    if player == config.PLAYER_X then
        playSound("placeX")
    else
        playSound("placeO")
    end

    animation.pulseMarker(ui.getMonitor(), function(idx, marker, pulse)
        ui.drawCellMarker(idx, marker, pulse)
    end, cellIndex, player)

    return true
end

local function switchPlayer()
    if state.currentPlayer == config.PLAYER_X then
        state.currentPlayer = config.PLAYER_O
    else
        state.currentPlayer = config.PLAYER_X
    end
end

local function aiMove()
    state.waitingForAI = true
    redrawGame()

    sleep(config.AI_THINK_DELAY)

    local move
    local emptyCount = 0
    for i = 1, 9 do
        if state.board[i] == config.EMPTY then
            emptyCount = emptyCount + 1
        end
    end

    if emptyCount == 9 then
        move = ai.openingMove(state.board, config.PLAYER_O)
    else
        move = ai.chooseMove(state.board, config.PLAYER_O, config.PLAYER_X)
    end

    state.waitingForAI = false

    if move and state.board[move] == config.EMPTY then
        placeMarker(move, config.PLAYER_O)
        if not checkGameEnd() then
            state.currentPlayer = config.PLAYER_X
            redrawGame()
        end
    end
end

local function handleCellTouch(cellIndex)
    if state.gameOver or state.waitingForAI then
        playSound("error")
        return
    end

    if state.mode == config.MODE_PVAI and state.currentPlayer ~= config.PLAYER_X then
        playSound("error")
        return
    end

    if state.board[cellIndex] ~= config.EMPTY then
        playSound("error")
        return
    end

    local player = state.currentPlayer
    if not placeMarker(cellIndex, player) then
        return
    end

    if checkGameEnd() then
        return
    end

    switchPlayer()
    redrawGame()

    if state.mode == config.MODE_PVAI and state.currentPlayer == config.PLAYER_O then
        aiMove()
    end
end

local function handleGameTouch(tx, ty)
    local btn = ui.hitTestGameButtons(tx, ty)
    if btn == "menu" then
        playSound("menuOpen")
        ui.flashButton("menu")
        state.screen = "menu"
        ui.drawMainMenu(nil)
        return
    end

    if btn == "restart" then
        playSound("click")
        ui.flashButton("restart")
        resetGameState(state.mode)
        redrawGame()
        if state.mode == config.MODE_PVAI and state.currentPlayer == config.PLAYER_O then
            aiMove()
        end
        return
    end

    if state.gameOver then
        playSound("error")
        return
    end

    local cell = ui.hitTestCell(tx, ty)
    if cell then
        playSound("click")
        handleCellTouch(cell)
    end
end

local function handleMenuTouch(tx, ty)
    local id, index = ui.hitTestMenu(tx, ty)
    if not id then
        return
    end

    playSound("click")
    ui.drawMenuButton(index, true)
    sleep(0.12)
    ui.drawMenuButton(index, false)

    if id == "pvai" then
        resetGameState(config.MODE_PVAI)
        redrawGame()
    elseif id == "pvp" then
        resetGameState(config.MODE_PVP)
        redrawGame()
    elseif id == "stats" then
        state.screen = "stats"
        ui.drawStatsScreen()
    elseif id == "quit" then
        state.screen = "quit"
    end
end

local function handleStatsTouch(tx, ty)
    if ui.hitTestStatsBack(tx, ty) then
        playSound("menuOpen")
        state.screen = "menu"
        ui.drawMainMenu(nil)
    end
end

function tictactoe.init(mon, name, spk)
    monitorName = name
    speaker = spk
    ui.setMonitor(mon, name)
    save.load()
    state.screen = "menu"
    ui.drawMainMenu(nil)
end

function tictactoe.run()
    while state.screen ~= "quit" do
        local event, p1, p2, p3, p4 = os.pullEvent()

        if event == "monitor_touch" and p1 == monitorName then
            local tx, ty = p2, p3

            if state.screen == "menu" then
                handleMenuTouch(tx, ty)
            elseif state.screen == "game" then
                handleGameTouch(tx, ty)
            elseif state.screen == "stats" then
                handleStatsTouch(tx, ty)
            end
        elseif event == "key" and p1 == keys.escape then
            if state.screen == "game" or state.screen == "stats" then
                playSound("menuOpen")
                state.screen = "menu"
                ui.drawMainMenu(nil)
            elseif state.screen == "menu" then
                state.screen = "quit"
            end
        elseif event == "terminate" then
            save.persist()
            return
        end
    end

    save.persist()
end

return tictactoe
