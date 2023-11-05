include <banded.scad>

/* [Assembly] */

component = "complete"; // ["complete", "parts together", "tongue part", "screw part", "test"]

link_type = "tongue long hidden"; // ["tongue short", "tongue long hidden", "tongue through", "clips"]

// little grooves filled with glue
glue_bags = true;
// space to catch excess glue
// glue_residue_bag = true;

debug = "none"; // ["none", "slice top", "slice side"]

// set 'component' to "test" to view test objects
test = "none"; // ["none", "clips", "tooth_profile", "tooth_profile_end", "bag_pane", "bag"]

/* [3D-Print] */

type = "component"; // ["component", "printable"]

support             = false;
support_gap_z       = 0.1; // 0.01
support_gap_xy      = 1.2; // 0.1
support_line_width  = 0.7; // 0.05
support_brim_height = 0.4; // 0.05

/* [Common] */

wall = 3; // 0.1

gap_component = 0.12;  // 0.01

glue_bag_depth = 0.30;        // 0.05
glue_bag_slot  = 1.0;         // 0.1
glue_bag_side_distance = 1.5; // 0.5

// glue_residue_size = 1.0;

/* [Tongue] */

// original: 76mm
tongue_length    = 75.5; // 0.1
tongue_width     = 18;   // 0.1
tongue_thickness =  7;   // 0.1
//
tongue_end_length = 5;       // 0.1
tongue_chamfer_length = 2;   // 0.1
tongue_chamfer_heigth = 1;   // 0.1
tongue_hole_width    = 11.4; // 0.1
tonque_hole_length   = 13.0; // 0.1
tongue_hole_straight =  6;   // 0.1
tongue_hole_begin = 5;       // 0.1
tongue_edges_radius = 1;     // 0.1
//
tongue_bind_length          = 3;   // 0.1
tongue_bind_thickness_begin = 0.3; // 0.1
tongue_bind_thickness_end   = 1.3;

/* [Shaft] */

shaft_length      = 11; // 0.1
shaft_bind_length =  1; // 0.1
shaft_width       = 29; // 0.1
shaft_thickness   = 23; // 0.1
// Parameter of superellipse
shaft_n = 2.2; // 0.01

/* [Screw] */

screw_type = "half width"; // ["half width", "circle"]

screw_diameter_begin = 27;   // 0.1
screw_diameter_end   = 21.5; // 0.1
screw_depth          = 24;   // 0.1
//
screw_cylinder_depth =  1;   // 0.1
screw_outer_diameter = 34;   // 0.1
//
screw_pitch          = 4; // 0.1
screw_tooth_diameter = 2; // 0.1
screw_tooth_depth    = 1; // 0.1

/* [Hidden] */

$fd=0.01;

