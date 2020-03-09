### Functions pertaining to the distribution of resources on the landscape
### for use with forage_revised jupyter notebook

function resource_distributions(observed_mean, observed_variance)
    # derived alpha and c
    c = observed_mean ./ (observed_variance .- observed_mean); # [float] [g/m2 / (g2/m4 * g/m2) = g/m2 / g3/m6 = m4/g2]
    alpha = c .* observed_mean;   # [float] [m4/g2 * g/m2 = m2/g]
    #lambda = alpha ./ c; # [float vector] [g/m2]


    r = alpha;
    p = 1.0 ./ (1.0 .+ c);
    #Define the negative binomial distribution
    #neg_bin = NegativeBinomial(r, p)

    #Define the gamma distribution
    gamma_dist = Gamma.(alpha, 1.0 ./ c); #mean = alpha * (1/c)

    return gamma_dist
end


# function for building list of distances to each resource
function dist_to_resources(number_resources, gamma_dist)
#Draw distances to each resource (meters)
    distance_to_resource = zeros(Float64, number_resources);

    for i = 1:number_resources # for each resource
    # rand can be given a random number generator
    # this is the 2-step distance draw because you can't just build a neg bin
        distance_to_resource[i] = rand(Exponential(1.0 / rand(gamma_dist[i]))); # in meters
        end
    return distance_to_resource
end


#What resource is the closest?
function find_nearest_resource(dist_to_resource)
    distance_tuple = findmin(dist_to_resource); # touple b/c (value, index)
    nearest_distance = distance_tuple[1]; # value of touple
    nearest_resource = distance_tuple[2]; # index of touple
    return nearest_distance, nearest_resource
end
