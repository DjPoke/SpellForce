REM Spell Force
REM Entry program.
REM License: MIT
REM Press Ctrl+R to run.

drv = driver()
print drv, ", detail type is: ", typeof(drv);

' require
import "functions.bas"
import "boss1class.bas"
import "boss2class.bas"

' constants
MAX_FIREBALLS = 4
MAX_ZOMBIES = 8
MAX_TENTACLES = 2
MAX_POWERBALLS = 4
MAX_VULTURES = 3

DEAD = 0
SPAWNING = 1
WALKING = 2
ESCAPING = 3

INTRO = 0
PLAYING = 1
LOSE = 2
OVER = 3

GROUND = 0
WALL = 1
WATER = 2
LAVA = 3
TELEPORT1 = 4
TELEPORT2 = 5
TELEPORT3 = 6
TELEPORT4 = 7

MAX_LEVELS = 8

introImage = load_resource("introImage.quantized")

' load sprites
spellcaster = load_resource("spellcaster.sprite")
fireballs = load_resource("fireballs.sprite")

zombies = list()
for i = 0 to MAX_ZOMBIES - 1
	push(zombies, load_resource("zombi.sprite"))
next

tentacles = list()
for i = 0 to MAX_TENTACLES - 1
	push(tentacles, load_resource("tentacle.sprite"))
next

vultures = list()
for i = 0 to MAX_VULTURES - 1
	push(vultures, load_resource("vulture.sprite"))
next

powerball = load_resource("powerball.sprite")

' map timer, for tiles animation
mapTimer = 0

' player sprites vars
sc = vec2()
target = vec2()
sc.x = 80 - 6
sc.y = 112 - 6
sc_playing = false
scDeadTimer = 0

' define default fireballs
dim fbx(MAX_FIREBALLS)
dim fby(MAX_FIREBALLS)
dim fbstate(MAX_FIREBALLS)

for i = 0 to MAX_FIREBALLS - 1
	fbx(i) = 0
	fby(i) = 0
	fbstate(i) = false
next

' define default zombies
dim zx(MAX_ZOMBIES)
dim zy(MAX_ZOMBIES)
dim zstate(MAX_ZOMBIES)
dim ztimer(MAX_ZOMBIES)
zombiTimer = 0

for i = 0 to MAX_ZOMBIES - 1
	zx(i) = 0
	zy(i) = 0
	zstate(i) = DEAD
	ztimer(i) = 0
	play(zombies(i), "DIEE", "DIEE", true, false)
next

' define default tentacles
dim tex(MAX_TENTACLES)
dim tey(MAX_TENTACLES)
dim testate(MAX_TENTACLES)
dim tetimer(MAX_TENTACLES)
dim tethrow(MAX_TENTACLES)
tentacleTimer = 0

for i = 0 to MAX_TENTACLES - 1
	tex(i) = 0
	tey(i) = 0
	testate(i) = DEAD
	tetimer(i) = 0
	tethrow(i) = false
	play(tentacles(i), "TENE", "TENE", true, false)
next

' define default powerballs
dim pbx(MAX_POWERBALLS)
dim pby(MAX_POWERBALLS)
dim pbstate(MAX_POWERBALLS)

for i = 0 to MAX_POWERBALLS - 1
	pbx(i) = 0
	pby(i) = 0
	pbstate(i) = false
next

' define default vultures
dim vx(MAX_VULTURES)
dim vy(MAX_VULTURES)
dim vdir(MAX_VULTURES)
dim vstate(MAX_VULTURES)
vultureTimer = 0

for i = 0 to MAX_VULTURES - 1
	vx(i) = 0
	vy(i) = 0
	vdir(i) = 0
	vstate(i) = DEAD
	play(vultures(i), "DIEE", "DIEE", true, false)
next

' sounds
killMonsterSound = wave()
push(killMonsterSound, 2, 987.77, 0.0625, 1)
push(killMonsterSound, 2, 698.46, 0.0625, 1)
push(killMonsterSound, 4098, 523.25, 0.0625, 1)
push(killMonsterSound, 4098, 392, 0.0625, 1)
push(killMonsterSound, 4098, 261.63, 0.0625, 1)
push(killMonsterSound, 4098, 174.61, 0.0625, 1)

