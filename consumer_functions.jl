### functions pertaining to the state and dynamics of consumers
### for use with forage_revised jupyter notebook




#logelifespan=0.85+0.209logeMb
function find_lifespan(mass)
    life_span = 0.85 * mass^0.209
    return life_span * 100
end



function find_velocity(mass)
    # g or kg????
    #Consumer Velocity (meters/second)
    velocity = ((0.33 / (1000^0.21)) * mass^0.21) / 10;
    return velocity
end

function find_handling_time(mass)
        # g or kg????

    #bites per time b = -0.24, a = 0.37
    bite_rate = 0.37 * mass^-0.24; # float, 1/s

    #grams in a bite b = 0.969, a = .002, unit = g
    bite_mass = 0.002 * mass^0.969;

    #Handling time (s) = consumption rate + ...
    handling_time = (1 ./ bite_rate) .* (1 / bite_mass); # [float], [1 / 1/s = s]

    return handling_time .* [1,1]
end

# these help with data aggregation

function handling_by_resource(t_handle)
    by_res = zeros(Float64, number_resources);
    by_res[1] = t_handle[2]+t_handle[3]+t_handle[4]
    by_res[2] = t_handle[5]+t_handle[6]+t_handle[7]
    #by_res[3] = t_handle[8]+t_handle[9]+t_handle[10]
    #by_res[4] = t_handle[11]+t_handle[12]+t_handle[13]
    return by_res
end

function travelling_by_resource(t_travel)
    by_res = zeros(Float64, number_resources);
    by_res[1] = t_travel[2]+t_travel[3]+t_travel[4]
    by_res[2] = t_travel[5]+t_travel[6]+t_travel[7]
   # by_res[3] = t_travel[8]+t_travel[9]+t_travel[10]
    #by_res[4] = t_travel[11]+t_travel[12]+t_travel[13]
    return by_res
end

# update nutrient state on successful foraging (only increases)
function update_nutrient_state(initial_nutrient_state, resource_list, resource; resource_size=1.0)
# tracks absolute nutrient intake
# takes a nutrient state (2d float array) and a resource (int)
# returns an updated nutrient state (2d float array)
    nutrient_state = initial_nutrient_state .+= (resource_size .* resource_list[resource]);

    return nutrient_state

end


# update energy with gains and/or losses
function update_energy_state(initial_energy, cost_field, cost_basal; time=0, energy_gain=0, field=false, basal=false)
    # should take a current energy state as well as gains/costs
    # should output an updated energy state
    if field == true && basal == false
        energy_loss = cost_field * time
        updated_energy = initial_energy + energy_gain - energy_loss
        return updated_energy

        elseif field == false && basal == true
            energy_loss = cost_basal * time
            updated_energy = initial_energy + energy_gain - energy_loss
            return updated_energy
    else
        return "something is awry in this energy update"

    end


end

function update_time(current_time, target, targeted_resource; travel=false, handle=false,
        distance_to_resource=0, velocity=1, travel_time=0, handling_time=0)

    if travel==true && handle==false
        #Add travel time to clock
        # how much time for this single foraging event
        single_travel_time = distance_to_resource[targeted_resource] / velocity;
         # time it takes at the weird modified velocity
        current_time += single_travel_time;
        #Record travel time
        travel_time += single_travel_time;
    return single_travel_time, current_time, travel_time

    elseif travel==false && handle==true
         #Record handling time costs
         # currently no handling tim
        current_time += handling_time;
        handling_time += handling_time;
        return  current_time, handling_time

    else
        return "something has gone awry in the time update"
    end

end
