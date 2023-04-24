
#import "Basic";
#import "Math";
Thruster :: struct
{
	position  : Vector3;
	direction : Vector3;
};

Thruster_Configuration :: struct(N: int)
{
	thrusters : [N] Thruster;
}
Parameters :: struct(N : int)
{
	power     : [N] float;
}


calculate_Forces :: (
	config : *Thruster_Configuration($N),
	params : *Parameters(N)) -> (Vector3, Vector3)
{
	force  : Vector3;
	torque : Vector3;
	for config.thrusters
	{
		f := it.direction * clamp(params.power[it_index], 0 , 1);
		force += f;
		torque += cross(it.position, f);
	}
	return force, torque;
}
