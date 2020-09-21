using JuMP, Cbc, CSV

file = "compatibility_score.csv"

scores_import = CSV.read(file, header=false)
scores = Matrix{Int}(scores_import)
dims = size(scores,1)

dateModel = Model(Cbc.Optimizer)

@variable(dateModel, matches[1:dims, 1:dims], binary=true)
@objective(dateModel, Max, sum(matches[:,:].*scores[:,:]))

for i = 1:dims
    @constraint(dateModel, sum(matches[i,:]) <=1 )
    @constraint(dateModel, sum(matches[:,i]) <=1 )
end

stats = JuMP.optimize!(dateModel)

print("Solution status: ")
println(termination_status(dateModel))
print("Objective value = ")
println(objective_value(dateModel))
matchList = findall(m->m==1,value.(matches))
println("Enter matchList to console to display list of matches")
