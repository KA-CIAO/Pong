push = require 'push'
Class = require 'class'
require 'Paddle'
require 'Ball'

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

PADDLE_SPEED = 250

function love.load()
    love.graphics.setDefaultFilter('nearest', 'nearest')

    love.window.setTitle('Pong')

    math.randomseed(os.time())

    smallFont = love.graphics.newFont('Retron2000.ttf', 13)
    fpsFont = love.graphics.newFont('Retron2000.ttf', 14)
    largeFont = love.graphics.newFont('Retron2000.ttf', 15)
    scoreFont = love.graphics.newFont('Retron2000.ttf', 33)
    escFont = love.graphics.newFont('Retron2000.ttf', 10)
    love.graphics.setFont(smallFont)

    sounds = {
        ['paddle_hit'] = love.audio.newSource('sounds/paddle_hit.wav', 'static'),
        ['score'] = love.audio.newSource('sounds/score.wav', 'static'),
        ['wall_hit'] = love.audio.newSource('sounds/wall_hit.wav', 'static')
    }
    
    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        resizable = true,
        vsync = true,
        canvas = false
    })


    player1 = Paddle(15, 30, 4, 30)
    player2 = Paddle(VIRTUAL_WIDTH - 15, VIRTUAL_HEIGHT - 50, 4, 30)   
    ball = Ball(VIRTUAL_WIDTH / 2 - 2, VIRTUAL_HEIGHT / 2 - 2, 4, 4)

    player1Score = 0
    player2Score = 0

    servingPlayer = 1

    winningPlayer = 0

    gameMode = ''
    difficulty = ''
    controls = ''
  
    gameState = 'menu_mode'
end

function love.resize(w, h)
    push:resize(w, h)
end

