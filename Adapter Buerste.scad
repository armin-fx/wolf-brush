include <banded.scad>

/* [Assembly] */

component = "complete"; // ["complete", "parts together", "tongue part", "screw part", "test_clips"]

link_type = "tongue through"; // ["tongue short", "tongue long hidden", "tongue through", "clips"]

glue_bags = true;

debug = "none"; // ["none", "slice top", "slice side"]

/* [3D-Print] */

type = "component"; // ["component", "printable"]

support             = false;
support_gap_z       = 0.1;
support_gap_xy      = 0.5;
support_line_width  = 0.7;
support_brim_height = 0.4;

/* [Common] */

wall = 3;

gap_component = 0.12;

glue_bag_depth = 0.25; // [0.05:0.05:1]
glue_bag_slot  = 1.0; // [0.1:0.1:3]

/* [Tongue] */

// original: 76mm
tongue_length    = 75.5;
tongue_width     = 18;
tongue_thickness =  7;
//
tongue_end_length = 5;
tongue_chamfer_length = 2;
tongue_chamfer_heigth = 1;
tongue_hole_width    = 11.4;
tonque_hole_length   = 13.0;
tongue_hole_straight =  6;
tongue_hole_begin = 5;
//
tongue_bind_length          = 3;
tongue_bind_thickness_begin = 0.3;
tongue_bind_thickness_end   = 1.3;

/* [Shaft] */

shaft_length    =  1;
shaft_width     = 29;
shaft_thickness = 23;
// Parameter of superellipse
shaft_n = 2.2;

/* [Screw] */

screw_diameter_begin = 27;
screw_diameter_end   = 21;
screw_depth          = 24;
screw_cylinder_depth =  1;
//
screw_pitch          = 4;
screw_tooth_diameter = 2;
screw_tooth_depth    = 1;
//
screw_outer_diameter = 34;

/* [Hidden] */

$fd=0.01;

screw_length = shaft_length+10+screw_cylinder_depth+screw_depth;

shaft_curve = superellipse_curve (interval=[0,360], r=0.5, a=[shaft_thickness,shaft_width], n=shaft_n, slices="x");

if (debug=="none") show();
if (debug=="slice top")  object_slice(axis=[0,0,1]) show();
if (debug=="slice side") object_slice(axis=[0,1,0]) show();

module show ()
{
	if (component=="complete")
	{
		if (type=="component")
		{
			tongue ();
			translate_x(tongue_length+tongue_bind_length)
			screw ();
		}
		else if (type=="printable")
		{
			translate_z(tongue_length+tongue_bind_length+screw_length)
			rotate_y(90)
			{
				tongue ();
				translate_x(tongue_length+tongue_bind_length)
				screw ();
			}
			
			if (support)
			{
				screw_support();
			}
		}
	}
	else if (component=="tongue part")
	{
		if (type=="component")
		{
			split_tongue_part ();
		}
		else if (type=="printable")
		{
			translate_z(tongue_thickness/2)
			split_tongue_part ();
		}
	}
	else if (component=="screw part")
	{
		if (type=="component")
		{
			split_screw_part ();
		}
		else if (type=="printable")
		{
			rotate_y(90)
			translate_x(-tongue_length-tongue_bind_length-screw_length)
			union()
			split_screw_part ();
			
			if (support)
			{
				screw_support();
			}
		}
	}
	else if (component=="parts together")
	{
		split_tongue_part ();
		split_screw_part ();
	}
}

//--------------------------------------------------------------------------------

module screw_support ()
{
	color(alpha=0.5)
	difference()
	{
	union()
	{
		ring_square (
			h =support_brim_height,
			di=screw_diameter_end + 2,
			do=screw_outer_diameter
		);
		ring_square (
			h =screw_depth+screw_cylinder_depth - support_gap_z,
			w =support_line_width,
			do=screw_outer_diameter
		);
		raft_width = screw_outer_diameter-screw_diameter_begin - 2*support_gap_xy;
		//
		translate_z(screw_depth+screw_cylinder_depth - support_brim_height-support_gap_z
			- (raft_width-support_line_width)
		)
		funnel (
			h =raft_width-support_line_width,
			w =support_line_width,
			di2=screw_outer_diameter-raft_width,
			do1=screw_outer_diameter,
			do2=screw_outer_diameter
		);
		translate_z(screw_depth+screw_cylinder_depth - support_brim_height-support_gap_z)
		ring_square(
			h =support_brim_height,
			di=screw_outer_diameter-raft_width,
			do=screw_outer_diameter
		);
	}
	}
}