screw_length = shaft_length+screw_cylinder_depth+screw_depth;

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
	color(alpha=0.3)
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
	shaft_length+screw_cylinder_depth,
	2*tongue_bind_thickness_end+tongue_width,
	tongue_thickness+tongue_bind_thickness_end
];
place_list_cube=[
	2.5,
	       box_size[0]/2,
	-2.5 + box_size[0]
];
place_list_wedge=[
	(screw_depth-wall) - 13,
	(screw_depth-wall) -  9.5,
	(screw_depth-wall) -  6,
	(screw_depth-wall) -  2.5
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
						translate_x(shaft_length + screw_cylinder_depth+screw_depth + extra)
						cube_extend ([wall+gap_component+extra, screw_outer_diameter,screw_outer_diameter], align=-X);
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
			// cube
			if (glue_bag_side_distance==0)
			{
				place_copy_x(place_list_cube)
				render(convexity=2)
				rotate_y(-90)
				bag_trace (
					translate_x_points(l=tongue_bind_thickness_end/2, list=
						square_curve([box_size[2], box_size[1]], center=true)
						)
				);
			}
			else
			{
				bag_cube_trace =
					rotate_y_points(a=-90, list=
					projection_points (plane=false, list=
					translate_x_points(l=tongue_bind_thickness_end/2, list=
					square_curve([box_size[2], box_size[1]], center=true)
					)));
				bag_line_list = trace_to_lines (bag_cube_trace, closed=true);
				bag_lines_list = [for (x=place_list_cube) each [ for (p=bag_line_list) translate_x_points (p, x) ] ];
				bag_lines_part = [for (l=bag_lines_list)
					let (
						length = length_line (l)
					)
					if (length-2*glue_bag_side_distance > 0)
					[ lerp (l[0], l[1],        glue_bag_side_distance, [0,length])
					, lerp (l[0], l[1], length-glue_bag_side_distance, [0,length])]
				];
				
				render(convexity=2)
				for (line=bag_lines_part)
				{	
					bag_line(line, rotational=X);
				}
			}
			// wedge
			if (link_type=="tongue through" || link_type=="tongue long hidden")
			translate_x(box_size[0])
			{
				wedge_left_trace  =
					rotate_y_points(a=-90, list=
					projection_points (plane=false, list=
					translate_x_points(l=tongue_bind_thickness_end/2, list=
					square_curve ([box_size[2], wedge_begin], center=true)
					)));
				wedge_right_trace =
					translate_x_points(l=screw_depth, list=
					rotate_y_points(a=-90, list=
					projection_points (plane=false, list=
					translate_x_points(l=tongue_bind_thickness_end/2, list=
					square_curve ([box_size[2], wedge_end], center=true)
					))));
				size_wedge_trace = len(wedge_left_trace);
				wedge_direction_list =
					[ for (i=[0:1:size_wedge_trace-1])
					  lerp( wedge_right_trace[i], wedge_right_trace[(i+1)%size_wedge_trace], 0.5)
					- lerp( wedge_left_trace [i], wedge_left_trace [(i+1)%size_wedge_trace], 0.5)
					];
				bag_trace_list =
					[ for (x=place_list_wedge) lerp (wedge_left_trace, wedge_right_trace, x, [0,screw_depth]) ]
				;
				bag_line_list = [ for (t=bag_trace_list) each trace_to_lines (t, closed=true) ];
				bag_lines_part = [for (l=bag_line_list)
					let (
						length = length_line (l)
					)
					if (length-2*glue_bag_side_distance > 0)
					[ lerp (l[0], l[1],        glue_bag_side_distance, [0,length])
					, lerp (l[0], l[1], length-glue_bag_side_distance, [0,length])]
				];
				
			//	#show_trace(wedge_left_trace,  closed=true);
			//	#show_trace(wedge_right_trace, closed=true);
			//	#show_lines(bag_lines_part);
				
				render(convexity=2)
				for (i=[0:1:len(bag_lines_part)-1])
				{
					line      = bag_lines_part[i];
					direction = wedge_direction_list[i%size_wedge_trace];
					
					bag_line(line, rotational=direction);
				}
			}
		}
	}
}

