#= Code written by Valentín Martpinez Gama @valenmgama with assistance in
    development from Eduardo Garza, Mariela Romano, Jorge Serrano and Manek
    Raffiel.

    To participate in the Bastida Challenge 2020 - Traveling Salesman Problem

     Heuristic Genetic Algorithm"
=#

using Random, CSV, DataFrames
const file = "challenge2020_s1111.csv"

const pop_size = 10000
const elites = 100
const survivors = 4950
const mutts = 3500
const gens = 150

function generate_distance_matrix(file)
    #Importar datos de Excel
    nodes_import = CSV.read(file, header = true)

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
    #println(pretty_table(nodes_import))
    #println(pretty_table(distance_matrix))
    return distance_matrix
end

const distance_matrix = generate_distance_matrix(file)
const num_nodes = size(distance_matrix, 1)

function fitness_function(path)
    return distance_matrix[path[end],path[1]] +
        sum(distance_matrix[path[i-1],path[i]] for i = 2:num_nodes)
end

struct Individual
    generation::Int
    genes::Vector{Int}
    fitness_score::Float64
end
Individual(gen, genes) = Individual(gen, genes, fitness_function(genes))

function init_poulation(pop_size)
    population = Vector{Individual}(undef,pop_size)
    for i in 1:pop_size
        population[i] = Individual(1,randperm(num_nodes))
    end
    return population
end

function new_generation!(population, mating_pool, gen)

    for p in 1:survivors
        parent1 = mating_pool[p]
        parent2 = mating_pool[rand(1:survivors)]

        for (c,I) in enumerate(cross_parents(parent1.genes, parent2.genes, gen))
            if c == 1
                population[elites+p] = I
            elseif c == 2
                population[elites+survivors+p] = I
            else
                print("Error")
            end
        end
    end

    for m in 1:(mutts÷2)
        mutt_1 = population[rand(10:pop_size)]
        mutt_2 = population[rand(10:pop_size)]
        mutate_type1!(mutt_1)
        mutate_type2!(mutt_2)
    end
end

function cross_parents(parent1_genes, parent2_genes, gen)

    cross_point = rand(1:num_nodes-1)

    ch1_genes = similar(parent1_genes)
    ch2_genes = similar(parent2_genes)
    ch1_genes[1:cross_point] = @view parent1_genes[1:cross_point]
    ch2_genes[1:cross_point] = @view parent2_genes[1:cross_point]
    parent1_left = @view parent1_genes[cross_point+1:end]
    parent2_left = @view parent2_genes[cross_point+1:end]

    ch1_pending = similar(parent1_left, Tuple{Int, Int})
    ch2_pending = similar(parent2_left, Tuple{Int, Int})


    for (index, value) in enumerate(parent1_left)
        ch1_pending[index] = (value, findfirst(isequal(value), parent2_genes)::Int64)
    end
    sort!(ch1_pending, by = last)
    for (index, (value, _)) in enumerate(ch1_pending)
        ch1_genes[cross_point+index] = value
    end

    for (i, v) in enumerate(parent2_left)
        ch2_pending[i] = (v, findfirst(isequal(v), parent1_genes)::Int64)
    end
    sort!(ch2_pending, by = last)
    for (i,(v, _)) in enumerate(ch2_pending)
        ch2_genes[cross_point+i] = v
    end

    return (Individual(gen,ch1_genes), Individual(gen,ch2_genes))
end

function mutate_type1!(mutt_1::Individual)
    mutt_gene = rand(1:num_nodes-1)
    i = findfirst(isequal(mutt_gene), mutt_1.genes)
    j = findfirst(isequal(mutt_gene+1), mutt_1.genes)
    mutt_1.genes[i] = mutt_gene+1
    mutt_1.genes[j] = mutt_gene
end

function mutate_type2!(mutt_2::Individual)
    mutt_gene = rand(1:num_nodes-2)
    i = findfirst(isequal(mutt_gene), mutt_2.genes)
    j = findfirst(isequal(mutt_gene+2), mutt_2.genes)
    mutt_2.genes[i] = mutt_gene+2
    mutt_2.genes[j] = mutt_gene
end

function GA()
    population = init_poulation(pop_size)
    mating_pool = Array{Individual}(undef, survivors)

    for g = 2:gens

        partialsort!(population, survivors, by = p -> p.fitness_score)
        mating_pool = @view population[1:survivors]

        new_generation!(population, mating_pool, g)

        if (population[1].fitness_score == population[elites].fitness_score) || ((g - population[1].generation) > 6)
            print("Convergencia en la GEN")
            println(g)
            println("TODOS ELITES IGUALES")
            break
        end
        if ((g - population[1].generation) > gens/5)
            print("Convergencia en la GEN")
            println(g)
            print("SIN CAMBIOS en x GENS x = ")
            println(gens/5)
            break
        end
        println(g)
    end
    println()
    sort!(population, by = p -> p.fitness_score)
    return population[1]
end

@time winner = GA()
print(winner)

function arcs_function(sequence)
    arcs = zeros(Int, num_nodes, num_nodes)
    i = sequence[1]
    for s in 2:length(sequence)
        j = sequence[s]
        arcs[i,j] = 1
        i = j
    end
    arcs[i,sequence[1]] = 1
    return arcs
end

arc_matrix = arcs_function(winner.genes)

df = DataFrame(arc_matrix)
CSV.write("tabla_arcos.csv", df)