box_size=[
	shaft_length+10+screw_cylinder_depth,
	2*tongue_bind_thickness_end+tongue_width,
	tongue_thickness+tongue_bind_thickness_end
];
place_list=[
	2.5,
	       box_size[0]/2,
	-2.5 + box_size[0]
];
wedge_begin = box_size[1] - 3;
wedge_end   = (screw_diameter_end-wall*2)
	* cos(atan2(box_size[2]/2+tongue_bind_thickness_end/2, screw_diameter_end-wall*2));
wedge_r = 1.5;
wedge_raise = 0; // TODO

module split_tongue_part ()
{
	difference()
	{
		tongue ();
		//
		translate([
			tongue_length -extra,
			-tongue_bind_thickness_end-tongue_width/2 -extra,
			-tongue_thickness/2-tongue_bind_thickness_end -extra
		])
		cube([
			tongue_bind_length +2*extra,
			2*tongue_bind_thickness_end+tongue_width +2*extra,
			tongue_bind_thickness_end +extra
		]);
	}
	
	translate_x(tongue_length+tongue_bind_length)
	difference()
	{
		union()
		{
			translate_z(tongue_bind_thickness_end/2)
			cube_extend(box_size, align=[1,0,0]);
			//
			if (link_type=="tongue through" || link_type=="tongue long hidden")
			{
				difference()
				{
					translate_x(box_size[0])
					rotate_z(-90)
					wedge_rounded(
						v_min=[-wedge_begin/2,0          ,-box_size[2]/2+tongue_bind_thickness_end/2],
						v_max=[ wedge_begin/2,screw_depth, box_size[2]/2+tongue_bind_thickness_end/2],
						v2_min=[-wedge_end/2             ,-box_size[2]/2+tongue_bind_thickness_end/2],
						v2_max=[ wedge_end/2             , box_size[2]/2+tongue_bind_thickness_end/2],
						r=wedge_r, edges_bottom=[0,1,0,1],  edges_top=[0,1,0,1], edges_side=0
					);
					
					if (link_type=="tongue long hidden")
					{
						translate_x(shaft_length+10 + screw_cylinder_depth+screw_depth)
						cube_extend ([wall+gap_component,100,100], align=-X);
					}
				}
			}
			if (link_type=="clips")
			{
				clips_trace=[];
				
				echo ("TODO tongue clips");
			}
		}
		
		if (glue_bags==true)
		{
			place_copy_x(place_list)
			render(convexity=2)
			rotate_y(-90)
			bag (
				translate_x_points(l=tongue_bind_thickness_end/2, list=
					square_curve([box_size[2], box_size[1]], align=[0,0])
					)
				, side=0.5
			);
		}
	}
}

test_trace=[
	[10,0],
	[10,1],
	[11,2],
	[11,3]
];
if (component=="test_clips")
{
	clips_trace(test_trace) clips_side_plane_tongue();
}

// expandiere den clips in Y-Richtung entlang einer Spur
module clips_trace (trace, l=1000)
{
	y_list = extract_axis(test_trace, 1);
	y_min  = min(y_list);
	y_max  = max(y_list);
	y_diff = y_max - y_min;
	intersection()
	{
		translate_y(y_min)
		cube_extend ([l,y_diff,l], align=[0,1,0]);
		
		mirror_copy_x()
		intersection()
		{
			plain_trace_extrude (trace) children();
			
			cube_extend ([l,l,l], align=[1,0,0]);
		}
	}
}

//clips_side_plane_tongue ();
//rotate_extrude() clips_side_plane_tongue ();

module clips_side_plane_tongue (h=box_size[2], r=wedge_r, l=200)
{
	mirror_x()
	difference()
	{
		square([l, h]);
		
		mirror_copy_at_y([0,h/2])
		edge_rounded_plane (r, 90);
	}
}