hitMonsterSound = wave()
push(hitMonsterSound, 1, 246.94, 0.125, 1)
push(hitMonsterSound, 1, 220, 0.125, 0.846154)
push(hitMonsterSound, 1, 196, 0.125, 0.538462)
push(hitMonsterSound, 1, 174.61, 0.125, 0.153846)

fireballsSound = wave()
push(fireballsSound, 5, 130.81, 0.0625, 1)
push(fireballsSound, 5, 220, 0.0625, 0.769231)
push(fireballsSound, 5, 349.23, 0.0625, 0.538462)
push(fireballsSound, 5, 659.26, 0.0625, 0.307692)
push(fireballsSound, 5, 987.77, 0.0625, 0.0769231)

powerBallSound = wave()
push(powerBallSound, 5, 164.81, 0.0625, 1)
push(powerBallSound, 1, 174.61, 0.03125, 0.769231)
push(powerBallSound, 1, 220, 0.03125, 0.615385)
push(powerBallSound, 1, 329.63, 0.03125, 0.384615)

teleportSound = wave()
push(teleportSound, 1, 261.63, 0.125, 0.538462)
push(teleportSound, 3, 440, 0.125, 0.692308)
push(teleportSound, 2, 659.26, 0.125, 0.846154)
push(teleportSound, 4, 880, 0.125, 1)

music0$ = GetIntroMusic(0)
music1$ = GetIntroMusic(1)

' init game
level = 0
lives = 0
score = 0
enabledCommands = true
winner = false
winTimer = 0
layers = nil
layer1 = nil
nbZombiesAlive = 0
nbTentaclesAlive = 0
nbVulturesAlive = 0
boss = nil
bossDeadDelay = 0

' stage of the game
stage = INTRO

' start the music
play music0$, 0, 0, true
play music1$, 1, 0, true

' ===============================================================================

def playerIsDead()
	' delete zombies
	for i = 0 to MAX_ZOMBIES - 1
		zstate(i) = DEAD
		play(zombies(i), "DIEE", "DIEE", true, false)
	next
	' delete tentacles
	for i = 0 to MAX_TENTACLES - 1
		testate(i) = DEAD
		play(tentacles(i), "TENE", "TENE", true, false)
	next
	' delete vultures
	for i = 0 to MAX_VULTURES - 1
		vstate(i) = DEAD
		play(vultures(i), "DIEE", "DIEE", true, false)
	next
	' delete fireballs
	for i = 0 to MAX_FIREBALLS - 1
		fbstate(i) = false
	next
	' delete powerballs
	for i = 0 to MAX_POWERBALLS - 1
		pbstate(i) = false
	next
	if level = 3 then
		boss = new(boss1)
		boss.MakeBoss(8, 80, 64, 270, 40)
	elseif level = 6 then
		boss = new(boss2)
		boss.MakeBoss(16, 80, 48)
	endif
	stage = LOSE
	play(spellcaster, "DIE","DIEE", false, true)
	play "O2 L4 D < A A# A > D", 0
	play "O3 L4 D > A A# A < D", 1
	scDeadTimer = 0
enddef

' ===============================================================================

' game title
def title(delta)

	cls

	' push start timer
	if pushStartTimer = nil then
		pushStartTimer = 0
	endif
	
	pushStartTimer = pushStartTimer + delta

	if pushStartTimer >= 1.0 then
		pushStartTimer = 0
	endif

	' draw intro image
	img introImage, 0, 0
	
	' text push start
	if pushStartTimer <= 0.5 then
		text 41, 81, "Push Start"
	endif
	
	' gamepad action button
	if btnp(4, 0) or btnp(4, 1) then
		stop 0
		stop 1
		stage = PLAYING
		level = 1
		lives = 3
		score = 0
		enabledCommands = true
		winner = false
		winTimer = 0
		layers = load_resource(str(level) + ".map")
		layer1 = get(layers, 1)
		nbZombiesAlive = GetZombiesCountByLevel(level)
		nbTentaclesAlive = GetTentaclesCountByLevel(level)
		nbVulturesAlive = GetVulturesCountByLevel(level)
		if level = 3 then
			boss = new(boss1)
			boss.MakeBoss(8, 80, 64, 270, 40)
		elseif level = 6 then
			boss = new(boss2)
			boss.MakeBoss(16, 80, 48)
		endif
	endif
	
	' quit the game on escape key pressed
	if keyp(27) then
		cls
		end
	endif
