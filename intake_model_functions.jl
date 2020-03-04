### Foraging model functions from the intake only version
# to do
# clarify g/kg
# track origins of ALL allo eqns
# clean and comment


function bite_size_allo(mass, plant)
    # from shipley 94 "the scaling of intake rate"
    # mass in kg
    # bite size in g
    if plant == "browse"
        bite_size = (0.057* (mass)^0.63); # [g]
        
    elseif plant == "graze"
        bite_size = (0.026 * (mass)^0.59); # [g]
        
    end
    
    return bite_size
    
end

bite_size = bite_size_allo(100.0, "browse")

function bite_rate_allo(mass)
    # not sure where from
    bite_rate = 0.37 * mass^(-0.024)
    
    return bite_rate
    
end

bite_rate = bite_rate_allo(100.0)

bite_rate * bite_size

function alpha_allo(mass, plant)
    bite_rate = bite_rate_allo(mass)
    bite_size = bite_size_allo(mass, plant)
    alpha = bite_rate * bite_size
    return alpha
end
 

function number_of_chews(mass)
    #chew/g (processed to mean particle size (allo) and swallowed)
    # shipley 94
    chews_per_gram = 364.97* mass^(-0.86);
    
    return chews_per_gram
    
end

function chew_rate_allo(mass, teeth)
    # from "dental functional morphology predicts scaling"
    # mass in kg
    # duration in ms
    if teeth == "bunodont"
        chewing_cycle_duration = (228.0* (mass)^0.246) / 1000; # 2.358 [ms -> s]
        
    elseif teeth == "acute/obtuse lophs"
        chewing_cycle_duration = (299.2 * (mass)^0.173) / 1000; # 2.476 [ms -> s]
        
    elseif teeth == "lophs and non-flat"
        chewing_cycle_duration = (320.6 * (mass)^0.154) / 1000; # 2.506 [ms -> s]
        
    elseif teeth == "lophs and flat"
        chewing_cycle_duration = (262.4* (mass)^0.207) / 1000; # 2.419 [ms -> s]0
        
    end
    
    return 1 / (chewing_cycle_duration )  #[s/chew -> chews/s]
    
end


chew_rate = chew_rate_allo(100.0, "lophs and non-flat") 

chews_per_gram = number_of_chews(100.0)

beta = chew_rate / chews_per_gram

function beta_allo(mass, teeth)
    chew_rate = chew_rate_allo(mass, teeth) 
    chews_per_gram = number_of_chews(mass)
    beta = chew_rate / chews_per_gram
    return beta
end


function mean_retention_time(mass, gut_type)
    # mean retention of a particle in the gut [s]
    
    
    if gut_type == "caecum"
        mean_retention_time = (23.6 * (mass)^0.24) 
        
    elseif gut_type == "colon"
        mean_retention_time = (34.2 * (mass)^0.04)
        
    elseif gut_type == "non-rumen foregut"
        mean_retention_time = (34.7 * (mass)^0.08)
        
    elseif gut_type == "rumen foregut"
        mean_retention_time = (24.7 * (mass)^0.13)
        
    end
    
    return mean_retention_time * 60 * 60 # [hr -> s]
    
end




mean_retention_time(100.0, "rumen foregut")

function gut_volume_g(mass, gut_type)
    # from "case of nonscaling"
    # wet mass of guts in kg
    # bm in kg
    
    if gut_type == "caecum"
        capacity = (0.102* (mass)^1.05); 
        
    elseif gut_type == "colon"
        capacity = (0.117 * (mass)^1.03);
        
    elseif gut_type == "non-rumen foregut"
        capacity = (0.100 * (mass)^1.11);
        
    elseif gut_type == "rumen foregut"
        capacity = (0.114 * (mass)^1.05);
        
    end
    
    return capacity * 1000 #[kg -> g]
    
end