function love.update(dt)
    
    if gameState == 'serve' then
        if gameMode == 'pvp' then             
            if servingPlayer == 1 then
                ball.dx = math.random(150, 200)
                ball.dy = math.random(-50, 50)
             elseif servingPlayer == 2 then  
                ball.dx = -math.random(150, 200)
                ball.dy = math.random(-50, 50)
            end 
        end     
               
        if gameMode == 'cvc' then                   
            if servingPlayer == 1 then
                ball.dx = math.random(150, 200)
                ball.dy = math.random(-50, 50)
                gameState = 'play'
             elseif servingPlayer == 2 then 
                ball.dx = -math.random(150, 200)
                ball.dy = math.random(-50, 50)
                gameState = 'play'
            end 
        end 
        
        if servingPlayer == 1 and gameMode == 'pvc' then
            ball.dx = math.random(150, 200)
            ball.dy = math.random(-50, 50)
         elseif servingPlayer == 2 and gameMode == 'pvc' then 
            ball.dx = -math.random(150, 200)
            ball.dy = math.random(-50, 50)
            gameState = 'play'
         elseif servingPlayer == 1 and gameMode == 'pvc'  then
            ball.dx = math.random(150, 200)
            ball.dy = math.random(-50, 50)
            gameState = 'play'
         elseif servingPlayer == 2 and gameMode == 'pvc' then 
            ball.dx = -math.random(150, 200)
            ball.dy = math.random(-50, 50)
        end
        
    elseif gameState == 'play' then

        if ball:collides(player1) then
            ball.dx = -ball.dx * 1.04
            ball.x = player1.x + 6

            if ball.dy < 0 then
                ball.dy = -math.random(10, 160)
            else
                ball.dy = math.random(10, 160)
            end

            sounds['paddle_hit']:play()
        end
        
        if ball:collides(player2) then
            ball.dx = -ball.dx * 1.03
            ball.x = player2.x - 4

            if ball.dy < 0 then
                ball.dy = -math.random(10, 160)
            else
                ball.dy = math.random(10, 160)
            end

            sounds['paddle_hit']:play()
        end

        if ball.y <= 0 then
            ball.y = 0
            ball.dy = -ball.dy
            sounds['wall_hit']:play()
        end

        if ball.y >= VIRTUAL_HEIGHT - 4 then
            ball.y = VIRTUAL_HEIGHT - 4
            ball.dy = -ball.dy
            sounds['wall_hit']:play()
        end

        if ball.x < 0 then
            servingPlayer = 1
            player2Score = player2Score + 1
            sounds['score']:play()

            if player2Score == 10 then
                winningPlayer = 2
                gameState = 'done'
            else
                gameState = 'serve'
                ball:reset()
            end
        end

        if ball.x > VIRTUAL_WIDTH then
            servingPlayer = 2
            player1Score = player1Score + 1
            sounds['score']:play()

            if player1Score == 10 then
                winningPlayer = 1
                gameState = 'done'
            else
                gameState = 'serve'
                ball:reset()
            end
        end
    end

    if gameMode == 'pvp' then
        if love.keyboard.isDown('w') then
            player1.dy = -PADDLE_SPEED
         elseif love.keyboard.isDown('s') then
            player1.dy = PADDLE_SPEED
        else
            player1.dy = 0
        end

        if love.keyboard.isDown('up') then
            player2.dy = -PADDLE_SPEED
         elseif love.keyboard.isDown('down') then
            player2.dy = PADDLE_SPEED
        else
            player2.dy = 0
        end
     end

    if gameMode == 'pvc' then   
        up_key = 'w'     
        down_key = 's'
     if controls == 'ws' then          
        up_key = 'w'
        down_key = 's'
     elseif controls == 'ud' then
        up_key = 'up'
        down_key = 'down'
     end

     check_width = 0
     if difficulty == 'easy' then
        check_width = VIRTUAL_WIDTH/4
     elseif difficulty == 'medium' then
        check_width = VIRTUAL_WIDTH/2
     elseif difficulty == 'hard' then
        check_width = VIRTUAL_WIDTH
     end


     plr = player1         
     plr_n = player2
     if ((ball.x - plr_n.x)^2)^(0.5)  < check_width then 
        if (plr_n.y > (ball.y + ball.height/2))  then            
            plr_n.dy = -PADDLE_SPEED
         elseif (plr_n.y + plr_n.height < (ball.y + ball.height/2))  then
            plr_n.dy = PADDLE_SPEED
         else
            plr_n.dy = 0
        end
     end

     if love.keyboard.isDown(up_key) then       
        plr.dy = -PADDLE_SPEED
      elseif love.keyboard.isDown(down_key) then
        plr.dy = PADDLE_SPEED
       else
        plr.dy = 0
      end
    
    end

    if gameMode == 'cvc' then
     if ball.x < VIRTUAL_WIDTH/3 then 
       if (player1.y > (ball.y + ball.height/2))  then
          player1.dy = -PADDLE_SPEED
       elseif (player1.y + player1.height < (ball.y + ball.height/2))  then
          player1.dy = PADDLE_SPEED
       else
          player1.dy = 0
       end
     end
  
     if ball.x > 2 * VIRTUAL_WIDTH/3 then
       if (player2.y > (ball.y + ball.height/2))  then
         player2.dy = -PADDLE_SPEED
         elseif (player2.y + player2.height < (ball.y + ball.height/2))  then
         player2.dy = PADDLE_SPEED
         else
        player2.dy = 0
        end
     end
    end
    
    if gameState == 'play' then
        ball:update(dt)
    end

    player1:update(dt)
    player2:update(dt)
end