test_trace=[
	[10,0],
	[10,1],
	[11,2],
	[11,3]
];
if (component=="test" && test=="clips")
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
						translate_x(shaft_length + screw_cylinder_depth+screw_depth)
						cube_extend ([wall, screw_outer_diameter,screw_outer_diameter], align=-X);
					}
				}
			}
		}
		
		if (glue_bags==true)
		{
			// cube
			if (glue_bag_side_distance==0)
			{
				place_copy_x(place_list_cube)
				render(convexity=2)
				rotate_y(-90)
				bag_trace (
					reverse(
					translate_x_points(l=tongue_bind_thickness_end/2, list=
						square_curve([box_size_gap[2], box_size_gap[1]], align=[0,0])
						) )
				);
			}
			else
			{
				bag_cube_trace =
					rotate_y_points(a=-90, list=
					projection_points (plane=false, list=
					translate_x_points(l=tongue_bind_thickness_end/2, list=
					square_curve([box_size_gap[2], box_size_gap[1]], align=[0,0])
					)));
				bag_line_list = trace_to_lines (bag_cube_trace, closed=true);
				bag_lines_list = [for (x=place_list_cube) each [ for (p=bag_line_list) translate_x_points (p, x) ] ];
				bag_lines_part = [for (l=bag_lines_list)
					let (
						length = length_line (l)
					)
					if (length-2*glue_bag_side_distance > 0)
					[ lerp (l[0], l[1],        glue_bag_side_distance, [0,length])
					, lerp (l[0], l[1], length-glue_bag_side_distance, [0,length])]
				];
				
				render(convexity=2)
				for (line=bag_lines_part)
				{	
					bag_line(line, rotational=-X);
				}
			}
			// wedge
			if (link_type=="tongue through" || link_type=="tongue long hidden")
			translate_x(box_size[0])
			{
				wedge_left_trace  =
					rotate_y_points(a=-90, list=
					projection_points (plane=false, list=
					translate_x_points(l=tongue_bind_thickness_end/2, list=
					square_curve ([box_size_gap[2], wedge_begin_gap], center=true)
					)));
				wedge_right_trace =
					translate_x_points(l=screw_depth, list=
					rotate_y_points(a=-90, list=
					projection_points (plane=false, list=
					translate_x_points(l=tongue_bind_thickness_end/2, list=
					square_curve ([box_size_gap[2], wedge_end_gap], center=true)
					))));
				size_wedge_trace = len(wedge_left_trace);
				wedge_direction_list =
					[ for (i=[0:1:size_wedge_trace-1])
					  lerp( wedge_right_trace[i], wedge_right_trace[(i+1)%size_wedge_trace], 0.5)
					- lerp( wedge_left_trace [i], wedge_left_trace [(i+1)%size_wedge_trace], 0.5)
					];
				bag_trace_list =
					[ for (x=place_list_wedge) lerp (wedge_left_trace, wedge_right_trace, x, [0,screw_depth]) ]
				;
				bag_line_list = [ for (t=bag_trace_list) each trace_to_lines (t, closed=true) ];
				bag_lines_part = [for (l=bag_line_list)
					let (
						length = length_line (l)
					)
					if (length-2*glue_bag_side_distance > 0)
					[ lerp (l[0], l[1],        glue_bag_side_distance, [0,length])
					, lerp (l[0], l[1], length-glue_bag_side_distance, [0,length])]
				];
				
				render(convexity=2)
				for (i=[0:1:len(bag_lines_part)-1])
				{
					line      = bag_lines_part[i];
					direction = wedge_direction_list[i%size_wedge_trace];
					
					bag_line(line, rotational=-direction);
				}
			}
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
			,r=tongue_edges_radius
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
		wedge_simple([tongue_chamfer_length, tongue_chamfer_heigth, tongue_width], align=X+Y);
		
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
	plain_trace_extrude_closed( square_curve([tongue_thickness,tongue_width], center=true) )
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
	slices =
		quantize (raster=12, value=
		get_slices_circle_current_x (
		max (screw_outer_diameter, screw_diameter_begin, screw_diameter_end
	)));
	
	rotate_y(90)
	linear_extrude(height=shaft_bind_length)
	polygon(shaft_curve);
	
	translate_x(shaft_bind_length)
	hull()
	{
		rotate_y(90)
		linear_extrude(height=epsilon)
		polygon(shaft_curve);
		
		translate_x(shaft_length - 2*shaft_bind_length)
		rotate_y(90)
		cylinder_extend(d=screw_outer_diameter, h=epsilon, slices=slices);
	}
	translate_x(shaft_length - shaft_bind_length)
	rotate_y(90)
	cylinder_extend(d=screw_outer_diameter, h=shaft_bind_length, slices=slices);
	
	translate_x(shaft_length)
	rotate_y(90)
	cylinder_extend(h=screw_cylinder_depth, d=screw_diameter_begin, slices=slices);
	//
	screw_depth_end    = (floor (screw_depth/screw_pitch) - (screw_profile_end_cut_value)) * screw_pitch;
	screw_diameter_mid = bezier_1 (screw_depth_end/screw_depth, [screw_diameter_begin,screw_diameter_end]);
	//
	translate_x(shaft_length + screw_cylinder_depth)
	rotate_y(90)
	rotate_z(screw_rotation_begin)
	//render(convexity=6)
	difference()
	{
		//fn = 24;
		//
		cylinder_extend(h=screw_depth, d1=screw_diameter_begin, d2=screw_diameter_end, slices=slices);
		
		// Helix Teil module:
		/*
		helix_extrude (
			height=screw_depth, pitch=screw_pitch, r=[screw_diameter_begin,screw_diameter_end]/2
			, orientation=true
			, slices=slices, convexity=0
		)
		tooth_profile_cut();
		//*/
		
		// Helix Teil function:
		//*
		build(
			let(
				a = tooth_profile_cut (),
				e = helix_extrude_points ( list=a
					, height=screw_depth+screw_pitch, pitch=screw_pitch
					, r=[
						screw_diameter_begin,
						lerp (screw_diameter_begin,screw_diameter_end,(screw_depth+screw_pitch)/screw_depth)
						] / 2
					, orientation=true
					, slices=slices)
			) e
			, convexity=5
		);
		//
		build(
			let(
				a = tooth_profile_end_cut (),
				e = helix_extrude_points ( list=a
					, height=screw_depth-screw_depth_end, pitch=screw_pitch
					, r=[
						screw_diameter_mid,
						screw_diameter_end
						] / 2
					, orientation=true
					, slices=slices),
				f = translate_z (e, screw_depth_end),
				g = rotate_z (f, 360 * ((screw_depth_end/screw_pitch)%1))
			) g
			, convexity=5
		);
		//*/
	}
}