enddef

' ===============================================================================

' game function
def battle(delta)
	
	' update the map (water, lava, etc.)
	mapTimer = mapTimer + delta
	
	if mapTimer > 0.5 then
		mapTimer = 0
		for y = 0 to 15
			for x = 0 to 19
				c = mget layers, 1, x, y
				if c = 5 then
					mset layers, 1, x, y, 13
				elseif c = 13 then
					mset layers, 1, x, y, 5
				elseif c = 6 then
					mset layers, 1, x, y, 14
				elseif c = 14 then
					mset layers, 1, x, y, 6
				endif
			next
		next
	endif

	' ===============================================================================
	
	' if commands are enabled...
	if enabledCommands then
		' player's vars
		sc_moving = false
		target.x = sc.x
		target.y = sc.y
		teleport_value = 0
		col_wall = false
		col_water = false
		col_lava = false
		col_teleport = false
	
		' left movement
		if btn(0, 0) or btn(0, 1) then
			target.x = target.x - (delta * 30)
			sc_moving = true
			if sc_playing = false then
				sc_playing = true
				play(spellcaster, "WALK", "WALKE")
			endif
		endif

		' right movement
		if btn(1, 0) or btn(1, 1) then
			target.x = target.x + (delta * 30)
			sc_moving = true
			if not sc_playing then
				sc_playing = true
				play(spellcaster, "WALK", "WALKE")
			endif
		endif

		' check collisions with map
		tcolx = GetMapCollision(layers, target.x, sc.y, 12, 12)

		' move on x axis only if there are no collisions
		if len(tcolx) = 0 then
			sc.x = target.x
		else
			col_wall = false
			col_water = false
			col_lava = false
			col_teleport = false
			for i = 0 to len(tcolx) - 1
				if tcolx(i) = 1 then
					col_wall = true
				elseif tcolx(i) = 2 then
					col_water = true
				elseif tcolx(i) = 3 then
					col_lava = true
				elseif tcolx(i) >= 4 and tcolx(i) <=7 then
					col_teleport = true
					teleport_value = tcolx(i)
				endif
			next
			if not col_wall and not col_water then
				sc.x = target.x
				if col_lava then
					PlayerIsDead()
				endif
			endif
		endif
	
		' up movement
		if btn(2, 0) or btn(2, 1) then
			target.y = target.y - (delta * 30)
			sc_moving = true
			if not sc_playing then
				sc_playing = true
				play(spellcaster, "WALK", "WALKE")
			endif
		endif

		' down movement
		if btn(3, 0) or btn(3, 1) then
			target.y = target.y + (delta * 30)
			sc_moving = true
			if not sc_playing then
				sc_playing = true
				play(spellcaster, "WALK", "WALKE")
			endif
		endif
	
		' check collisions with map
		tcoly = GetMapCollision(layers, sc.x, target.y, 12, 12)

		' move on y axis only if there are no collisions
		if len(tcoly) = 0 then
			sc.y = target.y
		else
			col_wall = false
			col_water = false
			col_lava = false
			col_teleport = false
			for i = 0 to len(tcoly) - 1
				if tcoly(i) = 1 then
					col_wall = true
				elseif tcoly(i) = 2 then
					col_water = true
				elseif tcoly(i) = 3 then
					col_lava = true
				elseif tcoly(i) >= 4 and tcoly(i) <=7 then
					col_teleport = true
					teleport_value = tcoly(i)
				endif
			next
			if not col_wall and not col_water then
				sc.y = target.y
				if col_lava then
					PlayerIsDead()
				endif
			endif
		endif
	
		' use teleporter
		if col_teleport then
			' blink when the player is on it
			if mapTimer < 0.25 then
				for y = 0 to 15
					for x = 0 to 19
						cc = mget layers, 0, x, y
						if cc = teleport_value or cc = teleport_value + 4 then
							c = mget layers, 1, x, y
							if c = 21 then
								mset layers, 1, x, y, 22
							endif
						else
							c = mget layers, 1, x, y
							if c = 22 then
								mset layers, 1, x, y, 21
							endif
						endif
					next
				next
			else
				for y = 0 to 15
					for x = 0 to 19
						cc = mget layers, 0, x, y
						if cc = teleport_value or cc = teleport_value + 4 then
							c = mget layers, 1, x, y
							if c = 22 then
								mset layers, 1, x, y, 21
							endif
						endif
					next
				next
			endif
			' push B button
			if btnp(5, 0) or btnp(5, 1) then
				sctemp = list()
				sctemp = TeleportPlayer(teleport_value, layers, sc.x, sc.y)
				sc.x = sctemp(0)
				sc.y = sctemp(1)
				sfx teleportSound
			endif
		else
			for y = 0 to 15
				for x = 0 to 19
					c = mget layers, 1, x, y
					if c = 22 then
						mset layers, 1, x, y, 21
					endif
				next
			next
		endif
		
		' stop animation of the player
		if not sc_moving and sc_playing then
			sc_playing = false
			stop(spellcaster)
		endif
	endif
	
	' ===============================================================================
	
	' move fireballs
	for i = 0 to MAX_FIREBALLS - 1
		if fbstate(i) then
			fby(i) = fby(i) - (delta * 120)
			if fby(i) < 0 then
				fbstate(i) = false
			endif
			
			c = GetMapCollision(layers, fbx(i), fby(i), 12, 12)
			for j = 0 to len(c) - 1
				if c(j) = 1 then
					fbstate(i) = false
				endif
			next
		endif
	next
	
	' if commands are enabled...
	if enabledCommands then
		' throw fireballs
		if btnp(4, 0) or btnp(4, 1) then
			for i = 0 to MAX_FIREBALLS - 1
				if not fbstate(i) then
					fbstate(i) = true
					fbx(i) = sc.x
					fby(i) = sc.y
					sfx fireballsSound
					exit
				endif
			next
		endif
	endif

	' ===============================================================================
	
	' increment the timers	
	zombiTimer = zombiTimer + delta
	tentacleTimer = tentacleTimer + delta
	vultureTimer = vultureTimer + delta

	' ===============================================================================
	
	' spawn zombies
	if zombiTimer > 1 then
		zombiTimer = 0
		if nbZombiesAlive > 0 then
			for i = 0 to MAX_ZOMBIES - 1
				if zstate(i) = DEAD then
					v = rnd(1, 8)
					if v = 1 then
						cpt = 0
						for j = 0 to MAX_ZOMBIES - 1
							if zstate(j) = SPAWNING or zstate(j) = WALKING then
								cpt = cpt + 1
							endif
						next
						if cpt < nbZombiesAlive then
							zx(i) = 20 + (rnd(0, 10) * 12)
							zy(i) = 20 + (rnd(0, 4) * 12)
							c = GetMapCollision(layers, zx(i), zy(i), 12, 12)
							if len(c) = 0 then
								zstate(i) = SPAWNING
								play(zombies(i), "SPAWN", "SPAWNE", false, true)
								exit
							endif
						endif
					endif
				endif
			next
		endif
	endif
	
	' prepare zombies to walk
	for i = 0 to MAX_ZOMBIES - 1
		if zstate(i) = SPAWNING then
			ztimer(i) = ztimer(i) + delta
			if ztimer(i) > 1 then
				zstate(i) = WALKING
				ztimer(i) = 0
				play(zombies(i), "WALK", "WALKE")
			endif			
		elseif zstate(i) = ESCAPING then
			ztimer(i) = ztimer(i) + delta
			if ztimer(i) > 1 then
				zstate(i) = DEAD
				ztimer(i) = 0
				play(zombies(i), "DIEE", "DIEE", true, false)
			endif			
		endif
	next
	
	' move zombies
	for i = 0 to MAX_ZOMBIES - 1
		if zstate(i) = WALKING then
			zy(i) = zy(i) + (delta * 8)
			if zy(i) > 128 - 16 then
				zstate(i) = ESCAPING
				play(zombies(i), "DIE", "DIEE", false, true)
			else
				c = GetMapCollision(layers, zx(i), zy(i), 12, 12)
				for j = 0 to len(c) - 1
					if c(j) >= 1 and c(j) <= 3 then
						zstate(i) = ESCAPING
						play(zombies(i), "DIE", "DIEE", false, true)
					endif
				next
			endif
		endif
	next
	
	' ===============================================================================
	
	' spawn tentacles
	if tentacleTimer > 2.5 then
		tentacleTimer = 0
		if nbTentaclesAlive > 0 then
			for i = 0 to MAX_TENTACLES - 1
				if testate(i) = DEAD then
					r = rnd(1, 3)
					if r = 1 then
						' on level 1...
						if level = 1 then
							cpt = 0
							for j = 0 to MAX_TENTACLES - 1
								if testate(j) = WALKING then
									cpt = cpt + 1
								endif
							next
							if cpt < nbTentaclesAlive then
								tex(i) = rnd(56, 104)
								tey(i) = 24
								testate(i) = WALKING
								tethrow(i) = false
								play(tentacles(i), "TEN", "TENE", false, true)
								tetimer(i) = 2
								exit
							endif
						elseif level = 4 then
							cpt = 0
							for j = 0 to MAX_TENTACLES - 1
								if testate(j) = WALKING then
									cpt = cpt + 1
								endif
							next
							if cpt < nbTentaclesAlive then
								tex(i) = rnd(64, 96)
								tey(i) = 32
								testate(i) = WALKING
								tethrow(i) = false
								play(tentacles(i), "TEN", "TENE", false, true)
								tetimer(i) = 2
								exit
							endif
						elseif level = 5 then
							cpt = 0
							for j = 0 to MAX_TENTACLES - 1
								if testate(j) = WALKING then
									cpt = cpt + 1
								endif
							next
							if cpt < nbTentaclesAlive then
								tex(i) = rnd(56, 104)
								tey(i) = 56
								testate(i) = WALKING
								tethrow(i) = false
								play(tentacles(i), "TEN", "TENE", false, true)
								tetimer(i) = 2
								exit
							endif
						endif
					endif
				endif
			next
		endif
	endif
		
	' move tentacles
	for i = 0 to MAX_TENTACLES - 1
		if testate(i) = WALKING then
			tetimer(i) = tetimer(i) - delta
			if tetimer(i) <= 0 then
				tetimer(i) = 0
				testate(i) = DEAD
				tethrow(i) = false
				play(tentacles(i), "TENE", "TENE", true, false)
			endif
		endif
	next
	
	' ===============================================================================
	
	' spawn vulture
	if vultureTimer > 1.5 then
		vultureTimer = 0
		if nbVulturesAlive > 0 then
			for i = 0 to MAX_VULTURES - 1
				if vstate(i) = DEAD then
					r = rnd(1, 4)
					if r = 1 then
						flp = rnd(1, 2)
						if flp = 1 then
							cpt = 0
							for j = 0 to MAX_VULTURES - 1
								if vstate(j) = WALKING then
									cpt = cpt + 1
								endif
							next
							if cpt < nbVulturesAlive then
								vx(i) = 160
								vy(i) = 16 + (rnd(0, 8) * 12)
								vdir(i) = -1
								vstate(i) = WALKING
								flip_x(vultures(i), true)
								play(vultures(i), "FLY", "FLYE", true, false)
								exit
							endif
						else
							cpt = 0
							for j = 0 to MAX_VULTURES - 1
								if vstate(j) = WALKING then
									cpt = cpt + 1
								endif
							next
							if cpt < nbVulturesAlive then
								vx(i) = -12
								vy(i) = 16 + (rnd(0, 8) * 12)
								vdir(i) = 1
								vstate(i) = WALKING
								flip_x(vultures(i), false)
								play(vultures(i), "FLY", "FLYE", true, false)
								exit
							endif
						endif
					endif
				endif
			next
		endif
	endif
		
	' move vulture
	for i = 0 to MAX_VULTURES - 1
		if vstate(i) = WALKING then
			vx(i) = vx(i) + (vdir(i) * delta * 40)
			if (vdir(i) = 1 and vx(i) >= 160) or (vdir(i) = -1 and vx(i) <= -12) then
				vstate(i) = DEAD
				vdir(i) = 0
				play(vultures(i), "DIEE", "DIEE", true, false)
			endif
		endif
	next
	
	' ===============================================================================
	
	' a tentacle throw a powerball
	for i = 0 to MAX_TENTACLES - 1
		if testate(i) = WALKING then
			if tetimer(i) <= 1 and not tethrow(i) then
				for j = 0 to MAX_POWERBALLS - 1
					if not pbstate(j) then
						tethrow(i) = true
						pbstate(j) = true
						pbx(j) = tex(i)
						pby(j) = tey(i)
						pbx(j) = pbx(j) + 2
						pby(j) = pby(j) + 8
						exit
					endif
				next
			endif
		endif
	next

	' move powerballs
	for i = 0 to MAX_POWERBALLS - 1
		if pbstate(i) then
			pby(i) = pby(i) + (delta * 40)
			if pby(i) < 128 then
				c = GetMapCollision(layers, pbx(i), pby(i), 8, 8)
				for j = 0 to len(c) - 1
					if c(j) = 1 then
						pbstate(i) = false
						sfx powerBallSound
					endif
				next
			else 
				pbstate(i) = false
				sfx powerBallSound
			endif
		endif
	next
	
	' ===============================================================================

	' update the current boss position
	if level = 3 then
		if boss.GetAlive() then
			boss.MoveBoss(delta)
			' throw a powerball
			if boss.ThrowPowerball() then
				for j = 0 to MAX_POWERBALLS - 1
					if not pbstate(j) then
						pbstate(j) = true
						co = list()
						co = boss.GetHeadCoordinates()
						pbx(j) = co(0) - 4
						pby(j) = co(1) - 4
						exit
					endif
				next
			endif
		endif
	elseif level = 6 then
		if boss.GetAlive() then
			boss.MoveBoss(delta)
			' throw a powerball
			if boss.ThrowPowerball() then
				for j = 0 to MAX_POWERBALLS - 1
					if not pbstate(j) then
						pbstate(j) = true
						co = list()
						co = boss.GetHeadCoordinates(rnd(0, 15))
						pbx(j) = co(0) - 4
						pby(j) = co(1) - 4
						exit
					endif
				next
			endif
		endif
	endif

	' ===============================================================================

	' the player collides with a zombi
	for j = 0 to MAX_ZOMBIES - 1
		if zstate(j) = WALKING then
			if GetCollided(sc.x, sc.y, sc.x + 11, sc.y + 10, zx(j), zy(j), zx(j) + 11, zy(j) + 10) then
				PlayerIsDead()
			endif
		endif
	next
	
	' the player collides with a tentacle
	for j = 0 to MAX_TENTACLES - 1
		if testate(j) then
			if GetCollided(sc.x, sc.y, sc.x + 11, sc.y + 10, tex(j), tey(j), tex(j) + 11, tey(j) + 10) then
				PlayerIsDead()
			endif
		endif
	next
	
	' the player collides with a powerball
	for j = 0 to MAX_POWERBALLS - 1
		if pbstate(j) then
			if GetCollided(sc.x, sc.y, sc.x + 11, sc.y + 11, pbx(j), pby(j), pbx(j) + 7, pby(j) + 7) then
				PlayerIsDead()
			endif
		endif
	next
	
	' the player collides with a vulture
	for j = 0 to MAX_VULTURES - 1
		if vstate(j) = WALKING then
			if GetCollided(sc.x, sc.y, sc.x + 9, sc.y + 11, vx(j), vy(j), vx(j) + 7, vy(j) + 7) then
				PlayerIsDead()
			endif
		endif
	next
	
	' the player collides with a boss
	if level = 3 then
		if boss.GetObjectCollided(sc.x, sc.y, sc.x + 11, sc.y + 11) then
			PlayerIsDead()
		endif
	elseif level = 6 then
		c = boss.GetObjectCollided(sc.x, sc.y, sc.x + 11, sc.y + 11) then
		if c > -1 then
			PlayerIsDead()
		endif
	endif
	
	' ===============================================================================

	' fireballs hit monsters
	for j = 0 to MAX_FIREBALLS - 1
		' zombies
		if fbstate(j) then
			for i = 0 to MAX_ZOMBIES - 1
				if zstate(i) = WALKING then
					if GetCollided(fbx(j), fby(j), fbx(j) + 11, fby(j) + 3, zx(i), zy(i), zx(i) + 11, zy(i) + 11) then
						fbstate(j) = false
						zstate(i) = ESCAPING
						play(zombies(i), "DIE", "DIEE", false, true)
						sfx killMonsterSound
						nbZombiesAlive = nbZombiesAlive - 1
						score = score + 50
					endif
				endif
			next
		endif
		' tentacles
		if fbstate(j) then
			for i = 0 to MAX_TENTACLES - 1
				if testate(i) = WALKING then
					if GetCollided(fbx(j), fby(j), fbx(j) + 11, fby(j) + 3, tex(i), tey(i), tex(i) + 11, tey(i) + 11) then
						fbstate(j) = false
						testate(i) = DEAD
						play(tentacles(i), "TENE", "TENE", true, false)
						sfx killMonsterSound
						nbTentaclesAlive = nbTentaclesAlive - 1
						score = score + 100
					endif
				endif
			next
		endif
		' vultures
		if fbstate(j) then
			for i = 0 to MAX_VULTURES - 1
				if vstate(i) = WALKING then
					if GetCollided(fbx(j), fby(j), fbx(j) + 11, fby(j) + 3, vx(i), vy(i), vx(i) + 7, vy(i) + 7) then
						fbstate(j) = false
						vstate(i) = DEAD
						play(vultures(i), "DIEE", "DIEE", true, false)
						sfx killMonsterSound
						nbVulturesAlive = nbVulturesAlive - 1
						score = score + 200
					endif
				endif
			next
		endif
		' boss
		if level = 3 then
			if fbstate(j) then
				if boss.GetAlive() then
					if boss.GetObjectCollided(fbx(j), fby(j), fbx(j) + 11, fby(j) + 3) then
						fbstate(j) = false
						sfx hitMonsterSound
						score = score + 10
						if boss.Hit() then
							score = score + 2000
							play "O4 L8 C E G > L4 C", 0
							play "O4 L8 E G > C L4 E", 1
							bossDeadDelay = 1
						endif
					endif
				endif
			endif
		elseif level = 6 then
			if fbstate(j) then
				if boss.GetAlive() then
					c = boss.GetObjectCollided(fbx(j), fby(j), fbx(j) + 11, fby(j) + 3)
					if c > -1 then
						fbstate(j) = false
						sfx hitMonsterSound
						score = score + 10
						if boss.Hit(c) then
							score = score + 2000
							play "O4 L8 C E G > L4 C", 0
							play "O4 L8 E G > C L4 E", 1
							bossDeadDelay = 1
						endif
					endif
				endif
			endif
		endif
	next
	
	' ===============================================================================

	' count alive monsters, and win if there are no more ones
	if nbZombiesAlive = 0 and nbTentaclesAlive = 0 and nbVulturesAlive = 0 and enabledCommands and level mod 3 <> 0 and stage = PLAYING then
		' delete fireballs
		for i = 0 to MAX_FIREBALLS - 1
			if fbstate(i) then
				fbstate(i) = false
			endif
		next
		' delete powerballs
		for i = 0 to MAX_POWERBALLS - 1
			if pbstate(i) <> false then
				pbstate(i) = false
			endif
		next
		enabledCommands = false
		winner = true
		winTimer = 0
		PlayWinnerMusic()
		OpenDoors(layers, level)
		play(spellcaster, "WALK", "WALKE")
	endif

	' if the current level is versus a boss, check if we win
	if level mod 3 = 0 then
		if not boss.GetAlive() and not winner then
			bossDeadDelay = bossDeadDelay - delta
			if bossDeadDelay <= 0 then
				bossDeadDelay = 0
				' delete fireballs
				for i = 0 to MAX_FIREBALLS - 1
					if fbstate(i) then
						fbstate(i) = false
					endif
				next
				' delete powerballs
				for i = 0 to MAX_POWERBALLS - 1
					if pbstate(i) <> false then
						pbstate(i) = false
					endif
				next
				enabledCommands = false
				winner = true
				winTimer = 0
				PlayWinnerMusic()
				OpenDoors(layers, level)
				play(spellcaster, "WALK", "WALKE")
			endif
		endif
	endif
		
	' ===============================================================================

	' if the player won
	if winner then
		winTimer = winTimer + delta
		if winTimer > 5 then
			stop(spellcaster)
			winner = false
			winTimer = 0
			level = level + 1
			if level > MAX_LEVELS then
				level = 1
			endif
			layers = load_resource(str(level) + ".map")
			layer1 = get(layers, 1)
			sc.x = 80 - 6
			sc.y = 112 - 6
			sc_playing = false
			enabledCommands = true
			nbZombiesAlive = GetZombiesCountByLevel(level)
			nbTentaclesAlive = GetTentaclesCountByLevel(level)
			nbVulturesAlive = GetVulturesCountByLevel(level)
			if level = 3 then
				boss = new(boss1)
				boss.MakeBoss(8, 80, 64, 270, 40)
			elseif level = 6 then
				boss = new(boss2)
				boss.MakeBoss(16, 80, 48)
			endif
		endif
	endif
	
	' ===============================================================================

	' draw the map
	map layer1, 0, 0

	' draw zombies
	for i = 0 to MAX_ZOMBIES - 1
		spr zombies(i), zx(i), zy(i)
	next

	' draw tentacles
	for i = 0 to MAX_TENTACLES - 1
		spr tentacles(i), tex(i), tey(i)
	next

	' draw the player
	spr spellcaster, sc.x, sc.y

	' draw fireballs
	for i = 0 to MAX_FIREBALLS - 1
		if fbstate(i) then
			spr fireballs, fbx(i), fby(i)
		endif
	next

	' draw powerballs
	for i = 0 to MAX_POWERBALLS - 1
		if pbstate(i) then
			spr powerball, pbx(i), pby(i)
		endif
	next
	
	' draw vultures
	for i = 0 to MAX_VULTURES - 1
		spr vultures(i), vx(i), vy(i)
	next
	
	' draw boss
	if level mod 3 = 0 then
		boss.DrawBoss()
	endif

	' draw the score and the lives
	rectfill 0, 0, 160, 7, rgba(0, 0, 0, 128)
	text 8, 0, StringFormat(score, 7)
	text 88, 0, "Lives: " + str(lives)
	
	' ===============================================================================
		
	' quit the game on escape key pressed
	if keyp(27) then
		cls
		end
	endif
