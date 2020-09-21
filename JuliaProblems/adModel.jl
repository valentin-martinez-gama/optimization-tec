using JuMP, Cbc, CSV

file = "campaignData.csv"

data_import = CSV.read(file, header=false)
campData = Matrix{Int}(data_import)

totalsColumn = size(campData,2)
numOptions = size(campData,2)-1

customersData = campData[1,1:numOptions]
resourcesData = campData[2:end,1:numOptions]
totalsData = campData[2:end,totalsColumn]

adModel = Model(Cbc.Optimizer)

@variable(adModel, options[1:numOptions], binary=true)
@objective(adModel, Max, sum(options[:].*customersData[:]))

for r = 1:size(resourcesData,1)
    @constraint(adModel, sum(resourcesData[r,:].*options[:])<=totalsData[r])
end
@constraints(adModel, begin
    options[6]-(options[4]+options[5])<=0
    options[2]+options[4]<=1
end)

stats = JuMP.optimize!(adModel)
result = JuMP.value.(options)
