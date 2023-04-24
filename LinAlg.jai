#import "Math";


EPS :: 0.00001;


Matrix :: struct(rows : int, cols : int)
{
	Rows : int = rows;
	Cols : int = cols;
	data : [rows][cols] float;
}

mul :: (a : *Matrix($N, $K), b : *Matrix(K, $M)) ->*Matrix(N, M)
{
	assert(a.Cols == b.Rows);
	c := New(Matrix(N,M));
	c.Rows = a.Rows;
	c.Cols = b.Cols;
	for row: 0..a.Rows-1
	{
		for col : 0..b.Cols-1
		{
			scalar_product := 0.0;
			for k: 0..b.Rows-1
			{
				scalar_product += a.data[row][k] * b.data[k][col];
			}
			c.data[row][col] = scalar_product;
		}
	}
	return c;
}

transpose :: (a : *Matrix($N, $M)) -> *Matrix(M, N)
{
	b:= New(Matrix(M,N));
	b.Rows = a.Cols;
	b.Cols = a.Rows;
	for row: 0..a.Rows-1
	{
		for col: 0..a.Cols-1
		{
			b.data[col][row] = a.data[row][col];
		}
	}
	return b;
}


view :: (mat : *$T/Matrix)
{

	fmt :: #bake_arguments formatFloat(width = 6, trailing_width = 6 - 3, zero_removal = .NO);
	for row: 0..mat.Rows-1
	{
		for col: 0..mat.Cols-1  print("% ", fmt(mat.data[row][col]));
		print("\n");
	}
}


inverse :: (mat : *Matrix($N, N)) -> *Matrix(N,N)
{
	working  := New(Matrix(N, 2 * N));
	for row: 0..mat.Rows-1
	{
		for col: 0..mat.Cols-1
		{
			working.data[row][col] = mat.data[row][col];
		}
		working.data[row][N + row] = 1;
	}
	for pivot : 0..mat.Rows-1
	{
		value := working.data[pivot][pivot];
		if abs(value) < EPS
		{
			print("Non invertible matrix\n");
			break pivot;
		}
		for col: 0..2 * mat.Rows - 1
		{
			working.data[pivot][col] /= value;
		}
		for row : 0..mat.Rows - 1
		{
			if row == pivot  continue row;
			factor := working.data[row][pivot];
			for col : 0..2*mat.Rows-1
			{
				working.data[row][col] -= working.data[pivot][col] * factor;
			}
		}
	}
	res := New(Matrix(N,N));
	res.Rows = mat.Rows;
	res.Cols = mat.Cols;

	for row: 0..mat.Rows-1
		for col: 0..mat.Cols-1
			res.data[row][col] = working.data[row][col + N];
	free(working);
	return res;
}

#import "Basic";
