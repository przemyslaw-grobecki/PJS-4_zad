if pcall(require, "lldebugger") then require("lldebugger").start() end
if pcall(require, "mobdebug") then require("mobdebug").start() end

lose = false
score = 0
startFigureX = 5
boardGameWidth = 12
boardGameHeight = 23
tileWidth = 25
tileHeight = 25
boardState = {
    {0,0,0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0,0,0,0},
}

local figures = {
    {2,4,6,8}, -- I
    {3,5,6,8}, -- Z
    {4,6,5,7}, -- S
    {4,6,5,8}, -- T
    {3,4,6,8}, -- L
    {4,6,8,7}, -- J
    {3,4,5,6}, -- O
};

figure = {
    {2,3},
    {2,4},
    {2,5},
    {2,6}
}

t = 0
t_k = 0
function love.load()
    board = love.graphics.newImage("tetrisBoard.png")
    scoreOffset = 30
    boardWidth = board:getWidth()
    boardHeight = board:getHeight()
    love.window.setMode(boardWidth,boardHeight+scoreOffset)
    quad = love.graphics.newQuad(0, -scoreOffset, boardWidth, boardHeight+scoreOffset, board)
end

function love.update(dt)
    t = t + dt 
    t_k = t_k + dt

    if lose == false then
        if t_k > 0.05 then 
            if love.keyboard.isDown("left") then
                moveleft()
            end
            if love.keyboard.isDown("right") then
                moveRight()
            end
            if love.keyboard.isDown("up") then
                rotate()
            end
            t_k = 0
        end
        if t > 0.4 then
            moveDown()
            clearLine()
            t = 0
        end
    end
end

function love.draw()
    love.graphics.draw(board, quad, width, height)
    if lose == false then
        drawCurrentShape()
        drawBoardState()
    else
        love.graphics.print("You LOST",boardWidth/2,boardGameHeight/2)
    end
    love.graphics.print("Score= " .. score,boardWidth/2,0)
end

function drawCurrentShape()
    for i=1,4 do
        love.graphics.rectangle("fill", (figure[i][1]-1)*tileWidth, 31+(figure[i][2]-1)*tileHeight, tileWidth, tileHeight)
    end
end

function drawBoardState()
    for i=1,boardGameWidth do
        for j=1,boardGameHeight do
            if boardState[j][i] == 1 or boardState[j][i] == 2 then
                love.graphics.rectangle("fill", (i-1)*tileWidth, 31+(j-1)*tileHeight, tileWidth, tileHeight)
            end
        end
    end
end 

function moveDown()  
    makeSolid = false 
    for i=1,4 do
        if figure[i][2] + 1 > boardGameHeight or boardState[figure[i][2] + 1][figure[i][1]] == 1 then
            makeSolid = true
        end
    end
    if makeSolid then
        for i=1,4 do
            boardState[figure[i][2]][figure[i][1]] = 1
        end
        createFigure()
        checkForLoose()
    else
        for i=1,4 do
            figure[i][2] = figure[i][2] + 1
        end
    end
end

function rotate()
    local tableCopy = deepcopy(figure)
    local center = figure[2]
    for i=1,4 do
        local x = figure[i][2]-center[2]
        local y = figure[i][1]-center[1]
        figure[i][2] = center[2] + y
        figure[i][1] = center[1] - x
    end
    if check() == false then
        figure = deepcopy(tableCopy)
    end
end

function moveleft()
    for i=1,4 do
        figure[i][1] = figure[i][1] - 1 
    end
    if check() == false then
        for i=1,4 do
            figure[i][1] = figure[i][1] + 1
        end
    end 
end

function moveRight()
    for i=1,4 do
        figure[i][1] = figure[i][1] + 1 
    end
    if check() == false then
        for i=1,4 do
            figure[i][1] = figure[i][1] - 1
        end
    end 
end
 
function createFigure()
    local figureNumber = math.random(1,7)
    if figureNumber == 1 then
        S()
    elseif figureNumber == 2 then 
        Z() 
    elseif figureNumber == 3 then 
        T()
    elseif figureNumber == 4 then 
        L()    
    elseif figureNumber == 5 then 
        J()    
    elseif figureNumber == 6 then 
        O()    
    else 
        I()   
    end
end

function I()
    figure[1][1] = startFigureX + 1
    figure[1][2] = 1

    figure[2][1] = startFigureX + 1
    figure[2][2] = 2

    figure[3][1] = startFigureX + 1
    figure[3][2] = 3

    figure[4][1] = startFigureX + 1
    figure[4][2] = 4
end

function Z()
    figure[1][1] = startFigureX
    figure[1][2] = 2

    figure[2][1] = startFigureX
    figure[2][2] = 3

    figure[3][1] = startFigureX + 1
    figure[3][2] = 3

    figure[4][1] = startFigureX
    figure[4][2] = 4
end

function S()
    figure[1][1] = startFigureX + 1
    figure[1][2] = 2

    figure[2][1] = startFigureX + 1
    figure[2][2] = 3

    figure[3][1] = startFigureX
    figure[3][2] = 3

    figure[4][1] = startFigureX
    figure[4][2] = 4
    
end

function T()
    figure[1][1] = startFigureX + 1
    figure[1][2] = 2
    
    figure[2][1] = startFigureX + 1
    figure[2][2] = 3
    
    figure[3][1] = startFigureX
    figure[3][2] = 3
    
    figure[4][1] = startFigureX + 1
    figure[4][2] = 4
end

function L()
    figure[1][1] = startFigureX
    figure[1][2] = 2
    
    figure[2][1] = startFigureX + 1
    figure[2][2] = 2
    
    figure[3][1] = startFigureX + 1
    figure[3][2] = 3
    
    figure[4][1] = startFigureX + 1
    figure[4][2] = 4
end

function J()
    figure[1][1] = startFigureX + 1
    figure[1][2] = 2

    figure[2][1] = startFigureX + 1
    figure[2][2] = 3

    figure[3][1] = startFigureX + 1
    figure[3][2] = 4

    figure[4][1] = startFigureX
    figure[4][2] = 4
end

function O()
    figure[1][1] = startFigureX
    figure[1][2] = 2

    figure[2][1] = startFigureX + 1
    figure[2][2] = 2

    figure[3][1] = startFigureX 
    figure[3][2] = 3

    figure[4][1] = startFigureX + 1
    figure[4][2] = 3
end

function check()
    for i=1,4 do
        if figure[i][1] < 1 or figure[i][1] > boardGameWidth or figure[i][2]> boardGameHeight then return false
        elseif boardState[figure[i][2]][figure[i][1]] == 1 then return false
        end
    end
    return true
end

function clearLine()
    local sum = 0
    for i=1,boardGameHeight do
        for j=1,boardGameWidth do
            if boardState[i][j] == 1 then
                sum = sum + 1
            end
        end
        if sum == boardGameWidth then
            for n=1,boardGameWidth do
                boardState[i][n] = 0
            end
            for z=i,2,-1 do
                for y=1,boardGameWidth do
                    if boardState[z-1][y] == 1 then
                        boardState[z][y] = 1
                        boardState[z-1][y] = 0
                    end
                end
            end
            score = score + 1
        end
        sum = 0
    end
end

function checkForLoose()
    for i=1,4 do
        if boardState[figure[i][2]][figure[i][1]] == 1 then
            lose = true
        end
    end
end

function deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end