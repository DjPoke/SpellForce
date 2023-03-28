class boss1
	m_xcenter = 0
	m_ycenter = 0
	m_angle = 0
	m_ray = 0
	m_speed = 10
	m_separation = 12
	m_nbBodyParts = 0
	m_bodyPart = list()
	m_xangle = list()
	m_xray = 3
	m_energy = 0
	m_dead = false
	m_throwPowerballsTimer = 0
	def MakeBoss(nbBodyParts, x, y, a, r)
		m_energy = 100
		m_dead = false
		m_xcenter = x
		m_ycenter = y
		m_angle = a
		m_ray = r
		m_nbBodyParts = nbBodyParts
		for i = 0 to m_nbBodyParts - 1
			push(m_xangle, (360 / m_nbBodyParts) * i)
			push(m_bodyPart, load_resource("boss1BodyPart.sprite"))
			play(m_bodyPart(i), "WALK", "WALKE", true, false)
		next
	enddef
	def MoveBoss(delta)
		m_angle = m_angle + (m_speed * delta)
		if m_angle >= 360 then
			m_angle = m_angle - 360
		endif
		for i = 0 to m_nbBodyParts - 1
			m_xangle(i) = m_xangle(i) + 5
			if m_xangle(i) >= 360 then
				m_xangle(i) = m_xangle(i) - 360
			endif
		next
		m_throwPowerballsTimer = m_throwPowerballsTimer + delta
	enddef
	def GetObjectCollided(x1, y1, x2, y2)
		for i = 0 to m_nbBodyParts - 1
			x3 = m_xcenter + (m_xray * cos(m_xangle(i) * 3.1415 / 180.0)) + (m_ray * cos((m_angle + (i * m_separation)) * 3.1415 / 180.0)) - 8
			y3 = m_ycenter + (m_xray * sin(m_xangle(i) * 3.1415 / 180.0)) + (m_ray * sin((m_angle + (i * m_separation)) * 3.1415 / 180.0)) - 8
			x4 = x3 + 15
			y4 = y3 + 15
			if not (x1 > x4 or x2 < x3 or y1 > y4 or y2 < y3) then
				return true
			endif
		next
		return false
	enddef
	def Hit()
		if m_energy > 0 then
			m_energy = m_energy - 1
			if m_energy = 0 then
				m_dead = true
				for i = 0 to m_nbBodyParts - 1
					play(m_bodyPart(i), "DIE", "DIEE", false, true)
				next
			endif
		endif
		return m_dead
	enddef
	def GetAlive()
		return not m_dead
	enddef
	def GetHeadCoordinates()
		co = list(0, 0)
		i = rnd(0, m_nbBodyParts - 1)
		co(0) = m_xcenter + (m_xray * cos(m_xangle(i) * 3.1415 / 180.0)) + (m_ray * cos((m_angle + (i * m_separation)) * 3.1415 / 180.0))
		co(1) = m_ycenter + (m_xray * sin(m_xangle(i) * 3.1415 / 180.0)) + (m_ray * sin((m_angle + (i * m_separation)) * 3.1415 / 180.0))
		return co
	enddef
	def ThrowPowerball()
		if m_throwPowerballsTimer > 2 then
			m_throwPowerballsTimer = 0
			return true
		endif
		return false
	enddef
	def DrawBoss()
		for i = 0 to m_nbBodyParts - 1
			spr m_bodyPart(i), m_xcenter + (m_xray * cos(m_xangle(i) * 3.1415 / 180.0)) + (m_ray * cos((m_angle + (i * m_separation)) * 3.1415 / 180.0)) - 8, m_ycenter + (m_xray * sin(m_xangle(i) * 3.1415 / 180.0)) + (m_ray * sin((m_angle + (i * m_separation)) * 3.1415 / 180.0)) - 8
		next
	enddef
endclass
