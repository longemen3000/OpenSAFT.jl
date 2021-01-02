abstract type EoS end
abstract type SAFT <: EoS end
abstract type Cubic <: EoS end

abstract type PCSAFTFamily <: SAFT end
abstract type sPCSAFTFamily <: SAFT end
abstract type ogSAFTFamily <: SAFT end
abstract type SAFTVRMieFamily <: SAFT end
abstract type SAFTVRQMieFamily <: SAFT end
abstract type SAFTgammaMieFamily <: SAFT end

#cubics whose volume roots can be solved via polynomials
abstract type StandardCubic <: Cubic end 
abstract type vdWFamily <: StandardCubic end
abstract type RKFamily <: StandardCubic end
abstract type SRKFamily <: StandardCubic end
abstract type PRFamily <: StandardCubic end
abstract type CPAFamily <: Cubic end

#to allow broadcasting without problems
Base.broadcastable(model::EoS) = Ref(model)

struct SAFTVRMie <: SAFTVRMieFamily
    components::Array{Set{String},1}
    params::SAFTVRMieParams
end

struct SAFTVRQMie <: SAFTVRQMieFamily
    components::Array{Set{String},1}
    params::SAFTVRQMieParams
end

struct PCSAFT <: PCSAFTFamily
    components::Array{Set{String},1}
    sites::Array{String,1}
    params::PCSAFTParams
end

struct sPCSAFT <: sPCSAFTFamily
    components::Array{Set{String},1}
    params::sPCSAFTParams
end

struct ogSAFT <: ogSAFTFamily
    components::Array{Set{String},1}
    params::ogSAFTParams
end

struct SAFTgammaMie <: SAFTgammaMieFamily
    components::Array{Set{String},1}
    groups::Array{Set{String},1}
    group_multiplicities::Dict{Set{String},DefaultDict{Set{String},Int64,Int64}}
    params::SAFTgammaMieParams
end

struct vdW{VARIANT} <: vdWFamily
    components::Vector{String}
    params::CubicParams
    variant::VARIANT
end

struct RK{VARIANT} <: RKFamily
    components::Vector{String}
    params::CubicParams
    variant::VARIANT
end

struct SRK{VARIANT} <: SRKFamily
    components::Vector{String}
    params::CubicParams
    variant::VARIANT
end

struct PR{VARIANT} <: PRFamily
    components::Vector{String}
    params::CubicParams
    variant::VARIANT
end

struct CPA <: CPAFamily
    components::Array{Set{String},1}
    params::CPAParams
end
