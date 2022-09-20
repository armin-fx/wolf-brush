include <tools.scad>

height = 8;
width  = 14;

slot_width   =  width - 2* 3.0;
slot_length  = 14;
length = 24;

$fd=0.02;

difference()
{
	center ([0      ,width ,0     ])
	cube   ([length ,width ,height]);
	
	translate_x (slot_width/2 + length-slot_length)
	cylinder_extend(d=slot_width, h=height);
	
	translate_x(slot_width/2 + length-slot_length)
	center ([0                     , slot_width, 0])
	cube   ([slot_length-slot_width/2, slot_width, height]);
}


function mult_each (list, list2) =
	[ for (i=[0:len(list)-1]) list[i] * list2[i] ]
;

function center_list (list, size, axis) =
	let(
		Size   = parameter_numlist (3, size, preset=[0,0,0], fill=0),
		Axis   = parameter_numlist (3, axis, preset=[1,1,1], fill=0),
		Center = mult_each (Size, Axis) / -2
	)
	translate_list(list, Center)
;
module center (size, axis)
{
	Size   = parameter_numlist (3, size, preset=[0,0,0], fill=0);
	Axis   = parameter_numlist (3, axis, preset=[1,1,1], fill=0);
	Center = mult_each (Size, Axis) / -2;
	translate(Center)
	children();
}
