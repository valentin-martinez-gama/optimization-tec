using JuMP, Cbc

sudokuModel = Model(Cbc.Optimizer)

gridsize = 3
@variable(sudokuModel, x[1:gridsize^2,1:gridsize^2,1:gridsize^2], binary=true)
a = zeros(gridsize^2,gridsize^2,gridsize^2)

as = [
1 4 2;1 5 6;1 7 7;1 9 1;
2 1 6;2 2 8;2 5 7;2 8 9;
3 1 1;3 2 9;3 6 4;3 7 5;
4 1 8;4 2 2;4 4 1;4 8 4;
5 3 4;5 4 6;5 6 2;5 7 9;
6 2 5;6 6 3;6 8 2;6 9 8;
7 3 9;7 4 3;7 8 7;7 9 4;
8 2 4;8 5 5;8 8 3;8 9 6;
9 1 7;9 3 3;9 5 1;9 6 8
]

for n in 1:size(as,1)
    c = as[n,:]
    a[c[1],c[2],c[3]]=1
end

for d1 = 1:gridsize^2
    for d2 = 1:gridsize^2
        @constraints(sudokuModel, begin
            sum(x[d1,d2,:])==1
            sum(x[d1,:,d2])==1
            sum(x[:,d1,d2])==1
        end)
        for k = 1:gridsize^2
            @constraint(sudokuModel, x[d1,d2,k]>=a[d1,d2,k])
        end
    end
end
for s1 = 0:(gridsize-1)
    for s2 = 0:(gridsize-1)
        for k = 1:gridsize^2
            @constraint(sudokuModel, sum(x[3*s1+a,3*s2+b,k] for a=1:gridsize, b=1:gridsize)==1)
        end
    end
end

stats = JuMP.optimize!(sudokuModel)

sol = JuMP.value.(x)
ABC = sum(sol[5,2,:].*collect(1:gridsize^2))+sum(sol[3,6,:].*collect(1:gridsize^2))+sum(sol[9,8,:].*collect(1:gridsize^2))
