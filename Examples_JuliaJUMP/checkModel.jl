using JuMP, Cbc

checkModel = Model(Cbc.Optimizer)

@variable(checkModel, box[1:4], binary = true)
@variable(checkModel, routes[1:3,1:4], binary = true)

cost = [75 150 225 75;
        357 255 153 306;
        84 105 126 105]

@objective(checkModel, Min, 150*sum(box[1:3])+sum(cost.*routes))

@constraint(checkModel, box[4]==1)

for city in 1:4
    @constraint(checkModel, routes[:,city].<=box[city])
end
for region in 1:3
    @constraint(checkModel, sum(routes[region,:])==1)
end

res = JuMP.optimize!(checkModel)

boxes = JuMP.value.(box)
routes = JuMP.value.(routes)
