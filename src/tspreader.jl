using Printf, LinearAlgebra
using Base.Filesystem: basename, splitext

const INFINITE = typemax(Int)

# ---------------------- Estrutura Data ----------------------
mutable struct Data
    instanceName::String
    nbOfPar::Int
    dimension::Int
    explicitCoord::Bool
    xCoord::Vector{Float64}
    yCoord::Vector{Float64}
    distMatrix::Matrix{Float64}

    function Data(qtParam::Int, instance::String)
        if qtParam < 2
            error("Missing parameters\nUsage: ./exeLaRP [Instance]")
        elseif qtParam > 2
            error("Too many parameters\nUsage: ./exeLaRP [Instance] [Upper Bound] [Search method]")
        end
        new(instance, qtParam, -1, false, Float64[], Float64[], zeros(0,0))
    end
end

# ---------------------- Funções Auxiliares ----------------------
function CalcDistEuc(X, Y, I, J)
    sqrt((X[I]-X[J])^2 + (Y[I]-Y[J])^2)
end

function CalcDistAtt(X, Y, I, J)
    rij = sqrt(((X[I]-X[J])^2 + (Y[I]-Y[J])^2)/10)
    tij = floor(rij + 0.5)
    dij = tij < rij ? tij + 1 : tij
    dij
end

function CalcLatLong(X, Y, n)
    PI = 3.141592
    latitude = zeros(n)
    longitude = zeros(n)
    for i in 1:n
        deg = floor(X[i])
        min = X[i] - deg
        latitude[i] = PI * (deg + 5*min/3)/180
        deg = floor(Y[i])
        min = Y[i] - deg
        longitude[i] = PI * (deg + 5*min/3)/180
    end
    return latitude, longitude
end

function CalcDistGeo(latit, longit, I, J)
    RRR = 6378.388
    q1 = cos(longit[I]-longit[J])
    q2 = cos(latit[I]-latit[J])
    q3 = cos(latit[I]+latit[J])
    Int(RRR * acos(0.5*((1+q1)*q2 - (1-q1)*q3)) + 1.0)
end

# ---------------------- Métodos Data ----------------------
function read!(data::Data)
    # Ler todas as linhas
    file_lines = readlines(data.instanceName)

    # ----------------- DIMENSION -----------------
    dim_line = findfirst(x -> occursin("DIMENSION", x), file_lines)
    if dim_line === nothing
        error("Dimension not found in file")
    end
    data.dimension = parse(Int, strip(split(file_lines[dim_line], ":")[end]))

    # ----------------- EDGE_WEIGHT_TYPE -----------------
    ew_line = findfirst(x -> occursin("EDGE_WEIGHT_TYPE", x), file_lines)
    if ew_line === nothing
        error("EDGE_WEIGHT_TYPE not found")
    end
    typeProblem = uppercase(strip(split(file_lines[ew_line], ":")[end]))

    # Inicializar vetores e matriz
    data.xCoord = zeros(data.dimension)
    data.yCoord = zeros(data.dimension)
    data.distMatrix = zeros(data.dimension, data.dimension)

    # ----------------- Lógica para EXPLICIT -----------------
    if typeProblem == "EXPLICIT"
        ewf_line = findfirst(x -> occursin("EDGE_WEIGHT_FORMAT", x), file_lines)
        ewf = strip(split(file_lines[ewf_line], ":")[end])

        section_start = findfirst(x -> occursin("EDGE_WEIGHT_SECTION", x), file_lines)
        matrix_values = parse.(Float64, split(join(file_lines[(section_start+1):end])))

        idx = 1
        if ewf == "FULL_MATRIX"
            for i in 1:data.dimension, j in 1:data.dimension
                data.distMatrix[i,j] = matrix_values[idx]
                if i == j data.distMatrix[i,j] = INFINITE end
                idx += 1
            end
        else
            error("EDGE_WEIGHT_FORMAT $ewf não suportado")
        end

    # ----------------- Lógica para coordenadas -----------------
    elseif typeProblem in ["EUC_2D", "CEIL_2D", "ATT", "GEO"]
        data.explicitCoord = true
        section_start = findfirst(x -> occursin("NODE_COORD_SECTION", x), file_lines)

        coord_lines = filter(line -> occursin(r"^\s*\d+\s+\d+(\.\d+)?\s+\d+(\.\d+)?\s*$", line), file_lines[(section_start+1):end])

        data.xCoord = zeros(data.dimension)
        data.yCoord = zeros(data.dimension)

        for (i, line) in enumerate(coord_lines)
            tokens = split(line)
            data.xCoord[i] = parse(Float64, tokens[2])
            data.yCoord[i] = parse(Float64, tokens[3])
        end

        latitude, longitude = typeProblem == "GEO" ? CalcLatLong(data.xCoord, data.yCoord, data.dimension) : (zeros(data.dimension), zeros(data.dimension))

        for i in 1:data.dimension, j in 1:data.dimension
            if i == j
                data.distMatrix[i,j] = INFINITE
            else
                if typeProblem == "EUC_2D"
                    data.distMatrix[i,j] = round(CalcDistEuc(data.xCoord, data.yCoord, i, j))
                elseif typeProblem == "CEIL_2D"
                    data.distMatrix[i,j] = ceil(CalcDistEuc(data.xCoord, data.yCoord, i, j))
                elseif typeProblem == "ATT"
                    data.distMatrix[i,j] = CalcDistAtt(data.xCoord, data.yCoord, i, j)
                elseif typeProblem == "GEO"
                    data.distMatrix[i,j] = CalcDistGeo(latitude, longitude, i, j)
                end
            end
        end
    else
        error("Tipo $typeProblem não suportado")
    end

end

# ---------------------- Funções de Apoio ----------------------
function printMatrixDist(data::Data)
    for i in 1:data.dimension
        for j in 1:data.dimension
            @printf("%d ", data.distMatrix[i,j])
        end
        println()
    end
end

function getInstanceName(data::Data)
    base = basename(data.instanceName)
    splitext(base)[1]
end
