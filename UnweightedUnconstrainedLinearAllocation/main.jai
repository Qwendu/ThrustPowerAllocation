

m :: 6;
p :: 12;

#run main();
main :: ()
{
	b := generateControllEffectivenessMatrix(*configuration);
	print("Coefficient Matrix:\n");
	LinAlg.view(b);


	target : [6] float = .[1,0,0,0,0,0];
	preferred : [configuration.N] float;
	print("u_p = %\n", preferred);
	u := minimize(b, *target, *preferred);
	print("u = %\n", u);
	params := New(Parameters(configuration.N));
	params.power = u;
	f,t := calculate_Forces(*configuration, params);
	print("Forces Are %\nTorques are %\n", f, t);
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
	LinAlg.view(C);
	
	neg := LinAlg.mul(C, controll_effectiveness_matrix);

	/*
	 * Compute (I - C B)u_p + C t_c
	 */
	for *res
	{
		<<it = preferred[it_index];
		for k : 0..m-1
		{
			<<it -= neg.data[it_index][k] * preferred[k];
		}
		for k : 0..m-1
		{
			<<it += C.data[it_index][k] * t[k];
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
		.{position = .{-1,0,1}, direction = .{1,0,0}},
		.{position = .{-1,0,0}, direction = .{0,1,0}},
		.{position = .{-1,0,0}, direction = .{0,0,1}},
		.{position = .{-1,0,0}, direction = .{-1,0,0}},
		.{position = .{-1,0,1}, direction = .{0,-1,0}},
		.{position = .{-1,0,0}, direction = .{0,0,-1}},
	]
};