function mean_particle_mass(mass, gut_type)
    # from "comparative chewing efficiency"
    # mean particle size in mm 
    # mass in g 
    
    if gut_type == "rumen foregut" # ruminant
        mean_particle_size = (7.74 * (mass)^0.22) 
        
    elseif gut_type == "colon" # hindgut
        mean_particle_size = (6.61 * (mass)^0.26)
        
        else print("what are these guts?")
    
    end
    
    volume = (4/3) * pi * (1/2 * mean_particle_size)^3; # [mm^3]
    particle_mass = 0.0004 * volume; # [g/mm^3 * mm^3 = g]
    
    return particle_mass
    
end


particle_mass = mean_particle_mass(100.0, "rumen foregut"); # [g]
retention_time = mean_retention_time(100.0, "rumen foregut"); # [s]

particle_mass

retention_time

function outflow_rate(gut_fill, mrt)
    # function to capture processing rate of gut
    # gut_fill [g], mrt [s]
    gamma = gut_fill/mrt #[g/s]
    return gamma
end



function find_metabolism(mass)
    # takes a terrestrial mammal body mass (kg), returns storage masses and metabolic rates
    # find a source for this     
    
    mass_g = mass * 1000; #[kj]->[g]
# function for setting initial energy and metabolic costs from body mass
    #Joules per gram
    joules_per_gram = 20000; #varies between 7000 to 36000 [int] [J/g]
    kjoules_per_gram = joules_per_gram / 1000;   # [int/int=int] [kJ/g]  
    
    #initial_energy_state = mass_g * kjoules_per_gram;
    
    
    # from Yeakel et al 2018 Dynamics of starvation and recovery
    #mass at which you die, no fat or muscle
    fat_mass =  0.02*mass_g^1.19           #[g]
    muscle_mass = 0.383*mass_g^1.0         #[g]
    # you starve when muscle and fat stores have been depleted
    mass_starve = round(mass_g - (fat_mass + muscle_mass));  #[g]
    
    #how many kj units does this organism have?
    #convert grams to kJ [int-float*int=float] [g-g*kJ/g=kJ]
    storage_kj = (fat_mass + muscle_mass) * kjoules_per_gram; 
        

    
    
    
    # Metabolic constants for the basal and field metabolic rate
    b0_basal_met_rate = 0.018; #[watts] g^-0.75, 
    b0_field_met_rate = 0.047; #[watts] g^-0.75,
 
    #costs: f/df + sleeping over active hours
    cost_wh_basal = (b0_basal_met_rate * (mass_g^0.75)); #watt*hour, cost of basal metabolic rate in watt hours
    cost_wh_field = (b0_field_met_rate * (mass_g^0.75)); #watt*hour, cost of field metabolic rate in watt hours

    #Convert to kiloJoules
    watt_hour_to_kJ = 3.6;  #  [float], [kJ/watthour]

    #metabolic costs per hour
    cost_basal_hr = cost_wh_basal * watt_hour_to_kJ; # [float], [wh*kJ/wh=kJ/hr]
    cost_field_hr = cost_wh_field * watt_hour_to_kJ; # [float], [wh*kJ/wh=kJ/hr]

    # metabolic costs per second
    cost_basal = cost_basal_hr / 60 / 60;   # [float], [kJ/s]
    cost_field = cost_field_hr / 60 / 60;   # [float], [kJ/s]
    
    return storage_kj, cost_basal, cost_field, storage_kj*2
    
end


find_metabolism(100.0)

7978.888 / 24 / 60 / 60

function update_compartments(t, mouth, gut, fat, rates, costs, resource_gain; 
        cropping=false, chewing=false, travelling=false, resource=0)
    
   # function to update compartments with time
   # takes: time, current mouth, gut, and fat levels, intake mass
    if cropping == true && chewing == false
        mouth += rates[1][resource];
    end
        
    if cropping==false && chewing == true
       if mouth >= (beta)
           gut += rates[2] * t;
            mouth -= rates[2] * t;
        elseif mouth >0 && mouth < beta
            mouth -= mouth;
            gut += mouth;
        end
    end
        
    
    if cropping==true && chewing == true
        return print("you can't chew and crop")
    end
    
   if gut >0
        gut -= min(gut, rates[3]*t);
        fat += min(gut, rates[3]*t*16.7); #conversion g -> kj
    end
  
    
    if travelling==false
        fat -= min(fat, costs[1] * t); # 
    elseif travelling==true
        fat -= min(fat, costs[2] * t); #
    end
    #elseif fat <= 0
        #return print("you have died")
    
    
    return mouth, gut, fat
    