module split_screw_part ()
{
	translate_x(tongue_length+tongue_bind_length)
	difference()
	{
		screw ();
		//
		box_size_gap = box_size + [
			  gap_component + extra,
			2*gap_component,
			2*gap_component
		];
		wedge_begin_gap = wedge_begin + 2*gap_component;
		wedge_end_gap   = wedge_end   + 2*gap_component;
		//
		union()
		{
			translate_x(-extra)
			translate_z(tongue_bind_thickness_end/2)
			cube_extend (box_size_gap, align=[1,0,0]);
			//
			if (link_type=="tongue through" || link_type=="tongue long hidden")
			{
				difference()
				{
					translate_x(box_size[0])
					rotate_z(-90)
					wedge_rounded(
						v_min=[-wedge_begin_gap/2,0          ,-box_size_gap[2]/2+tongue_bind_thickness_end/2],
						v_max=[ wedge_begin_gap/2,screw_depth, box_size_gap[2]/2+tongue_bind_thickness_end/2],
						v2_min=[-wedge_end_gap/2             ,-box_size_gap[2]/2+tongue_bind_thickness_end/2],
						v2_max=[ wedge_end_gap/2             , box_size_gap[2]/2+tongue_bind_thickness_end/2],
						r=wedge_r+gap_component, edges_bottom=[0,1,0,1],  edges_top=[0,1,0,1], edges_side=0
					);
					
					if (link_type=="tongue long hidden")
					{
						translate_x(shaft_length+10 + screw_cylinder_depth+screw_depth)
						cube_extend ([wall,100,100], align=-X);
					}
				}
			}
		}
		
		if (glue_bags==true)
		{
			place_copy_x(place_list)
			render(convexity=2)
			rotate_y(-90)
			bag (
				reverse(
				translate_x_points(l=tongue_bind_thickness_end/2, list=
					square_curve([box_size_gap[2], box_size_gap[1]], align=[0,0])
					) )
				, side=0.5
			);
		}
	}
	intersection()
	{
		tongue ();
		//
		translate([
			tongue_length -extra,
			-tongue_bind_thickness_end-tongue_width/2 -extra,
			-tongue_thickness/2-tongue_bind_thickness_end -extra
		])
		cube([
			tongue_bind_length +2*extra,
			2*tongue_bind_thickness_end+tongue_width +2*extra,
			tongue_bind_thickness_end +extra - gap_component
		]);
	}
}

module tongue ()
{
	difference()
	{
		cube_rounded ([tongue_length, tongue_width, tongue_thickness]
			,align=[1,0,0]
			,r=1
			,edges_side  =0
			,edges_bottom=[1,0,1,0]
			,edges_top   =[1,0,1,0]
		);
		
		difference()
		{
			r_end = get_radius_from (chord=tongue_width, sagitta=tongue_end_length);
			//
			translate_x(-extra)
			cube_extend ([r_end+extra, tongue_width+extra*2, tongue_thickness+extra*2]
				,align=[1,0,0]);
			//
			translate_x(r_end)
			cylinder_extend (r=r_end, h=tongue_thickness, center=true);
		}
		//
		mirror_copy_z()
		translate_z(-tongue_thickness/2)
		rotate_x(90)
		wedge_simple([tongue_chamfer_length, tongue_chamfer_heigth], tongue_width, center=true);
		
		translate_x (tongue_hole_begin + tonque_hole_length/2)
		intersection()
		{
			cube ([tonque_hole_length,tongue_hole_width, tongue_thickness+extra*2], center=true);
			//
			cylinder_extend (r=tonque_hole_length/2, h=tongue_thickness+extra*2, center=true);
		}
	}
	
	translate_x(tongue_length)
	tongue_bind();
}

module tongue_bind()
{
	rotate_y(-90)
	plain_trace_connect_extrude( square_curve([tongue_thickness,tongue_width], center=true) )
	polygon([
		[0                          , -tongue_bind_length],
		[tongue_bind_thickness_end  , -tongue_bind_length],
		[tongue_bind_thickness_begin, 0],
		[0                          , 0]
	]);
	cube_extend ([tongue_bind_length, tongue_width, tongue_thickness], align=[1,0,0]);
}

module screw ()
{
	rotate_y(90)
	linear_extrude(height=shaft_length)
	polygon(shaft_curve);
	
	translate_x(shaft_length)
	hull()
	{
		rotate_y(90)
		linear_extrude(height=epsilon)
		polygon(shaft_curve);
		
		translate_x(9)
		rotate_y(90)
		cylinder_extend(d=screw_outer_diameter, h=epsilon);
	}
	translate_x(shaft_length+9)
	rotate_y(90)
	cylinder_extend(d=screw_outer_diameter, h=1);
	
