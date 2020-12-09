using JuMP, Cbc, CSV

lightModel = Model(Cbc.Optimizer)

@variable(lightModel, fixtures[1:5], binary=true)
@variable(lightModel, 0 <= luminosity[1:5] <= 300)

@objective(lightModel, Min, 450*sum(fixtures)+2*sum(luminosity))

corridors = [1 2; 1 3; 2 3; 2 4; 3 5; 4 5]
minLuminosity = [250,300,150,200,350,180]

for y = 1:size(fixtures,1)
    @constraint(lightModel, luminosity[y] <= 300*fixtures[y])
end

for c = 1:size(corridors,1)
    @constraint(lightModel, luminosity[corridors[c,1]]+luminosity[corridors[c,2]] >= minLuminosity[c])
end

result = JuMP.optimize!(lightModel)

JuMP.value.(fixtures)
JuMP.value.(luminosity)