end

function catch_food(chosen_resource, num_succ)
#Do you catch the food?
# will currently always catch food
    catch_food = rand();
    if catch_food < catch_success[chosen_resource]
    #You caught it! Pat yourself on the back
                            
    # indexing here works, i think, b/c weight of target 1 is 0, so this never 
    # comes up. If the weighting of target 1 changes, this will break
    num_succ[chosen_resource] += 1; 
    end
        return num_succ
end 
      




            

function forage(strategy_id, target_weight, target, resource_stats)
    # incomplete
    let nearest_resource = 0,
    #t = 0.0, # start the clock for the day
    nearest_distance = 0.0 # init the distance of nearest resource
    distances = dist_to_resources(resource_stats);
    nearest_distance, nearest_resource = find_nearest_resource(resource_stats, distances)
    chosen_resource = which_resource(strategy_id, target_weight, 
            target, nearest_resource)
    chosen_distance = distances[chosen_resource]

        return chosen_resource, chosen_distance
    end
        #return chosen_resource
    
end

function travel(strategy_id, target_weight, target, resource_stats, velocity, t, t_max)
    resource, distance = forage(strategy_id, target_weight, target, resource_stats)
    travel_time = distance/velocity; 

    if t_max >= travel_time + t
        return resource, travel_time
        elseif t_max < travel_time + t
            travel(strategy_id, target_weight, target, resource_stats, velocity, t, t_max)
        else
            return print("something is awry in travel")
        end
    end


# checked basic function with res =  [[1 2]; [3 4]; [5 6]]
# haven't done full check-expect

function resource_selection(strategy_id,target_weight, target, resource_stats)
    # pulls distance to resources, nearest resource, and which_res into 1 function call
    
    dist_to_resource = dist_to_resources(resource_stats);
    nearest_distance, nearest_resource = find_nearest_resource(resource_stats, dist_to_resource);
    chosen_resource = which_resource(strategy_id, target_weight, target, nearest_resource);
    
    return chosen_resource, dist_to_resource[chosen_resource]
end


function which_resource(strategy_id, target_weight, target, nearest_resource)
    # chooses between a targeted resource and the nearest resource
    # produces single Int value resource (1 or 2)
    # weighted coin flip, higher weight, more likely 1
    bernouli_dist = Bernoulli(1-target_weight[target]); 
    draw = rand(bernouli_dist);
    
    #If we draw a 0, the consumer will move towards the TARGETED RESOURCE
    if draw == 0 # if coinflip=0 (more likely if lower weighting)    
    # which resource is targeted?
    chosen_resource = strategy_id[target];   
    
    #If we draw a 1, the consumer will move towards the CLOSEST RESOURCE
        elseif draw == 1
        chosen_resource = nearest_resource  
    end
    
    return chosen_resource #, draw, strategy_id[target]
end


# function for building list of distances to each resource
# produces distances for [res1, res2]
function dist_to_resources(resource_stats)
    number_resources = length(resource_stats[:,1])
#Draw distances to each resource (meters)
    gamma_dist = resource_distributions(resource_stats[1,:], resource_stats[2,:]);
    distance_to_resource = zeros(Float64, number_resources);

    for i = 1:number_resources # for each resource
    # rand can be given a random number generator
    # this is the 2-step distance draw because you can't just build a neg bin
        distance_to_resource[i] = rand(Exponential(1.0 / rand(gamma_dist[i]))); # in meters
        end
    
    return distance_to_resource    
end 

                
#What resource is the closest?
# produces tuple of (distance, resource_id)
function find_nearest_resource(resource_stats, dist_to_resource)
    
    distance_tuple = findmin(dist_to_resource); # touple b/c (value, index)
    nearest_distance = distance_tuple[1]; # value of touple
    nearest_resource = distance_tuple[2]; # index of touple        
    return nearest_distance, nearest_resource
end