screw_rotation_begin =
	screw_type=="half width" ? 90 - 45:
	screw_type=="circle"     ? 90 :
	90
;
screw_profile_end_cut_value =
	screw_type=="half width" ? 0.25 :
	screw_type=="circle"     ? 0.25 :
	0
;
module   tooth_profile_cut () { polygon( tooth_profile_cut () ); }
function tooth_profile_cut () =
	screw_type=="half width" ? tooth_profile_cut_half_width () :
	screw_type=="circle"     ? tooth_profile_cut_circle () :
	undef
;
//
module   tooth_profile_end_cut () { polygon( tooth_profile_end_cut () ); }
function tooth_profile_end_cut () =
	screw_type=="half width" ? tooth_profile_end_cut_half_width () :
	screw_type=="circle"     ? tooth_profile_end_cut_circle () :
	undef
;

screw_tooth_edge_radius = screw_tooth_diameter/2 * 0.49;
//
function tooth_profile_cut_half_width () =
	let (
		$fd=0.005,
		r_edge=screw_tooth_edge_radius,
		screw_tooth_offset = screw_tooth_diameter
	)
	translate_y_points (l=r_edge - screw_tooth_offset, list=
	rotate_points( a=90, list=concat(
		 [	[-r_edge, -extra]]
		//
		,translate_points( circle_curve (r=r_edge, angle=[90, 270], slices="x"),
			[-r_edge, r_edge])
		,reverse(
		 translate_points( circle_curve (r=r_edge, angle=[90, 90 ], slices="x"),
			[ r_edge, screw_tooth_depth-r_edge]))
		//
		,reverse(
		 translate_points( circle_curve (r=r_edge, angle=[90, 0  ], slices="x"),
			[screw_tooth_diameter-r_edge, screw_tooth_depth-r_edge]))
		,translate_points( circle_curve (r=r_edge, angle=[90, 180], slices="x"),
			[screw_tooth_diameter+r_edge, r_edge])
		//
		,[	[screw_tooth_diameter+r_edge, -extra]]
	)))
