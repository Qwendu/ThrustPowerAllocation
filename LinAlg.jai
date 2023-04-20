#import "Math";


EPS :: 0.00001;


Matrix :: struct(Rows : int, Cols : int)
{
	data : [Rows][Cols] float;
}


mul :: (a : *Matrix($N, $K), b : *Matrix(K, $M)) ->*Matrix(N, M)
{
	c := New(Matrix(N,M));
	for row: 0..N-1
	{
		for col : 0..M-1
		{
			scalar_product := 0.0;
			for k: 0..K-1
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
	for row: 0..N-1
	{
		for col: 0..M-1
		{
			b.data[col][row] = a.data[row][col];
		}
	}
	return b;
}


view :: (mat : *$T/Matrix)
{
	#import "Basic";
	fmt :: #bake_arguments formatFloat(width = 6, trailing_width = 6 - 3, zero_removal = .NO);
	for row: 0..T.Rows-1
	{
		for col: 0..T.Cols-1  print("% ", fmt(mat.data[row][col]));
		print("\n");
	}
}


inverse :: (mat : *Matrix($N, N)) -> *Matrix(N,N)
{
	working  := New(Matrix(N, 2 * N));
	for row: 0..N-1
	{
		for col: 0..N-1
		{
			working.data[row][col] = mat.data[row][col];
		}
		working.data[row][N + row] = 1;
	}
	for pivot : 0..N-1
	{
		value := working.data[pivot][pivot];
		if abs(value) < EPS
		{
			print("Non invertible matrix\n");
			break pivot;
		}
		for cols: 0..2 * N - 1
		{
			working.data[pivot][cols] /= value;
		}
		for row : 0..N-1
		{
			if row == pivot  continue row;
			factor := working.data[row][pivot];
			for col : 0..2*N-1
			{
				working.data[row][col] -= working.data[pivot][col] * factor;
			}
		}
	}
	res := New(Matrix(N,N));
	for row: 0..N-1
		for col: 0..N-1
			res.data[row][col] = working.data[row][col + N];
	free(working);
	return res;
}

//svd :: (mat : *$T/Matrix) -> (U : *Matrix(T.Rows, T.Rows), S : *Matrix(T.Rows, T.Cols), V_T : *Matrix(T.Cols, T.Cols))