function love.keypressed(key)
    if key == 'escape' then
        if gameState ~= 'menu_mode' then
         gameState = 'menu_mode'
         ball:reset()
         player1Score = 0
         player2Score = 0
         player1:reset1()
         player2:reset2()
        else
         love.event.quit()
        end
        
    elseif key == 'enter' or key == 'return' then
        
        if  (gameMode == 'cvc') or (gameMode == 'pvp') or (gameMode == 'pvc' and ((servingPlayer == 1) or (servingPlayer == 2))) then
            if gameState == 'start' then
                gameState = 'serve'
             elseif gameState == 'serve' then
                gameState = 'play'
             elseif gameState == 'done' then
                gameState = 'serve'

                ball:reset()

                player1Score = 0
                player2Score = 0

                if winningPlayer == 1 then
                    servingPlayer = 2
                else
                    servingPlayer = 1
                end
            end
            
        elseif  (gameMode == 'pvc') and ((servingPlayer == 2) or (servingPlayer == 1)) then
            if gameState == 'start' then
                gameState = 'serve'    
             end
        end    
end

    if gameState == 'menu_mode' then
        if key == '1'  then
            gameMode = 'pvp'
            gameState = 'start'
         elseif key == '2' then
            gameMode = 'pvc'
            gameState = 'menu_diff'
            sounds['score']:play()
        elseif key == '3' then
            gameMode = 'cvc'
            gameState = 'start'

        end
    
    
     elseif gameState == 'menu_diff' then 
        if key == '1'  then
            difficulty = 'easy'
            gameState = 'menu_ctrl'
            sounds['score']:play()
        elseif key == '2' then
            difficulty = 'medium'
            gameState = 'menu_ctrl'
            sounds['score']:play()
        elseif key == '3' then
            difficulty = 'hard'
            gameState = 'menu_ctrl'
            sounds['score']:play()
        else 
            sounds['score']:play()
        end
        
     elseif gameState == 'menu_ctrl' then
        
        if key == '1' then 
            controls = 'ws'
            gameState = 'start'
            sounds['score']:play()
        elseif key == '2' then
            controls = 'ud'
            gameState = 'start'
            sounds['score']:play()
        else 
            sounds['score']:play()
        end        
        

    end
