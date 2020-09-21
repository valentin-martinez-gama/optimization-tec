using JuMP, Cbc, CSV

lightModel = Model(Cbc.Optimizer)

@variable(lightModel, fixtures[1:5], binary=true)
@variable(lightModel, 0 <= luminosity[1:5] <= 300)
@variable(lightModel, w, binary=true)
@variable(lightModel, z[1:5], binary=true)

@objective(lightModel, Min, 450*sum(fixtures)+2*sum(luminosity))

corridors = [1 2; 1 3; 2 3; 2 4; 3 5; 4 5]
minLuminosity = [250,300,150,200,350,180]

for y = 1:size(fixtures,1)
    @constraint(lightModel, luminosity[y] <= 300*fixtures[y])
end
for c = 1:size(corridors,1)
    @constraint(lightModel, luminosity[corridors[c,1]]+luminosity[corridors[c,2]] >= minLuminosity[c])
end
@constraint(lightModel, luminosity[1]>=300*w)
@constraint(lightModel, luminosity[4]>=300*(1-w))
@constraint(lightModel, sum(z)>=3)
for zi = 1:size(z,1)
    @constraint(lightModel, luminosity[zi]<=150+150*(1-z[zi]))
end
@constraint(lightModel, .6*luminosity[1]-.4*luminosity[3]<=0)

result = JuMP.optimize!(lightModel)

JuMP.value.(z)
JuMP.value.(fixtures)
JuMP.value.(luminosity)
