using JuMP, Cbc, CSV, PrettyTables


Raw_Plants_Data = CSV.read("Raw-Plants.csv", header=true)
Plants_DC_Data = CSV.read("Plants-DC.csv", header=true)
DC_Wares_Data = CSV.read("DC-Wares.csv", header=true)
Wares_Stores_Data = CSV.read("Wares-Stores.csv", header=true)

Raw_Plants_Costs = Matrix{Float64}(Raw_Plants_Data[1:4,2:5])
Plants_DC_Costs = Matrix{Float64}(Plants_DC_Data[1:4,2:5])
DC_Wares_Costs = Matrix{Float64}(DC_Wares_Data[1:4,2:5])
Wares_Stores_Costs = Matrix{Float64}(Wares_Stores_Data[1:4,2:5])

Raw_Fixed = Array{Float64}(Raw_Plants_Data[1:4,6])
Plants_Fixed = Array{Float64}(Plants_DC_Data[1:4,6])
DC_Fixed = Array{Float64}(DC_Wares_Data[1:4,6])
Wares_Fixed = Array{Float64}(Wares_Stores_Data[1:4,6])
Stores_Fixed = 9500

Raw_Supply = Array{Float64}(Raw_Plants_Data[1:4,7])
Store_Demand = transpose(Array{Float64}(Wares_Stores_Data[5,2:5]))

numF = 4

caseModel = Model(Cbc.Optimizer)

@variables(caseModel, begin
    RawToPlants[1:numF,1:numF] >= 0, Int
    PlantsToDC[1:numF,1:numF] >= 0, Int
    DCToWares[1:numF,1:numF] >= 0, Int
    WaresToStores[1:numF,1:numF] >= 0, Int
end)

@variables(caseModel, begin
    RawOpen[1:numF], Bin
    PlantsOpen[1:numF], Bin
    DCOpen[1:numF], Bin
    WaresOpen[1:numF], Bin
    StoresOpen[1:numF], Bin
end)

fixedCosts = @expression(caseModel, sum(RawOpen.*Raw_Fixed) + sum(PlantsOpen.*Plants_Fixed) + sum(DCOpen.*DC_Fixed) + sum(WaresOpen.*Wares_Fixed) + sum(StoresOpen.*Stores_Fixed))

variableCosts = @expression(caseModel, sum(RawToPlants.*Raw_Plants_Costs) + sum(PlantsToDC.*Plants_DC_Costs) + sum(DCToWares.*DC_Wares_Costs) + sum(WaresToStores.*Wares_Stores_Costs))

@objective(caseModel, Min, fixedCosts + variableCosts)

for n = 1:numF
    @constraints(caseModel, begin
        sum(WaresToStores[1:numF,n]) == Store_Demand[n]
        sum(RawToPlants[n,1:numF]) <= Raw_Supply[n]*.9*RawOpen[n]
        PlantsToDC[:,n] in SOS1()
    end)

    @constraints(caseModel, begin
        sum(RawToPlants[:,n]) == sum(PlantsToDC[n,:])
        sum(PlantsToDC[:,n]) == sum(DCToWares[n,:])
        sum(DCToWares[:,n]) == sum(WaresToStores[n,:])
    end)

    @constraints(caseModel, begin
        sum(RawToPlants[:,n]) <= PlantsOpen[n]*typemax(Int)
        sum(PlantsToDC[:,n]) <= DCOpen[n]*typemax(Int)
        sum(DCToWares[:,n]) <= WaresOpen[n]*typemax(Int)
        sum(WaresToStores[:,n]) <= StoresOpen[n]*typemax(Int)
    end)
end

JuMP.optimize!(caseModel)

RTP=JuMP.value.(RawToPlants)
PTD=JuMP.value.(PlantsToDC)
DTW=JuMP.value.(DCToWares)
WTS=JuMP.value.(WaresToStores)

println("Epa! no se imprime el primer print")
println("Amounts")
println(JuMP.value.(RawToPlants))
println(JuMP.value.(PlantsToDC))
println(JuMP.value.(DCToWares))
println(JuMP.value.(WaresToStores))
println("Opens")
println(JuMP.value.(RawOpen))
println(JuMP.value.(PlantsOpen))
println(JuMP.value.(DCOpen))
println(JuMP.value.(WaresOpen))
println(JuMP.value.(StoresOpen))
