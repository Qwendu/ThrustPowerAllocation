#load "../util.jai";


#module_parameters(PRINT_MATRICIES : bool = false, ITERATIONS : int = 10);


solve_Configuration :: (
	configuration : *Thruster_Configuration($N),
	force : Vector3, torque : Vector3) -> (allocation : [N] float, force_error : Vector3, torque_error : Vector3)
{
	nc := context;
	nc.print_style.struct_printer = DMatrix_Printer;
	power_allocation : DMatrix;

	
	result : DMatrix;
	target : DMatrix;
	error : DMatrix;
	push_context nc
	{
		push_allocator(temporary_allocator);

		cem := create_Controll_Effectiveness_Matrix(configuration);
		upper_limits : [N] float;
		for * upper_limits {<<it = configuration.thrusters[it_index].max;}

		#if PRINT_MATRICIES  print("CEM:\n%\n", cem);
		target = allocate_DMatrix(cem.Rows, 1);
		target[0][0] = force.x;
		target[1][0] = force.y;
		target[2][0] = force.z;
		target[3][0] = torque.x;
		target[4][0] = torque.y;
		target[5][0] = torque.z;

		new_target :=  target;
		

		preferred := allocate_DMatrix(cem.Cols, 1);
		power_allocation = solve(cem, new_target, preferred);

		#if PRINT_MATRICIES  print("Target:\n%\n", target);
		#if PRINT_MATRICIES  print("Power Allocation:\n%\n", power_allocation);


		for 0..ITERATIONS
		{


			
			swapped := 0;
			n_saturated := 0;
			for 0..power_allocation.Rows-1
			{
				if cem.Cols < cem.Rows  break;
				power_allocation[it][0] = clamp(power_allocation[it][0], 0, upper_limits[it]);
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
					{
						temp := upper_limits[it];
						upper_limits[it] = upper_limits[swapped];
						upper_limits[swapped] = temp;
					}
				
					swapped += 1;
				}
			}


			#if PRINT_MATRICIES  print("Saturated %\n", swapped);
			#if PRINT_MATRICIES  print("Limits:\n%\n", upper_limits);
			unsatisfied_power_allocation := constrained_View(power_allocation, row_end = swapped);
			new_cem := constrained_View(cem, col_end = swapped);
			#if PRINT_MATRICIES  print("New CEM\n%\n", new_cem);
			if new_cem.Cols < new_cem.Rows  break;

			new_preferred := constrained_View(preferred, row_end = swapped);
			#if PRINT_MATRICIES  print("New perferred\n%\n", new_preferred);
			new_target = target - (new_cem * unsatisfied_power_allocation);
			new_allocation := solve(new_cem, new_target, new_preferred);
			#if PRINT_MATRICIES  print("New allocation\n%\n", new_allocation);
			for 0..swapped-1 power_allocation[it][0] = new_allocation[it][0];
			power_allocation = unsatisfied_power_allocation;
			preferred = new_preferred;
		}
		power_allocation = reset_Views(power_allocation);
		result := cem * power_allocation;
		error = target - result;
		#if PRINT_MATRICIES  print("Result:\n%\n", result);
	}
	result_to_return : [N] float;
	for 0..power_allocation.Rows-1
	{
		result_to_return[it] = clamp(power_allocation[it][0], 0, configuration.thrusters[it].max);
	}

	error_force : Vector3;
	error_torque : Vector3;
	error_force.x  = error[0][0];
	error_force.y  = error[1][0];
	error_force.z  = error[2][0];
	error_torque.x = error[3][0];
	error_torque.y = error[4][0];
	error_torque.z = error[5][0];

	reset_temporary_storage();
	return result_to_return, error_force, error_torque;
}

#scope_file

solve :: (cem : DMatrix, target : DMatrix, preferred : DMatrix) -> DMatrix
{
	cem_t := transpose(cem);
	parens := cem * cem_t;
	inv := inverse(parens);
	C := cem_t * inv;
	#if PRINT_MATRICIES  print("C:\n%\n", C);
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


#import "Math";
#import "Basic";
#import,file "../DLinAlg.jai";
#import,file "../util.jai";
