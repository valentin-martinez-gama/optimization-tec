using JuMP
using Cbc

LP=Model(Cbc.Optimizer)
@variable(LP, x>=5)
@variable(LP, y>=6)
@constraint(LP, x+y==18)
@constraint(LP, 20x+30y<=470)
@objective(LP, Max, 2x+3y)
status= JuMP.optimize!(LP)
println("X: $(JuMP.value(x))")
println("Y : $(JuMP.value(y))")
println("zzz")