end

    
function love.draw()
    push:start()

    love.graphics.clear(43/255, 27/255, 23/255, 1)
    
    if gameState == 'start' then
        love.graphics.setFont(smallFont)
        love.graphics.printf('WELCOME TO PONG!', 0, 15, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('Press "Enter" to begin!', 0, 30, VIRTUAL_WIDTH, 'center')
        
    elseif gameState == 'serve' then
        if gameMode == 'pvp' then
            love.graphics.setFont(smallFont)
            love.graphics.printf('Player ' .. tostring(servingPlayer) .. "'s serve!", 
            0, 10, VIRTUAL_WIDTH, 'center')
            love.graphics.printf('Press "Enter" to serve!', 0, 30, VIRTUAL_WIDTH, 'center')
            
         elseif gameMode == 'pvc' then
            if (servingPlayer == 1) then
              love.graphics.setFont(smallFont)
              love.graphics.printf("Player's serve!", 0, 10, VIRTUAL_WIDTH, 'center')
              love.graphics.printf('Press "Enter" to serve!', 0, 30, VIRTUAL_WIDTH, 'center')
            elseif (servingPlayer == 2) then
              love.graphics.setFont(smallFont)
              love.graphics.printf("Computer's serve!", 0, 10, VIRTUAL_WIDTH, 'center')
              love.graphics.printf('Press "Enter" to serve!', 0, 30, VIRTUAL_WIDTH, 'center')
            end
        end
        
    elseif gameState == 'play' then
        love.graphics.setFont(smallFont)
        if gameMode == 'pvc' then
            love.graphics.printf('diff: '..difficulty..'     controls: '..controls, 0, 20, VIRTUAL_WIDTH, 'center')
        end
           
    elseif gameState == 'done' then
        
        if gameMode == 'pvp' then
            love.graphics.setFont(largeFont)
            love.graphics.printf('Player ' .. tostring(winningPlayer) .. ' wins!',
                0, 10, VIRTUAL_WIDTH, 'center')
            love.graphics.setFont(smallFont)
            love.graphics.printf('Press "Enter" to restart!', 0, 70, VIRTUAL_WIDTH, 'center')
         
         elseif gameMode == 'cvc' then
            love.graphics.setFont(largeFont)
            love.graphics.printf('Computer wins!',
                0, 10, VIRTUAL_WIDTH, 'center')
            love.graphics.setFont(smallFont)
            love.graphics.printf('Press "Enter" to restart!', 0, 70, VIRTUAL_WIDTH, 'center')
         
         elseif gameMode == 'pvc' then
            if (winningPlayer == 1) then
              love.graphics.setFont(largeFont)
              love.graphics.printf("Player's wins!", 0, 10, VIRTUAL_WIDTH, 'center')
              love.graphics.setFont(smallFont)
              love.graphics.printf('Press "Enter" to serve!', 0, 70, VIRTUAL_WIDTH, 'center')
            elseif (winnerPlayer == 2) then
              love.graphics.setFont(largeFont)
              love.graphics.printf("Computer's wins!", 0, 10, VIRTUAL_WIDTH, 'center')
              love.graphics.setFont(smallFont)
              love.graphics.printf('Press "Enter" to serve!', 0, 70, VIRTUAL_WIDTH, 'center')
            end
         end
        
        elseif gameState == 'menu_mode' then
        love.graphics.setFont(largeFont)
        love.graphics.printf('Choose a mode. (Press the corresponding number on your keyboard)',0, 25, VIRTUAL_WIDTH, 'center')
        love.graphics.setFont(smallFont)
        love.graphics.printf('1. Player vs Player \n 2. Player vs Computer \n 3. Computer vs Computer', 0, 85, VIRTUAL_WIDTH, 'center')
        love.graphics.setFont(escFont)
        love.graphics.printf('Press "escape" to quit.', 0, VIRTUAL_HEIGHT - 20, VIRTUAL_WIDTH, 'right')
        
        elseif gameState == 'menu_diff' then
        love.graphics.setFont(largeFont)
        love.graphics.printf('Choose a mode. (Press the corresponding number on your keyboard)',0, 25, VIRTUAL_WIDTH, 'center')
        love.graphics.setFont(smallFont)
        love.graphics.printf('1. Easy \n \n 2. Medium \n \n 3. Hard', 0, 85, VIRTUAL_WIDTH, 'center')
        love.graphics.setFont(escFont)
        love.graphics.printf('Press "escape" to quit.', 0, VIRTUAL_HEIGHT - 20, VIRTUAL_WIDTH, 'right')
        
       elseif gameState == 'menu_ctrl' then
        love.graphics.setFont(largeFont)
        love.graphics.printf('Choose a mode. (Press the corresponding number on your keyboard)',0, 25, VIRTUAL_WIDTH, 'center')
        love.graphics.setFont(smallFont)
        love.graphics.printf('1. W-S keys \n \n 2. Arrow keys', 0, 85, VIRTUAL_WIDTH, 'center')
        love.graphics.setFont(escFont)
        love.graphics.printf('Press "escape" to quit.', 0, VIRTUAL_HEIGHT - 20, VIRTUAL_WIDTH, 'right')
        
    end

    displayScore()
    
    if gameState ~= 'menu_mode' and gameState ~= 'menu_diff' and gameState ~= 'menu_ctrl' then
        player1:render()
        player2:render()
        ball:render()
    end

    displayFPS()

    push:apply('end')
end

function displayScore()
    if gameState ~= 'menu_mode' and gameState ~= 'menu_diff' and gameState ~= 'menu_ctrl' then
        love.graphics.setFont(scoreFont)
        love.graphics.print(tostring(player1Score), VIRTUAL_WIDTH / 2 - 50,
            VIRTUAL_HEIGHT / 3)
        love.graphics.print(tostring(player2Score), VIRTUAL_WIDTH / 2 + 30,
            VIRTUAL_HEIGHT / 3)
    end
end

function displayFPS()
    love.graphics.setFont(fpsFont)
    love.graphics.setColor(0, 255, 0, 255)
    love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()), 5, 5)
    love.graphics.setColor(255, 255, 255, 255)
end
