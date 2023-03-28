class boss2
	m_basex = 80
	m_basey = 64
	m_x = list()
	m_y = list()
	m_dirx = list()
	m_diry = list()
	m_nbBodyParts = 0
	m_bodyPart = list()
	m_energy = list()
	m_dead = false
	m_throwPowerballsTimer = 0
	def MakeBoss(nbBodyParts, x, y)
		m_basex = x
		m_basey = y
		m_dead = false
		m_nbBodyParts = nbBodyParts
		for i = 0 to m_nbBodyParts - 1
			push(m_bodyPart, load_resource("boss2BodyPart.sprite"))
			r = rnd(1, 3)
			if r = 1 then
				play(m_bodyPart(i), "WALK", "WALKE", true, false)
			elseif r = 2 then
				play(m_bodyPart(i), "W2", "W2E", true, false)
			elseif r = 3 then
				play(m_bodyPart(i), "W3", "W3E", true, false)
			endif
			push(m_x, x - 16 + rnd(0, 32))
			push(m_y, y - 8 + rnd(0, 16))
			push(m_dirx, rnd(0, 2) - 1)
			push(m_diry, rnd(0, 2) - 1)
			push(m_energy, 10)
		next
	enddef
	def MoveBoss(delta)
		for i = 0 to m_nbBodyParts - 1
			if m_energy(i) > 0 then
				if m_x(i) + m_dirx(i) >= m_basex + 16 or m_x(i) + m_dirx(i) <= m_basex - 16 then
					m_dirx(i) =  -m_dirx(i)
				else
					m_x(i) = m_x(i) + (m_dirx(i) * delta * 10)
				endif
				if m_y(i) + m_diry(i) >= m_basey + 8 or m_y(i) + m_diry(i) <= m_basey - 8 then
					m_diry(i) =  -m_diry(i)
				else
					m_y(i) = m_y(i) + (m_diry(i) * delta * 10)
				endif
			endif
		next
		m_throwPowerballsTimer = m_throwPowerballsTimer + delta
	enddef
	def GetObjectCollided(x1, y1, x2, y2)
		for i = 0 to m_nbBodyParts - 1
			x3 = m_x(i) - 6
			y3 = m_y(i) - 6
			x4 = x3 + 5
			y4 = y3 + 5
			if not (x1 > x4 or x2 < x3 or y1 > y4 or y2 < y3) then
				if m_energy(i) > 0 then
					return i
				endif
			endif
		next
		return -1
	enddef
	def Hit(i)
		m_dead = false
		if m_energy(i) > 0 then
			m_energy(i) = m_energy(i) - 1
			if m_energy(i) = 0 then
				m_dead = true
				for j = 0 to m_nbBodyParts - 1
					if m_energy(j) > 0 then
						m_dead = false
						exit
					endif
				next
				play(m_bodyPart(i), "DIEE", "DIEE", false, true)
			endif
		endif
		return m_dead
	enddef
	def GetAlive()
		return not m_dead
	enddef
	def GetHeadCoordinates(i)
		co = list(0, 0)
		while m_energy(i) <= 0
			i = i + 1
			if i =  m_nbBodyParts then
				i = 0
			endif
		wend
		co(0) = m_x(i)
		co(1) = m_y(i)
		return co
	enddef
	def ThrowPowerball()
		if m_throwPowerballsTimer > 1.5 then
			m_throwPowerballsTimer = 0
			return true
		endif
		return false
	enddef
	def DrawBoss()
		for i = 0 to m_nbBodyParts - 1
			spr m_bodyPart(i), m_x(i) - 6, m_y(i) - 6
		next
	enddef
endclass
