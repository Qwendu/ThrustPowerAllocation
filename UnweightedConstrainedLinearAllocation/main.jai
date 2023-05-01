#import,file "solver.jai"(false);

#run main();
main :: ()
{
	solution , ef, et := solve_Configuration(*configuration, 
	   force  = Vector3.{1,0,0}, 
	   torque = Vector3.{0,0,0});
	print("Solution UC is %\n", solution);
	print("EF is %\n", ef);
	print("ET is %\n", et);
}

#import "Math";
#import "Basic"()(MEMORY_DEBUGGER=true);

configuration := Thruster_Configuration(12).{
	.[
		.{max = 1, position = .{1,0,0}, direction = .{1,0,0}},
		.{max = 2, position = .{1,0,0}, direction = .{0,1,0}},
		.{max = 3, position = .{0,1,0}, direction = .{0,0,1}},
		.{max = 4, position = .{0,1,0}, direction = .{-1,0,0}},
		.{max = 5, position = .{1,0,1}, direction = .{0,-1,0}},
		.{max = 6, position = .{1,0,0}, direction = .{0,0,-1}},
		.{max = 7, position = .{-1,0,1}, direction = .{0.2,0,0}},
		.{max = 8, position = .{-1,0,0}, direction = .{0,1,0}},
		.{max = 9, position = .{-1,0,0}, direction = .{0,0,1}},
		.{max = 10, position = .{-1,0,0}, direction = .{-1,0,0}},
		.{max = 11, position = .{-1,0,1}, direction = .{0,-1,0}},
		.{max = 12, position = .{-1,0,0}, direction = .{0,0,-1}},
	]
};
