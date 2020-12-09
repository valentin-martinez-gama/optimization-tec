using JuMP, Cbc, CSV, PrettyTables

#Importar datos de Excel
nodes_import = CSV.read("Node_Coordinates.csv", header = true)

#Definir que hay en cada columna del excel y cuantos nodos hay en total
num_nodes = size(nodes_import,1)
idcol = 1
Xcol = 2
Ycol = 3

#Generar la Matriz de distancias a partir del numero de nodos
distance_matrix = Array{Float64}(undef, (num_nodes, num_nodes))
#Llenar la matriz de distancias entre todos los puntos usando Pitagoras
for n in 1:num_nodes
    for s in 1:num_nodes
        distance_matrix[n,s] = sqrt((nodes_import[n,Ycol] - nodes_import[s,Ycol])^2 +
        (nodes_import[n,Xcol] - nodes_import[s,Xcol])^2)
    end
end

println(pretty_table(nodes_import))
println(distance_matrix)

mtzModel = Model(Cbc.Optimizer)
@variable(mtzModel, rutas[1:num_nodes,1:num_nodes], binary=true)
@variable(mtzModel, 2 <= u[2:num_nodes] <= num_nodes)
@objective(mtzModel, Min, sum(rutas[:,:].*distance_matrix[:,:]))
for i = 1:num_nodes
    @constraint(mtzModel, sum(rutas[i,:]) == 1)
    @constraint(mtzModel, sum(rutas[:,i]) == 1)
    @constraint(mtzModel, rutas[i,i] == 0)
end
for i = 2:num_nodes
    for j = 2:num_nodes
        @constraint(mtzModel, u[i]-u[j]+1 <= (num_nodes-1)*(1-rutas[i,j]))
    end
end
stats = JuMP.optimize!(mtzModel)
print(pretty_table(JuMP.value.(rutas)))
