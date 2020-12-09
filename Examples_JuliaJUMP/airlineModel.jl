using JuMP, Cbc

airlineModel = Model(Cbc.Optimizer)

@variable(airlineModel, t[1:6] >= 0)

route = [428 80;
         190 120;
         642 75;
         224 100;
         512 60;
         190 110]
prices = route[:,1]
demand = route[:,2]

@objective(airlineModel, Max, sum(t.*prices))

@constraint(airlineModel, t[:].<=demand)
@constraint(airlineModel, sum(t[1:4]) <= 166)
@constraint(airlineModel, sum(t[3:6]) <= 166)

res = JuMP.optimize!(airlineModel)

tickets = JuMP.value.(t)
