#import "Basic";

CONFIG_NAME :: "asteroid.jai";

build_Method :: (name : string)
{
	CC :: #import "Compiler";
	CC.set_build_options_dc(.{do_output =false});
	w := CC.compiler_create_workspace(name);
	if !w  
	{
		print("Failed to create %\n", name);
		return;
	}
	o := CC.get_build_options(w);
	path := #filepath;
	
	base := tprint("%/%/", path, name);
	{
		o.output_path = tprint("%/.build/", base);
		o.output_executable_name = name;
		o.intermediate_path = o.output_path;
		//CC.set_optimization_level(*o,3,0);
		CC.set_build_options(o, w);
	}
	CC.add_build_file(tprint("%/main.jai", base),w);

}


#run {
	CC :: #import "Compiler";
	CC.set_build_options_dc(.{do_output = false});;
	build_Method("UnweightedUnconstrainedLinearAllocation");
}
