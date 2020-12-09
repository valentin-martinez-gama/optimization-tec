using JuMP, Cbc

simMod = Model(Cbc.Optimizer)

@variable(simMod, x1>=0)
@variable(simMod, x2>=0)

@constraints(simMod, begin
    2*x1+x2<=4
    x1+2*x2<=4
    x1+x2>=1
end)

@objective(simMod, Max, -10x1-4x2)

res = JuMP.optimize!(simMod)