	translate_x(shaft_length+10)
	rotate_y(90)
	cylinder_extend(h=screw_cylinder_depth, d=screw_diameter_begin);
	//
	translate_x(shaft_length+10 + screw_cylinder_depth)
	//rotate_x(90)
	rotate_y(90)
	render(convexity=6)
	difference()
	{
		//fn = 24;
		//
		cylinder_extend(h=screw_depth, d1=screw_diameter_begin, d2=screw_diameter_end);
		
		// Helix Teil module:
		/*
		helix_extrude (
			height=screw_depth, pitch=screw_pitch, r=[screw_diameter_begin,screw_diameter_end]/2
			, slices="x", convexity=0
		)
		rotate_to_vector([-(screw_diameter_begin-screw_diameter_end)/2,screw_depth], d=2)
		rotate(-90)
		translate_y (screw_tooth_diameter/2)
		tooth_profile_cut();
		//*/
		
		// Helix Teil function:
		//*
		build_object(
			let(
				a = tooth_profile_cut (),
				b = translate_y_points      (a, screw_tooth_diameter/2),
				c = rotate_points           (b, -90),
				d = rotate_to_vector_points (c, [-(screw_diameter_begin-screw_diameter_end)/2,screw_depth]),
				//
				e = helix_extrude_points ( list=d
					, height=screw_depth, pitch=screw_pitch, r=[screw_diameter_begin,screw_diameter_end]/2
					, slices="x")
			) e
			, convexity=5
		);
		//*/
	}
}

module tooth_profile_cut ()
{
	polygon( tooth_profile_cut() );
}
function tooth_profile_cut () =
	let (
		$fd=0.005,
		r_edge=screw_tooth_diameter/2 * 0.5
	)
	rotate_points( a=90, list=concat(
		 [[-r_edge, -extra]]
		//
		,translate_points( circle_curve (r=r_edge, angle=[90, 270], slices="x") , [-r_edge, r_edge])
		,reverse(
		 translate_points( circle_curve (r=r_edge, angle=[90, 90 ], slices="x") , [ r_edge, screw_tooth_depth-r_edge]))
		//
		,reverse(
		 translate_points( circle_curve (r=r_edge, angle=[90, 0  ], slices="x") , [screw_tooth_diameter-r_edge, screw_tooth_depth-r_edge]))
		,translate_points( circle_curve (r=r_edge, angle=[90, 180], slices="x") , [screw_tooth_diameter+r_edge, r_edge])
		//
		,[[screw_tooth_diameter+r_edge, -extra]]
	))
;
module tooth_profile_cut_ ()
{
	circle_extend(d=screw_tooth_diameter);
}

// side = value between 0...1, 0.5 = centered slot
module bag_pane (depth=glue_bag_depth, slot=glue_bag_slot, side=0, extra=extra)
{
	translate_y( (2*depth+slot) * side )
	polygon([
		[extra , 0],
		[0     , 0],
		[-depth, -depth],
		[-depth, -depth-slot],
		[0     , -depth-slot-depth],
		[extra , -depth-slot-depth]
	]);
}

module bag (trace, depth=glue_bag_depth, slot=glue_bag_slot, side=0, extra=extra)
{
	plain_trace_connect_extrude (trace)
	bag_pane (depth, slot, side);
}

//--------------------------------------------------------------------------------

module wedge_simple (size, h, tip_y=0, center)
{
	linear_extrude(height=h, center=center)
	polygon([
		[0,0],
		[size[0], tip_y],
		[0      , size[1]]
	]);
}

function center_list (list, size, axis) =
	let(
		Size   = parameter_numlist (3, size, preset=[0,0,0], fill=0),
		Axis   = parameter_numlist (3, axis, preset=[1,1,1], fill=0),
		Center = multiply_each (Size, Axis) / -2
	)
	translate_points(list, Center)
;
module center (size, axis)
{
	Size   = parameter_numlist (3, size, preset=[0,0,0], fill=0);
	Axis   = parameter_numlist (3, axis, preset=[1,1,1], fill=0);
	Center = multiply_each (Size, Axis) / -2;
	translate(Center)
	children();
}