enddef

' ===============================================================================

def lost(delta)

	' update the map (water, lava, etc.)
	mapTimer = mapTimer + delta
	
	if mapTimer > 0.5 then
		mapTimer = 0
		for y = 0 to 15
			for x = 0 to 19
				c = mget layers, 1, x, y
				if c = 5 then
					mset layers, 1, x, y, 13
				elseif c = 13 then
					mset layers, 1, x, y, 5
				elseif c = 6 then
					mset layers, 1, x, y, 14
				elseif c = 14 then
					mset layers, 1, x, y, 6
				endif
			next
		next
	endif

	' draw the map
	map layer1, 0, 0

	' draw player sprite dying alone
	spr spellcaster, sc.x, sc.y	

	' ===============================================================================
	
	scDeadTimer = scDeadTimer + delta
	if scDeadTimer > 5 then
		stop(spellcaster)
		scDeadTimer = 0
		layers = load_resource(str(level) + ".map")
		layer1 = get(layers, 1)
		sc.x = 80 - 6
		sc.y = 112 - 6
		sc_playing = false
		enabledCommands = true
		nbZombiesAlive = GetZombiesCountByLevel(level)
		nbTentaclesAlive = GetTentaclesCountByLevel(level)
		nbVulturesAlive = GetVulturesCountByLevel(level)
		lives = lives - 1
		if level = 3 then
			boss = new(boss1)
			boss.MakeBoss(8, 80, 64, 270, 40)
		elseif level = 6 then
			boss = new(boss2)
			boss.MakeBoss(16, 80, 48)
		endif
		if lives > 0 then
			stage = PLAYING
		else
			stage = OVER
			PlayEndMusic()
		endif
	endif
	
	' ===============================================================================

	' draw the score and the lives
	text 8, 0, StringFormat(score, 7)
	text 88, 0, "Lives: " + str(lives)
	
	' ===============================================================================

	' quit the game on escape key pressed
	if keyp(27) then
		cls
		end
	endif
enddef

' ===============================================================================

def gameover(delta)

	' clear the screen in black
	rectfill 0, 0, 160, 128, rgba(0, 0, 0, 255)
	
	' text gameover
	text 44, 44, "GAME OVER"

	' gamepad action button
	if btnp(4, 0) or btnp(4, 1) then
		stage = INTRO
		
		' start the music
		play music0$, 0, 0, true
		play music1$, 1, 0, true
	endif

' ===============================================================================

	' quit the game on escape key pressed
	if keyp(27) then
		cls
		end
	endif
enddef

' ===============================================================================

update_with
(
	drv,
	lambda (delta)
	(
		if stage = INTRO then
			title(delta)
		elseif stage = PLAYING then
			battle(delta)
		elseif stage = LOSE then
			lost(delta)
		elseif stage = OVER then
			gameover(delta)
		endif
	)
)
