using CSV, Clustering, Plots

DC_data = CSV.read("DC_Coordinates.csv", header=true)
DC_coordinates = (Matrix{Float64}(DC_data[:,1:2]))
DC_population = (Vector{Int64}(DC_data[:,3]))
num_DC = size(DC_data,1)

municipality_data = CSV.read("Municipality_Population_Coordinates.csv", header=true)
municipality_coordinates = (Matrix{Float64}(municipality_data[:,7:8]))
municipality_population = (Vector{Int64}(municipality_data[:,9]))

clustering_points = [DC_coordinates'  municipality_coordinates']
clustering_weights = [DC_population ; municipality_population]

result = kmeans(clustering_points, num_DC, init=[n for n=1:num_DC], weights=clustering_weights, display=:iter)

graph_points = DC_coordinates'
markers = [0 for n=1:num_DC]
c_population = []

for c =1:num_DC

    c_members = findall(g->g==c, result.assignments)

    tot_c=-100000000
    for m in c_members
        tot_c+=clustering_weights[m]
    end
        global c_population
        append!(c_population, tot_c)

    for n in 1:30
        i = rand(c_members)
        global graph_points = hcat(graph_points, clustering_points[:,i])
        append!(markers, result.assignments[i])
    end
end

DC_data.Poblacion = c_population
print(DC_data)
CSV.write("DC_Coordinates.csv", DC_data)

res = scatter(graph_points[1,:], graph_points[2,:], marker_z = markers,
        color=palette(:tab20), markersize=3, legend=false)

display(res)
a = assignments(result)
c = counts(result)
M = result.centers
