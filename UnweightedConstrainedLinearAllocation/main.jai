

main :: ()
{
	b := generateControllEffectivenessMatrix(*configuration);
	
	target : [6] float = .[1,0,0,0,0,0];
	preferred : [configuration.N] float;
	print("u_p = %\n", preferred);
	target_force := Vector3.{target[0],target[1],target[2]};
	target_torque := Vector3.{target[3],target[4],target[5]};
	params := New(Parameters(configuration.N));

	u := minimize(b, *target, *preferred);
	params.power = u;
	f,t := calculate_Forces(*configuration, params);
	iteration := 0;
	LinAlg.view(b);

	unsaturated_count := u.count;
	while error(target_force, target_torque, f, t) > 0.1
	{
		print("Solution so far is %\n", u);
		if iteration > 10  break;
		defer iteration +=1;
		// Project solution on possible space
		swap_index := 0;
		for scan: 0..unsaturated_count - 1
		{
			if u[scan] > 0 && u[scan] < 1
			{
				// Swap swap_index and scan
				temp := u[scan];
				u[scan] = u[swap_index];
				u[swap_index] = temp;
				
				temp = preferred[scan];
				preferred[scan] = preferred[swap_index];
				preferred[swap_index] = temp;
				for 0..5
				{
					temp = b.data[it][scan];
					b.data[it][scan] = b.data[it][swap_index];
					b.data[it][swap_index] = temp;
				}
				swap_index += 1;
			}
		}
		if swap_index == 0  break;

		print("Swap Index %\n", swap_index);
		b.Cols = swap_index;
		LinAlg.view(b);

		error_target := target;
		
		
		u = minimize(b, *target, *preferred);
	}



	print("Forces Are %\nTorques are %\n", f, t);
}

error :: (tf : Vector3, tt : Vector3, f : Vector3, t : Vector3) -> float
{
	return length(f - tf) + length(t - tt);
}

minimize :: (using controll_effectiveness_matrix : *Matrix($m, $p), target : *[m] float, u_p : *[p] float) -> [p] float
{
	// min 1/2 (u - u_p)^T W (u - u_p) -> solution is:
	// u = (I - CB)u_p + Ct_c 
	// where t_c is target
	// where C = B^T (B B^T)^-1
	// where u_p is the preferred value of u

	t : [] float = <<target;
	preferred : [] float = <<u_p;
	res : [p] float;

	B_T := LinAlg.transpose(controll_effectiveness_matrix);
	
	parens_term := LinAlg.mul(controll_effectiveness_matrix, B_T);
	inv := LinAlg.inverse(parens_term);

	C: = LinAlg.mul(B_T, inv);
	print("C:\n");
	//LinAlg.view(C);
	
	neg := LinAlg.mul(C, controll_effectiveness_matrix);

	/*
	 * Compute (I - C B)u_p + C t_c
	 */
	for 0..controll_effectiveness_matrix.Cols-1
	{
		
		res[it] = preferred[it];
		for k : 0..m-1
		{
			res[it] -= neg.data[it][k] * preferred[k];
		}
		for k : 0..m-1
		{
			res[it] += C.data[it][k] * t[k];
		}
	}
	return res;
}

generateControllEffectivenessMatrix :: (config : *Thruster_Configuration($N)) -> *Matrix(6, N)
{
	scratch : [6] float;
	res := New(LinAlg.Matrix(6,N));
	for config.thrusters
	{
		
		<<(cast(*Vector3)*scratch[0]) = it.direction;
		<<(cast(*Vector3)*scratch[3]) = cross(it.position, it.direction);
		for s, si: scratch  res.data[si][it_index] = s;
	}
	return res;
}

#run main();

#import "Math";
#import,file "../util.jai";
LinAlg :: #import,file "../LinAlg.jai";
Matrix :: LinAlg.Matrix;
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
