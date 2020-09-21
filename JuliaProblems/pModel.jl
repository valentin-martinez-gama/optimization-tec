using JuMP, Cbc

pModel = Model(Cbc.Optimizer)

setupTime = [45 45 45 45; 60 60 60 60; 100 100 100 100]
price = [50 50 50 50; 70 70 70 70; 120 120 120 120]
cost = [18 18 18 18; 15 15 15 15; 25 25 25 25]
rate = [5 5 5 5; 4 4 4 4 ;2 2 2 2]
demand = [400 600 200 800;
          240 440 100 660;
          80 120 40 100]

@variable(pModel, time[1:3,1:4]<= 435)
@variable(pModel, setUp[1:3,1:4], binary=true)
@variable(pModel, production[1:3,1:4])
@variable(pModel, inventory[1:3,1:4])

@constraint(pModel, time.<=480*setUp)
@constraint(pModel, sum(((setupTime.*setUp)+time),dims = 1) .<= 480)
@constraint(pModel, production .== (time.*rate))

d = 1
    @constraint(pModel, inventory[:,d] .== production[:,d]-demand[:,d])
for d = 2:4
    @constraint(pModel, inventory[:,d] .== inventory[:,d-1]+production[:,d]-demand[:,d])
end

@constraint(pModel, inventory .>= 0)
@constraint(pModel, inventory[:,4] .<= 0)

@objective(pModel, Max, sum(price.*production)-sum(cost.*inventory))

result = JuMP.optimize!(pModel)
