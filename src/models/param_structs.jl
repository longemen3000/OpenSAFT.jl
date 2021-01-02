abstract type Params end

struct PCSAFTParams <: Params
    segment::Dict #type: Dict{String,Float64}, can be changed to vector
    sigma::Dict #matrix of values
    epsilon::Dict #matrix of values
    epsilon_assoc::Dict #look on how to port this
    bond_vol::Dict #look on how to port this Dict{Set{Tuple{Set{String},String}},Float64}
    n_sites::Dict #dict of dicts
end

struct sPCSAFTParams <: Params
    segment::Dict
    sigma::Dict
    epsilon::Dict
    epsilon_assoc::Dict
    bond_vol::Dict
    n_sites::Dict
    k::Dict
end

struct SAFTVRMieParams <: Params
    segment::Dict
    sigma::Dict
    epsilon::Dict
    lambdaA::Dict
    lambdaR::Dict
    epsilon_assoc::Dict
    bond_vol::Dict
    n_sites::Dict
end

struct SAFTVRQMieParams <: Params
    MolarMass::Dict
    segment::Dict
    sigma::Dict
    epsilon::Dict
    lambdaA::Dict
    lambdaR::Dict
    epsilon_assoc::Dict
    bond_vol::Dict
    n_sites::Dict
end

struct ogSAFTParams <: Params
    segment::Dict
    sigma::Dict
    epsilon::Dict
    epsilon_assoc::Dict
    bond_vol::Dict
    n_sites::Dict
end

struct SAFTgammaMieParams <: Params
    segment::Dict
    shapefactor::Dict
    lambda_a::Dict
    lambda_r::Dict
    sigma::Dict
    epsilon::Dict
    epsilon_assoc::DefaultDict
    bond_vol::DefaultDict
    n_sites::DefaultDict
end



struct CPAParams <: Params
    a::Dict
    b::Dict
    c1::Dict
    Tc::Dict
    epsilon_assoc::Dict
    bond_vol::Dict
    n_sites::Dict
end


struct CubicParams <: Params
    mw::Vector{Float64}
    a::Vector{Float64} #Ωₐ*(R*Tc)²/Pc
    b::Vector{Float64} #Ωᵦ*(R*Tc)/Pc
    Tc::Vector{Float64}
    Pc::Vector{Float64}
    ω::Vector{Float64} #acentric_fac
    Aij::Matrix{Float64} #aij = 1- kij, used if has_Aij == true
    has_Aij::Bool
end