;
function tooth_profile_end_cut_half_width () =
	let (
		screw_tooth_offset = screw_tooth_diameter
	)
	translate_points (v=[extra, 2*screw_tooth_edge_radius - screw_tooth_offset], list=
	square_curve ([screw_tooth_depth+extra, screw_pitch], align=-X+Y)
	)
;
//
function tooth_profile_cut_circle () =
	translate_y_points (l=-screw_tooth_diameter/2, list=
	circle_curve (d=screw_tooth_diameter, align=Y, slices="x")
	)
;
function tooth_profile_end_cut_circle () =
	translate_points (v=[extra, 0], list=
	square_curve ([screw_tooth_diameter/2+extra, screw_pitch], align=-X+Y)
	)
;

if (component=="test" && test=="tooth_profile")
{
	a = tooth_profile_cut ();
	b = rotate_points           (a, -90);
	c = rotate_to_vector_points (b, [-(screw_diameter_begin-screw_diameter_end)/2,screw_depth]);
	build_object (a);
}
if (component=="test" && test=="tooth_profile_end")
{
	a = tooth_profile_end_cut ();
	b = rotate_points           (a, -90);
	c = rotate_to_vector_points (b, [-(screw_diameter_begin-screw_diameter_end)/2,screw_depth]);
	build_object (a);
}

if (component=="test" && test=="bag_pane")
{
	bag_pane();
}
if (component=="test" && test=="bag")
{
	bag_line([[0,1], [1,10]]);
}

// side = value between -1...1, 0 = centered slot
module bag_pane (depth=glue_bag_depth, slot=glue_bag_slot, side=0, extra=extra)
{
	translate_y( (depth+slot/2) * (side+1) )
	polygon([
		[extra , 0],
		[0     , 0],
		[-depth, -depth],
		[-depth, -depth-slot],
		[0     , -depth-slot-depth],
		[extra , -depth-slot-depth]
	]);
}

module bag_trace (trace, depth=glue_bag_depth, slot=glue_bag_slot, side=0, extra=extra)
{
	plain_trace_extrude_closed (trace)
	bag_pane (depth, slot, side, extra);
}

module bag (length, ends=true)
{
	intersection()
	{
		linear_extrude (length)
		bag_pane();
		
		if (ends==true)
		rotate_x(90)
		linear_extrude (glue_bag_slot+2*glue_bag_depth, center=true)
		bag_pane(slot=length-2*glue_bag_depth, side=1);
	}
}

// extrudiert und dreht das 2D-Objekt die Linie 'line' entlang
// Die X-Achse ist die Rotationsrichtung, wird um die Pfeilrichtung nach den Punkt 'rotational' gedreht
module bag_line (line, rotational=[1,0,0], ends=true)
{
	base_vector = [0,1];
	origin      = fill_missing_list (line[0]           , [0,0,0]);
	line_vector = fill_missing_list (line[1] - line[0] , [0,0,0]);
	up_to_z     = rotate_backwards_to_vector_points ( [rotational], line_vector);
	plane       = projection_points (up_to_z);
	angle_base  = rotation_vector (base_vector, plane[0]);
	//
	translate (origin)
	rotate_to_vector (line_vector, angle_base)
	bag (norm(line_vector), ends);
}

//--------------------------------------------------------------------------------

module wedge_simple (size, tip_y=0, center, align)
{
	Size  = parameter_size_3d (size);
	Align = parameter_align   (align, [1,1,1], center);
	
	translate ([for (i=[0:1:len(Size)-1]) (Align[i]-1)*Size[i]/2 ])
	linear_extrude(height=size[2])
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

function align_points (list, align, center) =
	let (
		data_box = get_bounding_box_points (list),
		size     = data_box[0],
		min_pos  = data_box[1],
		Align    = parameter_align (align, [1,1,1], center)
	)
	translate_points (list, - min_pos - size/2 + multiply_each (Align, size) )
;

