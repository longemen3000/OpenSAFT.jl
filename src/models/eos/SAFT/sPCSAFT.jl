function a_res(model::sPCSAFTFamily, z, v, T)
    return a_hc(model,z,v,T) + a_disp(model,z,v,T) + a_assoc(model,z,v,T)
end

function a_hc(model::sPCSAFTFamily,z,v,T)
    x = z/sum(z[i] for i in model.components)
    m = model.params.segment
    m̄ = sum(x[i]*m[i] for i in model.components)
    return m̄*a_hs(model,z,v,T) - (m̄-1)*log(g_hs(model,z,v,T))
end

function a_disp(model::sPCSAFTFamily,z,v,T)
    x = z/sum(z[i] for i in model.components)
    m = model.params.segment
    m̄ = sum(x[i]*m[i] for i in model.components)
    return -2*π*N_A*sum(z[i] for i in model.components)/v*I_n(model,z,v,T, 1)*m2ϵσ3(model,z,v,T, 1) - π*m̄*N_A*sum(z[i] for i in model.components)/v*C1(model,z,v,T)*I_n(model,z,v,T, 2)*m2ϵσ3(model,z,v,T, 2)
end

function d(model::sPCSAFTFamily,z,v,T, component)
    ϵ = model.params.epsilon[union(component,component)]
    σ = model.params.sigma[union(component,component)]
    return σ * (1 - 0.12exp(-3ϵ/T))
end

function ζn(model::sPCSAFTFamily,z,v,T, n)
    x = z/sum(z[i] for i in model.components)
    m = model.params.segment
    return N_A*sum(z[i] for i in model.components)*π/6/v * sum(x[i]*m[i]*d(model,z,v,T, i)^n for i in model.components)
end

function g_hs(model::sPCSAFTFamily,z,v,T)
    η = ζn(model,z,v,T, 3)
    return (1-η/2)/(1-η)^3
end

function a_hs(model::sPCSAFTFamily,z,v,T)
    η = ζn(model,z,v,T, 3)
    return (4η-3η^2)/(1-η)^2
end

function C1(model::sPCSAFTFamily,z,v,T)
    x = z/sum(z[i] for i in model.components)
    η = ζn(model,z,v,T, 3)
    m = model.params.segment
    m̄ = sum(x[i]*m[i] for i in model.components)
    return (1 + m̄*(8η-2η^2)/(1-η)^4 + (1-m̄)*(20η-27η^2+12η^3-2η^4)/((1-η)*(2-η))^2)^-1
end

function m2ϵσ3(model::sPCSAFTFamily, z, v, T, ϵ_power = 1)
    x = z/sum(z[i] for i in model.components)
    m = model.params.segment
    σ = model.params.sigma
    ϵ = model.params.epsilon
    #= return sum(x[i]*x[j]*m[i]*m[j] * (sqrt(ϵ[i]*ϵ[j])*(1-k[union(i,j)])/T)^ϵ_power * (0.5*(σ[i]+σ[j]))^3 for i in model.components, j in model.components) =#
    return sum(x[i]*x[j]*m[i]*m[j] * (ϵ[union(i,j)]*(1)/T)^ϵ_power * σ[union(i,j)]^3 for i in model.components, j in model.components)
end

function I_n(model::sPCSAFTFamily,z,v,T, n)
    x = z/sum(z[i] for i in model.components)
    m = model.params.segment
    m̄ = sum(x[i]*m[i] for i in model.components)
    η = ζn(model,z,v,T, 3)
    if n == 1
        corr = [0.9105631445 -0.3084016918 -0.0906148351;
                0.6361281449 0.1860531159 0.4527842806;
                2.6861347891 -2.5030047259 0.5962700728;
                -26.547362491 21.419793629 -1.7241829131;
                97.759208784 -65.255885330 -4.1302112531;
                -159.59154087 83.318680481 13.776631870;
                91.297774084 -33.746922930 -8.6728470368]
    elseif n == 2
        corr = [0.7240946941 -0.5755498075 0.0976883116;
                2.2382791861 0.6995095521 -0.2557574982;
                -4.0025849485 3.8925673390 -9.1558561530;
                -21.003576815 -17.215471648 20.642075974;
                26.855641363 192.67226447 -38.804430052;
                206.55133841 -161.82646165 93.626774077;
                -355.60235612 -165.20769346 -29.666905585]
    end
    return sum((corr[i+1,1] + (m̄-1)/m̄*corr[i+1,2] + (m̄-1)/m̄*(m̄-2)/m̄*corr[i+1,3]) * η^i for i = 0:6)
end

function a_assoc(model::sPCSAFTFamily, z, v, T)
    x = z/sum(z[i] for i in model.components)
    X_iA = X_assoc(model,z,v,T)
    return sum(x[i]*sum(log(X_iA[i,a])-X_iA[i,a]/2 + model.params.n_sites[i][a]/2 for a in keys(model.params.n_sites[i])) for i in model.components)
end

function X_assoc(model::sPCSAFTFamily, z, v, T)
    x = z/sum(z[i] for i in model.components)
    ρ = N_A*sum(z[i] for i in model.components)/v
    X_iA = Dict()
    X_iA_old = Dict()
    tol = 1.
    iter = 1
    while tol > 1e-12 && iter < 100
        for i in model.components
            for a in keys(model.params.n_sites[i])
                A = 0.
                for j in model.components
                    B = 0
                    for b in keys(model.params.n_sites[j])
                        if haskey(model.params.epsilon_assoc,Set([(i,a),(j,b)]))
                            if iter!=1
                                B+=X_iA_old[j,b]*Δ(model,z,v,T,i,j,a,b)
                            else
                                B+=Δ(model,z,v,T,i,j,a,b)
                            end
                        end
                    end
                    A += ρ*x[j]*B
                end
                if iter == 1
                    X_iA[i,a] =0.5+0.5*(1+A)^-1
                else
                    X_iA[i,a] =0.5*X_iA_old[i,a]+0.5*(1+A)^-1
                end
            end
        end
        if iter == 1
            tol = sqrt(sum(sum((1. -X_iA[i,a])^2 for a in keys(model.params.n_sites[i])) for i in model.components))
        else
            tol = sqrt(sum(sum((X_iA_old[i,a] -X_iA[i,a])^2 for a in keys(model.params.n_sites[i])) for i in model.components))
        end
        X_iA_old = deepcopy(X_iA)
        iter += 1
    end

    return X_iA
end

function Δ(model::sPCSAFTFamily, z, v, T, i, j, a, b)
    ϵ_assoc = model.params.epsilon_assoc[Set([(i,a),(j,b)])]
    κ = model.params.bond_vol[Set([(i,a),(j,b)])]
    σ = model.params.sigma[union(i,j)]
    g = g_hs(model,z,v,T)
    return g*σ^3*(exp(ϵ_assoc/T)-1)*κ
end
