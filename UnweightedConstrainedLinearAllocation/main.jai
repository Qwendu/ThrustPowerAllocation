

#run main();
main :: ()
{
	nc := context;
	nc.print_style.struct_printer = DMatrix_Printer;
	push_context nc
	{
		cem := create_Controll_Effectiveness_Matrix(*configuration);
		target := allocate_DMatrix(cem.Rows, 1);
		target[0][0] = 0.5;
		target[1][0] = 0.7;
		
		preferred := allocate_DMatrix(cem.Cols, 1);
		power_allocation := solve(cem, target, preferred);
		print("Target:\n%\n", target);
		print("Power Allocation:\n%\n", power_allocation);

		for 0..3
		{
			swapped := 0;
			n_saturated := 0;
			for 0..power_allocation.Rows-1
			{
				if cem.Cols < cem.Rows  break;
				pow := power_allocation[it][0];
				if abs(pow) < EPS || abs(pow - 1) < EPS
				{
					// Saturated
				}else{
					// Unsaturated
					swap_Column(cem, swapped, it);
					{
						temp := power_allocation[it][0];
						power_allocation[it][0] = power_allocation[swapped][0];
						power_allocation[swapped][0] = temp;
					}
					{
						temp := preferred[it][0];
						preferred[it][0] = preferred[swapped][0];
						preferred[swapped][0] = temp;
					}
				
					swapped += 1;
				}
			}
			print("Saturated %\n", swapped);
			unsatisfied_power_allocation := constrained_View(power_allocation, row_end = swapped);
			new_cem := constrained_View(cem, col_end = swapped);
			print("New CEM\n%\n", new_cem);
			if new_cem.Cols < new_cem.Rows  break;
			new_preferred := constrained_View(preferred, row_end = swapped);
			print("New perferred\n%\n", new_preferred);
			new_target := target - (new_cem * unsatisfied_power_allocation);
			new_allocation := solve(new_cem, target, new_preferred);
			print("New allocation\n%\n", new_allocation);
			for 0..swapped-1 power_allocation[it][0] = new_allocation[it][0];
			power_allocation = unsatisfied_power_allocation;
			target = new_target;
			preferred = new_preferred;
		}
		power_allocation = reset_Views(power_allocation);
		result := cem * power_allocation;
		print("Result:\n%\n", result);
	}

}



solve :: (cem : DMatrix, target : DMatrix, preferred : DMatrix) -> DMatrix
{
	cem_t := transpose(cem);
	parens := cem * cem_t;
	inv := inverse(parens);
	C := cem_t * inv;
	print("C:\n%\n", C);
	CB := C * cem; // I - C B
	for 0..min(CB.Rows-1, CB.Cols-1)  CB[it][it] = 1 - CB[it][it];

	pref := CB * preferred;
	
	tar := C * target;
	unconstrained_items := 0;
	result := pref + tar;
	for 0..result.Rows-1  if result[it][0] < 0  result[it][0] = 0;
	for 0..result.Rows-1  if result[it][0] > 1  result[it][0] = 1;
	return result;
}

create_Controll_Effectiveness_Matrix :: (configuration : *Thruster_Configuration($N)) -> DMatrix
{
	scratch : [6] float;
	res := allocate_DMatrix(6, configuration.N);
	for thruster,col: configuration.thrusters
	{
		<<(cast(*Vector3)*scratch[0]) = thruster.direction;
		<<(cast(*Vector3)*scratch[3]) = cross(thruster.position, thruster.direction);
		for row : 0..6-1  res[row][col] = scratch[row];
	}
	return res;
}
#import,file "../DLinAlg.jai";
#import "Math";
#import,file "../util.jai";
#import "Basic";

configuration := Thruster_Configuration(12).{
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
