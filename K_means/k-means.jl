using CSV, Clustering, Plots

client_locations = CSV.read("clients.csv", header=true)
k_coordinates = (Matrix{Float64}(client_locations))'

init = scatter(client_locations.X, client_locations.Y, show=true)

result = kmeans(k_coordinates, 2, init=:kmpp, maxiter=1000, display=:iter)

res = scatter(client_locations.X, client_locations.Y, marker_z = result.assignments,
        color=:lightrainbow, legend=false)

a = assignments(result)
c = counts(result)
M = result.centers
