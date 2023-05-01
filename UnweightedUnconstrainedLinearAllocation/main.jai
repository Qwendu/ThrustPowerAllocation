SOLVER :: #import,file "solver.jai"(false);

#run main();
main :: ()
{
	solution, ef, et := SOLVER.solve_Configuration(*configuration, 
	   force  = Vector3.{1,0,0}, 
	   torque = Vector3.{0,0,0});
	print("Solution UU is %\n", solution);
	print("EF is %\n", ef);
	print("ET is %\n", et);
}




configuration := SOLVER.Thruster_Configuration(12).{
	.[
		.{position = .{1,0,0}, direction = .{1,0,0}},
		.{position = .{1,0,0}, direction = .{0,1,0}},
		.{position = .{0,1,0}, direction = .{0,0,1}},
		.{position = .{0,1,0}, direction = .{-1,0,0}},
		.{position = .{1,0,1}, direction = .{0,-1,0}},
		.{position = .{1,0,0}, direction = .{0,0,-1}},
		.{position = .{-1,0,1}, direction = .{0.2,0,0}},
		.{position = .{-1,0,0}, direction = .{0,1,0}},
		.{position = .{-1,0,0}, direction = .{0,0,1}},
		.{position = .{-1,0,0}, direction = .{-1,0,0}},
		.{position = .{-1,0,1}, direction = .{0,-1,0}},
		.{position = .{-1,0,0}, direction = .{0,0,-1}},
	]
};

#import "Basic";
#import "Math";
