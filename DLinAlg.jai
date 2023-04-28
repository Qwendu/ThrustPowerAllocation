EPS :: 0.0001;
DMatrix :: struct
{
	Coord :: struct {row : int; col : int;};
	storage : Coord;
	start : Coord;
	end : Coord;
	Cols : int;
	Rows : int;
	data : []float; @Property(.count=storage.Rows*storage.Cols);
}

copy_DMatrix :: (a : DMatrix) -> DMatrix
{
	res : DMatrix = a;
	res.data.count = res.storage.row * res.storage.col;
	res.data.data = alloc(size_of(float) * res.data.count);
	for a.data
	{
		res.data[it_index] = it;
	}
	return res;
}

allocate_DMatrix :: (rows : int, cols : int) -> DMatrix
{
	res : DMatrix;
	res.storage.row = rows;
	res.storage.col = cols;
	res.end = res.storage;
	res.Rows = rows;
	res.Cols = cols;
	res.data.count = res.storage.row * res.storage.col;
	res.data.data = alloc(size_of(float) * res.data.count);

	return res;
}


operator * :: (a : DMatrix, b : DMatrix) -> DMatrix
{
	c : DMatrix = allocate_DMatrix(a.Rows, b.Cols);
	if (a.Cols != b.Rows)
	{
		err := tprint("LHS dimensions are %x%, but RHS dimensions are %x%, %2 != %3\n", a.Rows, a.Cols, b.Rows, b.Cols);
		assert(a.Cols == b.Rows, err);
	}
	
	for row: 0..a.Rows-1
	{
		for col : 0..b.Cols-1
		{
			scalar_product := 0.0;
			for k: 0..a.Cols-1
			{
				scalar_product += a[row][k] * b[k][col];
			}
			c[row][col] = scalar_product;
		}
	}

	return c;
}

operator + :: (a : DMatrix, b : DMatrix) -> DMatrix
{
	r := copy_DMatrix(a);
	for row: 0..r.Rows-1
	{
		for col: 0..r.Cols-1
		{
			r[row][col] += b[row][col];
		}
	}
	return r;
}


operator - :: (a : DMatrix, b : DMatrix) -> DMatrix
{
	r := copy_DMatrix(a);
	for row: 0..r.Rows-1
	{
		for col: 0..r.Cols-1
		{
			r[row][col] -= b[row][col];
		}
	}
	return r;
}
operator [] :: (a : DMatrix, idx : int) -> [] float
{
	res : [] float;
	res.count = a.end.col - a.start.col;
	res.data = *a.data[(idx + a.start.row) * a.storage.col + a.start.col];
	return res;
}

reset_Views :: (a : DMatrix) -> DMatrix
{
	r := a;
	r.start.row = 0;
	r.start.col = 0;
	r.end  .row = a.storage.row;
	r.end  .col = a.storage.col;
	r.Rows = r.end.row - r.start.row;
	r.Cols = r.end.col - r.start.col;
	return r;
}

transpose :: (a : DMatrix) -> DMatrix
{
	b := allocate_DMatrix(a.Cols, a.Rows);
	for row: 0..a.Rows-1
	{
		for col: 0..a.Cols-1
		{
			b[col][row] = a[row][col];
		}
	}
	return b;
}

inverse :: (mat : DMatrix) -> DMatrix
{
	N := mat.Rows;
	working := allocate_DMatrix(mat.Cols, 2 * N);
	for row: 0..N-1
	{
		for col: 0..N-1
		{
			working[row][col] = mat[row][col];
		}
		working[row][N + row] = 1;
	}
	for pivot : 0..N-1
	{
		value := working[pivot][pivot];
		if abs(value) < EPS
		{
			print("Non invertible matrix\n");
			break pivot;
		}
		for cols: 0..2 * N - 1
		{
			working[pivot][cols] /= value;
		}
		for row : 0..N-1
		{
			if row == pivot  continue row;
			factor := working[row][pivot];
			for col : 0..2*N-1
			{
				working[row][col] -= working[pivot][col] * factor;
			}
		}
	}
	res := allocate_DMatrix(N,N);
	for row: 0..N-1
		for col: 0..N-1
			res[row][col] = working[row][col + N];
	free(working.data.data);
	return res;
}

constrained_View :: (mat : DMatrix, row_start : int = -1, col_start : int = -1, row_end : int = -1, col_end : int = -1) -> DMatrix
{
	if col_start == -1  col_start = mat.start.col;
	if row_start == -1  row_start = mat.start.row;
	if col_end   == -1  col_end   = mat.end  .col;
	if row_end   == -1  row_end   = mat.end  .row;
	r := mat;
	r.start.row = row_start;
	r.start.col = col_start;
	r.end  .row = row_end;
	r.end  .col = col_end;
	r.Rows = r.end.row - r.start.row;
	r.Cols = r.end.col - r.start.col;
	
	return r;
}

swap_Column :: (mat : DMatrix, a : int , b : int)
{
	for 0..mat.Rows-1
	{
		temp := mat[it][a];
		mat[it][a] = mat[it][b];
		mat[it][b] = temp;
	}
}

DMatrix_Printer :: (builder :*String_Builder, any : Any, data : *void) -> bool
{
	if any.type == type_info(DMatrix)
	{
		fmt :: #bake_arguments formatFloat(width = 6, trailing_width = 6 - 3, zero_removal = .NO);
		mat :  = <<cast(*DMatrix)any.value_pointer;
		print_to_builder(builder, "DMatrix %x%\n", mat.Rows, mat.Cols);

		for row: 0..mat.Rows-1
		{


			for col: 0..mat.Cols-1
			{
				val := mat[row][col];
				//val : float = xx ((mat.start.row + row) * mat.storage.col + mat.start.col + col);
				print_to_builder(builder, "% ", fmt(val));
			}
			print_to_builder(builder, "\n");
		}
		return true;
	}
	return false;
}

#import "Basic";
#import "Math";
