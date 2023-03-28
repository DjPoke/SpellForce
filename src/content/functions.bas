' check collisions with map
def GetMapCollision(l, x, y, w, h)
	col_lst = list()
	
	xc = floor(x + (w / 2))
	yc = floor(y + (h / 2))
	
	o1 = 8 - w - 2
	o2 = 8 - h - 2
	o3 = w - 8 + 1
	o4 = h - 8 + 1
	
	tx1 = floor((xc + o1) / 8)
	ty1 = floor((yc + o2) / 8)
	tx2 = floor((xc + o3) / 8)
	ty2 = floor((yc + o4) / 8)
	
	t = 0
	
	for ty = ty1 to ty2
		for tx = tx1 to tx2
			c = mget l, 0, tx, ty
			if c > 0 then
				push(col_lst, c)
			endif
		next
	next

	return col_lst
enddef

' check collisions between two sprites
def GetCollided(x1, y1, x2, y2, x3, y3, x4, y4)
	if x1 > x4 or x2 < x3 or y1 > y4 or y2 < y3 then
		return false
	endif
	return true
enddef

' play a music when the player win
def PlayWinnerMusic()
	play "O4 L8 C G > C < G > C < G > D E", 0
	play "O2 L8 C G C G C G > C < G > C", 1
enddef

' play a music when the game is over
def PlayEndMusic()
	play "O4 L1 D C O3 D O2 L8 MS D", 0
	play "O4 L8 D < A > D E F A G F L2 E L4 C L16 > MS C C < A > C L8 D < A F D F A F A < D", 1
enddef

' return the intro music channel to play
def GetIntroMusic(chan)
	if chan = 0 then
		p1$ = "O2 ML L1 E D C D"
		p2$ = "O2 ML L1 E D C L2 D O5 L32 E F E F E F E F O6 E F E F E F E F"
		p3$ = "O1 MS L8 A A E G A A E G"
		p4$ = "O1 MS L8 A A E G A A > C < B"
		p5$ = "O2 MS L8 D D < A > C D D F G"
		p6$ = "O5 L32 B > C < B > C < B > C < B > C O4 B > C < B > C < B > C < B > C"
		p7$ = "O4 L32 B > C < B > C < B > C < B > C O5 B > C < B > C < B > C < B > C"
		mus$ = p1$ + p2$
		mus$ = mus$ + p3$ + p3$ + p3$ + p4$
		mus$ = mus$ + p3$ + p3$ + p3$ + p4$
		mus$ = mus$ + p5$ + p5$ + p3$ + p4$
		mus$ = mus$ + p5$ + p5$ + p3$ + p4$
		mus$ = mus$ + p3$ + p3$ + p3$ + p4$
		mus$ = mus$ + p3$ + p3$ + p3$ + p4$
		mus$ = mus$ + p5$ + p5$ + p3$ + p4$
		mus$ = mus$ + p5$ + p5$ + p3$ + p4$
		mus$ = mus$ + p6$ + p7$
	else
		a$ = "O4 L32 A > C E L8 A < P32 L32 A > C E A < P8 A > C E A < P8 A > C E A < P8"
		b$ = "O4 L32 A > C E L8 B < P32 L32 A > C E B < P8 A > C E B < P8 A > C E B < P8"
		c$ = "O4 L32 A > C E > L8 C < < P32 L32 A > C E > C < < P8 A > C E > C < < P8 A > C E > C < < P8"
		d$ = "O4 L32 A > C E > L8 D < < P32 L32 A > C E > D < < P8 A > C E > D < < P8 A > C E > D < < P8"
		e$ = "O4 L32 A > C E > L8 E < < P32 L32 A > C E > E < < P8 A > C E > E < < P8 A > C E > E < < P8"
		f$ = "O4 L32 A > C E > L8 F < < P32 L32 A > C E > F < < P8 A > C E > F < < P8 A > C E > F < < P8"
		c2$ = "O4 L32 > D F A > L8 C < < P32 L32 > D F A > C < < P8 > D F A > C < < P8 > D F A > C < < P8"
		d2$ = "O4 L32 > D F A > L8 D < < P32 L32 > D F A > D < < P8 > D F A > D < < P8 > D F A > D < < P8"
		p1$ = "O4 L8 F E D# E F E D# E"
		p2$ = a$ + b$ + c$ + d$ + e$ + f$ + e$ + d$
		p3$ = d2$ + c2$ + b$ + c$ + d2$ + c2$ + c$ + "O5 L2 B O5 L32 E F E F E F E F O6 E F E F E F E F"
		p4$ = "O5 L32 E F E F E F E F O4 E F E F E F E F"
		p5$ = "O5 L32 E F E F E F E F O6 E F E F E F E F"
		mus$ = p1$ + p1$ + p1$ + p1$ + p1$ + p1$ + p1$ + p1$
		mus$ = mus$ + p2$ + p3$
		mus$ = mus$ + p2$ + p3$
		mus$ = mus$ + p4$ + p5$
	endif
	return mus$
enddef

' open the door when the player win
def OpenDoors(m, l)
	for y = 0 to 19
		for x = 0 to 15
			c = mget m, 1, x, y
			if c = 20 then
				if l = 1 then
					mset m, 1, x, y, 1
				elseif l = 2 then
					mset m, 1, x, y, 19
				elseif l = 4 then
					mset m, 1, x, y, 1
				elseif l = 5 then
					mset m, 1, x, y, 1
				elseif l = 7 then
					mset m, 1, x, y, 19
				elseif l = 8 then
					mset m, 1, x, y, 19
				endif
			elseif c = 28 then
				if l = 3 then
					mset m, 1, x, y, 26
				elseif l = 6 then
					mset m, 1, x, y, 26
				endif
			endif
		next
	next
enddef

' return the number of zombis by level
def GetZombiesCountByLevel(l)
	if l = 1 then
		return 20
	elseif l = 2 then
		return 25
	elseif l = 4 then
		return 10
	elseif l = 5 then
		return 4
	elseif l = 7 then
		return 20
	elseif l = 8 then
		return 12
	endif

	return 0
enddef

' return the number of tentacles by level
def GetTentaclesCountByLevel(l)
	if l = 1 then
		return 4
	elseif l = 4 then
		return 4
	elseif l = 5 then
		return 6
	endif

	return 0
enddef

' return the number of vultures by level
def GetVulturesCountByLevel(l)
	if l = 2 then
		return 8
	elseif l = 4 then
		return 4
	elseif l = 5 then
		return 4
	elseif l = 7 then
		return 10
	elseif l = 8 then
		return 10
	endif

	return 0
enddef

' teleport the player
def TeleportPlayer(t, l, scx, scy)
	co = list(scx, scy)
	
	t = t + 1
	if t > 7 then
		t = t - 4
	endif
	
	for y = 0 to 15
		for x = 0 to 19
			c =  mget l, 0, x, y
			if c = t then
				co(0) = (x * 8) + 2
				co(1) = (y * 8) + 2
				return co
			endif
		next
	next
	return co
enddef

' format the score to show zeros before
def StringFormat(v, n)
	a$ = str(v)
	while len(a$) < n
		a$ = "0" + a$
	wend
	return a$
enddef
