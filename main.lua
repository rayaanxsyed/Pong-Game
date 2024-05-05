push = require "push"


WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

paddle_speed = 300

twoplayer = false

function love.load()
    love.graphics.setDefaultFilter('nearest', 'nearest')

    math.randomseed(os.time())

    smallfont = love.graphics.newFont('pixels.ttf', 12)
    fpsfont = love.graphics.newFont('pixels.ttf', 8)
    scorefont = love.graphics.newFont('pixels.ttf', 18)
    

    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT,WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false, 
        resizable = false,
        vsync = true
    })
    player1Y = 30
    player2Y = VIRTUAL_HEIGHT - 50

    player1Score = 0
    player2Score = 0

    ballX = VIRTUAL_WIDTH / 2 - 2 
    ballY = VIRTUAL_HEIGHT / 2 - 2 

    ballDX = math.random(2) == 1 and 300 or -300
    ballDY = math.random(-300,300)

    gamestate = 'start'
end

function love.keypressed(key)
    if key == 'escape' then 
        love.event.quit()
    elseif key == '2' then 
        twoplayer = true
    elseif key == '1' then 
        twoplayer = false
    elseif key == 'r' then 
        resetBall()
        player1Score = 0
        player2Score = 0
    elseif key == 'space' then 
        if gamestate == 'start' then 
            gamestate = 'play'
        else
            gamestate = 'start'
            ballX = VIRTUAL_WIDTH / 2 - 2 
            ballY = VIRTUAL_HEIGHT / 2 - 2 

            ballDX = math.random(2) == 1 and 300 or -300
            ballDY = math.random(-100,100)
        end
    end
end


function love.update(dt)
    if love.keyboard.isDown('w') then 
        player1Y = math.max(player1Y - paddle_speed * dt, 0)
    elseif love.keyboard.isDown('s') then 
        player1Y = math.min(VIRTUAL_HEIGHT - 20, player1Y + paddle_speed * dt)
    end

    if love.keyboard.isDown('up') then 
        player2Y = math.max(0, player2Y - paddle_speed * dt)
    elseif love.keyboard.isDown('down') then 
        player2Y = math.min(VIRTUAL_HEIGHT- 20, player2Y + paddle_speed * dt)
    end
    if gamestate == 'play' then 
        ballX = ballX + ballDX * dt
        ballY = ballY + ballDY * dt
        -- this is the AI, switch for two player or not 
        if ballDX > 0 and not twoplayer then 
            local targetY = ballY + 5 
            local centerY = player2Y + 10
            local deltaY = targetY - centerY

            if math.abs(deltaY) < paddle_speed * dt then
                player2Y = targetY - 10
            elseif deltaY < 0 then
                player2Y = math.max(0, player2Y - paddle_speed * dt)
            elseif deltaY > 0 then
                player2Y = math.min(VIRTUAL_HEIGHT, player2Y + paddle_speed * dt)
            end
        end
        -- up till here is the AI code 
        if ballX <= 0 then 
            player2Score = player2Score + 1
            resetBall()
        elseif ballX >= VIRTUAL_WIDTH - 5 then 
            player1Score = player1Score + 1
            resetBall()
        end
    end

    if ballX <= 15 and ballY >= player1Y and ballY <= player1Y + 20 then
        ballDX = math.abs(ballDX)
   end
   
   if ballX >= VIRTUAL_WIDTH - 15 and ballY >= player2Y and ballY <= player2Y + 20 then 
       ballDX = -math.abs(ballDX)
   end
   
   if ballY <= 0 or ballY >= VIRTUAL_HEIGHT then 
       ballDY = -ballDY
   end
end


function love.draw()
    push:apply('start')
    love.graphics.clear(40/255, 50/255, 60/255, 255/255)
    love.graphics.setFont(smallfont)

    if gamestate == 'start' then 
        love.graphics.printf("Start Pong", 0, 10, VIRTUAL_WIDTH, 'center')
    elseif gamestate == 'play' then 
        love.graphics.printf("Play Pong", 0, 10, VIRTUAL_WIDTH, 'center')
    end
    love.graphics.rectangle('fill', 10, player1Y, 5, 20)

    love.graphics.rectangle('fill', VIRTUAL_WIDTH - 10, player2Y, 5, 20)

    love.graphics.rectangle('fill', ballX, ballY, 4, 4)

    love.graphics.setFont(scorefont)
    love.graphics.print(player1Score,VIRTUAL_WIDTH / 2 - 40, VIRTUAL_HEIGHT / 4)

    love.graphics.print(player2Score,VIRTUAL_WIDTH / 2 + 30, VIRTUAL_HEIGHT / 4)

    displayFPS()

    push:apply('end')
end


function displayFPS()
    love.graphics.setColor(0,1,0,1)
    love.graphics.setFont(fpsfont)
    love.graphics.print('FPS'.. tostring(love.timer.getFPS()), 50, 20)
end

function resetBall()
    ballX = VIRTUAL_WIDTH / 2 - 2 
    ballY = VIRTUAL_HEIGHT / 2 - 2 
end