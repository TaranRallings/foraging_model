### functions pertaining to the state and dynamics of consumers
### for use with forage_revised jupyter notebook


function find_metabolism(mass)
    # i think these relations assume mass in grams, double check
    mass = mass*1000;
    
# function for setting initial energy and metabolic costs from body mass
    #Joules per gram
    joules_per_gram = 20000; #varies between 7000 to 36000 [int] [J/g]
    kjoules_per_gram = joules_per_gram / 1000;   # [int/int=int] [kJ/g]

    #initial_energy_state = mass * kjoules_per_gram;

    #mass at which you die, no fat or muscle
    mass_starve = round(mass - ((0.02 * mass^1.19) + (0.1 * 0.38 * mass^1.0)));


    #how many kj units does this organism have?
    storage_kj = (mass - mass_starve) * kjoules_per_gram; #convert grams to kJ [int-float*int=float] [g-g*kJ/g=kJ]
    #xc = 1;
    #organismal_max = round(Int, xc + organismal_max_kj - 1); #unchanged if xc = 1, [kJ]

    # Metabolic constants for the basal and field metabolic rate
    b0_basal_met_rate = 0.018; #[watts] g^-0.75,
    b0_field_met_rate = 0.047; #[watts] g^-0.75,

    #costs: f/df + sleeping over active hours
    cost_wh_basal = (b0_basal_met_rate * (mass^0.75)); #watt*hour, cost of basal metabolic rate in watt hours
    cost_wh_field = (b0_field_met_rate * (mass^0.75)); #watt*hour, cost of field metabolic rate in watt hours

    #Convert to kiloJoules
    watt_hour_to_kJ = 3.6;  #  [float], [kJ/watthour]

    #Convert kjg to 10kjg
    watt_hour_to_kJ = watt_hour_to_kJ #/ xscale; # scales conversaion constant by xscale (currently is 1)

    #metabolic costs per hour
    cost_basal_hr = cost_wh_basal * watt_hour_to_kJ; # [float], [wh*kJ/wh=kJ/hr]
    cost_field_hr = cost_wh_field * watt_hour_to_kJ; # [float], [wh*kJ/wh=kJ/hr]

    # metabolic costs per second
    cost_basal = cost_basal_hr / 60 / 60;   # [float], [kJ/s]
    cost_field = cost_field_hr / 60 / 60;   # [float], [kJ/s]

    return storage_kj, cost_basal, cost_field, storage_kj*2

end

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
