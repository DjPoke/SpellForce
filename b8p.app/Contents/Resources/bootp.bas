REM BASIC8
REM Copyright (C) 2018 - 2021 Wang Renxin
REM Boot program of BASIC8 player.

REM Gets motherboard information.

t = ticks()
print "BASIC8 version: ", version;
print "CPU cores: ", cpu_core_count;
print "Host OS: ", os;
print "  Binary directory: ", get_app_directory();
print "  Working directory: ", get_current_directory();
print "Boot program: ", current_file;

REM Gets plugged information.

' Gets joysticks.
print ;
print "Plugged joysticks:";
joysticks = all_joysticks
if joysticks then
	if len(joysticks) = 0 then
		print "  empty";
	else
		for j in joysticks
			print "  ", j;
		next
	endif
else
	print "  empty";
endif

' Gets expansions.
print "Plugged expansions:";
plugins = loaded_plugins
for p in plugins
	print "  ", p;
next

REM Configurates the machine.

' Sets call stack threshold.
print ;
print "Using call stack threshold: "
cst = 100
if cst = 0 then
	print "infinite";
else
	print cst;
endif
set_call_stack_threshold(cst)

' Sets GC interval.
print ;
print "Using GC interval: "
gci = 0
if gci = 0 then
	print "auto";
else
	print gci;
endif
set_gc_interval(gci)

' Uses extra font.
print ;
print "Using fonts:";
fonts = list("fonts/font.ttf")
use_font(nil, 0, 0, 0)
for f in fonts
	print "  ", f;
	use_font(f, 14, 1)
next
seal_font()

REM Ready!

print ;
t = ticks() - t
print "Cost: ", t, "ms";
print ;
print "READY";
print ;
