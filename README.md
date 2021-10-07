Samantha Hunter
10/05/2021

-   [Required R Packages](#required-r-packages)
-   [Functions to Query PokeAPI](#functions-to-query-pokeapi)
    -   [Ability](#ability)
        -   [](#section)
-   [](#section-1)
    -   [](#section-2)
    -   [Pokemon Type](#pokemon-type)
    -   [Generation](#generation)
    -   [Habitat](#habitat)
    -   [Berries](#berries)
    -   [Pokemon Base Stats](#pokemon-base-stats)
-   [Exploratory Data Analysis](#exploratory-data-analysis)
    -   [Generating Data Sets](#generating-data-sets)
        -   [Pokemon Attribute
            Exploration](#pokemon-attribute-exploration)
        -   [Exploring Generations](#exploring-generations)
            -   [Is there a power creep between generations of
                pokemon?](#is-there-a-power-creep-between-generations-of-pokemon)

Here we are going to show how to retrieve data from the
[PokeAPI](https://pokeapi.co/) from six endpoints using functions that I
have created. First we’re going to walk through the functions and then
we will do a bit of data exploration.

As a general note, while it is possible to query these endpoints using
numbers, I do not recommend it. For example, in the Ability endpoint,
there are 327 abilities, but you can only query up to ability 267 using
the index number. After that, you must use the ability name to get data
about that ability. To help with this issue, I have provided **a couple
lines of code** before each function that will result in a list of all
available index names that you can query by or you can use the resulting
list to query the entire endpoint as I have done in the data
exploration.

# Required R Packages

The following packages were used to query the API: `httr`: used to
connect to the API via URL `jsonlite`: used to decode the information we
got from the API into plain text `purr`: used to unlist the output from
the API `data.table`: used to combine the lists into a single dataframe

The following packages were used for the data exploration: `tidyverse`:
used for data manipulation and visualization

# Functions to Query PokeAPI

## Ability

The `ability` function interacts with the `ability` endpoint of the
PokeAPI. The function returns a tibble with an observation for each
pokemon that has the ability and what generation the ability was
introduced in.

### 

# 

### 

``` r
# Finding a list of all available abilities
avail_ability <- GET("https://pokeapi.co/api/v2/ability/?limit=327&offset=0")
avail_ability <- rawToChar(avail_ability$content)
avail_ability <- fromJSON(avail_ability)
avail_ability <- avail_ability[["results"]][["name"]]

ability <- function(name, ...){
  ###
  # This function takes the name of the abilities supplied and returns
  # data about the Pokemon that can use this ability, what generation
  # of game the ability originated in
  ###

  url_ability <- paste0("https://pokeapi.co/api/v2/ability/", avail_ability)
  poke_bility <- lapply(url_ability, GET)
  poke_bility <- lapply(poke_bility, '[[', 'content')
  poke_bility <- lapply(poke_bility, rawToChar)
  poke_bility <- lapply(poke_bility, fromJSON)

  # Unlisting our data from the API so that we can create a tidy data frame
  abilities <- (map(poke_bility, "name"))
  ability_pokemon <- (map(map(map(poke_bility, "pokemon"), "pokemon"), "name"))
  ability_generation <- map(map(poke_bility, "generation"), "name")

  # Creating a list of tibbles
  Pokemon_Ability <- list(rep(0, length(unlist(ability_pokemon))))
    for(a in 1:length(ability_pokemon)){
      Pokemon <- unlist(ability_pokemon[a])
      Ability <- rep(abilities[[a]], length(ability_pokemon[a]))
      Generation <- rep(ability_generation[[a]], length(ability_pokemon[a]))
      Pokemon_Ability[[a]] <- as_tibble(cbind(Pokemon, Ability, Generation))
    }

  # Combining our list of tibbles into one tibble
  Pokemon_Ability <- rbindlist(Pokemon_Ability, fill = TRUE)
  return(Pokemon_Ability)
}
```

## Pokemon Type

While there are 20 possible Pokemon types, I’m not interested the
information offered in the shadow or unknown Pokemon. The shadow Pokemon
only offers moves that are available for that Pokemon type. The unknown
Pokemon only have data about the generation of game that this Pokemon
type appeared in.

For the other Pokemon types, you can query this either by numbers, 1
through 18, or with the name of the Pokemon type. The resulting tibble
will only contain information about the Pokemon and the type it is. Some
Pokemon do have more than one type.

``` r
# Finding a list of all possible Pokemon types
avail_types <- GET("https://pokeapi.co/api/v2/type/?limit=20&offset=0")
avail_types <- rawToChar(avail_types$content)
avail_types <- fromJSON(avail_types)
avail_types <- avail_types[["results"]][["name"]]

type <- function(name, ...){
  ###
  # This function takes the Pokemon types and returns all the Pokemon
  # of that type.
  ###
  url_type <- paste0("https://pokeapi.co/api/v2/type/", (c(name, ...)))
  poke_type <- lapply(url_type, GET)
  poke_type <-lapply(poke_type, '[[', 'content')
  poke_type <- lapply(poke_type, rawToChar)
  poke_type <- lapply(poke_type, fromJSON)

  # Unlisting our data from the API so that we can create a tidy data frame
  types <- map(poke_type, "name")
  type_pokemon <- map(map(map(poke_type, "pokemon"), "pokemon"), "name")

  # Creating a list of tibbles
  Pokemon_Type <- list(rep(0, length(unlist(types))))
  for(a in 1:length(types)){
    Pokemon <- unlist(type_pokemon[a])
    Type <- rep(types[[a]], length(type_pokemon[a]))
    Pokemon_Type[[a]] <- as_tibble(cbind(Pokemon, Type))
  }

  # Combining our list of tibbles into one tibble
  Pokemon_Type <- rbindlist(Pokemon_Type)
  return(Pokemon_Type)
}
```

## Generation

In Pokemon, generations are generally regarded as when a ‘batch’ of new
Pokemon species are released and new game mechanics are added to the
video games. This function will return a tibble with observations for
each Pokemon species that was introduced in that generation.

``` r
# Finding a list of all available generations
avail_gen <- GET("https://pokeapi.co/api/v2/generation/")
avail_gen <- rawToChar(avail_gen$content)
avail_gen <- fromJSON(avail_gen)
avail_gen <- avail_gen[["results"]][["name"]]

generation <- function(name, ...){
  ###
  # This function takes the name of the generations supplied and returns
  # the Pokemon that was first introduced in that generation.
  ###
  url_gen <- paste0("https://pokeapi.co/api/v2/generation/", c(name, ...))
  poke_gen <- lapply(url_gen, GET)
  poke_gen <- lapply(poke_gen, '[[', 'content')
  poke_gen <- lapply(poke_gen, rawToChar)
  poke_gen <- lapply(poke_gen, fromJSON)
  
  # Unlisting our data from the API so that we can create a tidy data frame
  gen <- map(poke_gen, "name")
  gen_poke <- map(map(poke_gen, "pokemon_species"), "name")
  
  # Creating a list of tibbles
  Pokemon_Generation <- list(rep(0, length(unlist(gen_poke))))
  for(a in 1:length(gen_poke)){
    Pokemon <- unlist(gen_poke[a])
    Generation <- rep(gen[[a]], length(gen_poke[a]))
    Pokemon_Generation[[a]] <- as.tibble(cbind(Generation, Pokemon))
  }
  
  # Combining our list of tibbles into one tibble
  Pokemon_Generation <- rbindlist(Pokemon_Generation)
  return(Pokemon_Generation)
}
```

## Habitat

This function queries what type of environment Pokemon can be found. It
will return a tibble of the Pokemon that can be found in a habitat.

``` r
# Finding a list of all available habitats
avail_habitat <- GET("https://pokeapi.co/api/v2/pokemon-habitat/?limit=20&offset=0")
avail_habitat <- rawToChar(avail_habitat$content)
avail_habitat <- fromJSON(avail_habitat)
avail_habitat <- avail_habitat[["results"]][["name"]]

habitat <- function(name, ...){
  ###
  # This function takes the name of the habitat and returns what Pokemon that
  # can be found in that habitat
  ###
  url_habitat <- paste0("https://pokeapi.co/api/v2/pokemon-habitat/", c(name, ...))
  poke_habitat <- lapply(url_habitat, GET)
  poke_habitat <-lapply(poke_habitat, '[[', 'content')
  poke_habitat <- lapply(poke_habitat, rawToChar)
  poke_habitat <- lapply(poke_habitat, fromJSON)

  # Unlisting our data from the API so that we can create a tidy data frame
  habitat <- map(poke_habitat, "name")
  habitat_poke <- map(map(poke_habitat, "pokemon_species"), "name")

  # Creating a list of tibbles
  Pokemon_Habitat <- list(rep(0, length(unlist(habitat_poke))))
  for(a in 1:length(habitat_poke)){
    Pokemon <- unlist(habitat_poke[a])
    Habitat <- rep(habitat[[a]], length(habitat_poke[a]))
    Pokemon_Habitat[[a]] <- as_tibble(cbind(Habitat, Pokemon))
  }

  # Combining our list of tibbles into one tibble
  Pokemon_Habitat <- rbindlist(Pokemon_Habitat)
  return(Pokemon_Habitat)

}
```

## Berries

Berries are in-game items that can heal status effects, restore health
points, or have some other effect on Pokemon the berry is fed to. This
function will take the name of the berry and return how long it takes
the berry to grow on a bush and the maximum number of berries on a bush.

``` r
# Finding a list of all available berries
avail_berry <- GET("https://pokeapi.co/api/v2/berry?offset=0&limit=200")
avail_berry <- rawToChar(avail_berry$content)
avail_berry <- fromJSON(avail_berry)
avail_berry <- avail_berry[["results"]][["name"]]

berry <- function(name, ...){
  ###
  # This function takes the name of the berry and returns data about
  # the germination period of berries and the number of fruit the bush bears
  ###
  url_berry <- paste0("https://pokeapi.co/api/v2/berry/", c(name, ...))
  poke_berry <- lapply(url_berry, GET)
  poke_berry <- lapply(poke_berry, '[[', 'content')
  poke_berry <- lapply(poke_berry, rawToChar)
  poke_berry <- lapply(poke_berry, fromJSON)

  # Unlisting our data from the API so that we can create a tidy data frame
  berries <- unlist(map(poke_berry, "name"))
  growth_time <- unlist(map(poke_berry, "growth_time"))
  max_harvest <- unlist(map(poke_berry, "max_harvest"))

  # Combining tibbles into one tibble
  Pokemon_Berry <- as_tibble(cbind(berries, growth_time, max_harvest))
  return(Pokemon_Berry)
}
```

## Pokemon Base Stats

Here we get the base stats of all available Pokemon, as well as what
generation the pokemon belongs to. There are six available stats in the
Pokemon endpoint - hp, attack, defense, special attack, special defense,
and speed.

``` r
# Finding a list of all possible Pokemon
avail_pokemon <- GET("https://pokeapi.co/api/v2/pokemon/?limit=1200&offset=0")
avail_pokemon <- rawToChar(avail_pokemon$content)
avail_pokemon <- fromJSON(avail_pokemon)
avail_pokemon <- avail_pokemon[["results"]][["name"]]


poke_stats <- function(name, ...){
  ###
  # This function takes the Pokemon names and returns all the Pokemon
  # stats for those species.
  ###
  url <- paste0("https://pokeapi.co/api/v2/pokemon/",c(name, ...))
  pokedex <- lapply(X = url, FUN = GET)
  pokedex<-lapply(pokedex, '[[', 'content')
  pokedex <- lapply(pokedex, rawToChar)
  pokedex <- lapply(pokedex, fromJSON)

  # Unlisting our data from the API so that we can create a tidy data frame
  pokemon_stat <- map(pokedex, "name")
  base_stat <- map(map(pokedex, "stats"), "base_stat")

  # Initializing the variables whose values I want
  Pokemon <- rep(0, length(pokemon_stat))
  hp <- rep(0, length(pokemon_stat))
  attack  <- rep(0, length(pokemon_stat))
  defense <- rep(0, length(pokemon_stat))
  sp_attack <- rep(0, length(pokemon_stat))
  sp_defense <- rep(0, length(pokemon_stat))
  speed <- rep(0, length(pokemon_stat))

  # Creating a tibble of the Pokemon and their stats
  for(p in 1:length(pokemon_stat)){
    Pokemon[p] <- pokemon_stat[[p]]
    hp[p] <- as.numeric(base_stat[[p]][1])
    attack[p]  <- base_stat[[p]][2]
    defense[p] <- base_stat[[p]][3]
    sp_attack[p] <- base_stat[[p]][4]
    sp_defense[p] <- base_stat[[p]][5]
    speed[p] <- base_stat[[p]][6]
  }
  Pokemon_Stats <- as_tibble(cbind(Pokemon, hp, attack, defense, sp_attack, sp_defense, speed))

# The stats are printed as character values so we just want to change these to numeric
  for(s in 2:7){
      Pokemon_Stats[[s]] <- as.numeric(Pokemon_Stats[[s]])
  }

  return(Pokemon_Stats)
}
```

# Exploratory Data Analysis

## Generating Data Sets

I only want to analyze the [first 898
Pokemon](https://www.wargamer.com/pokemon-trading-card-game/how-many-pokemon-are-there).
The PokeAPI is structured so that the first 898 Pokemon are the strictly
unique species, while the rest are types of the species that may have a
different regional form or are evolved in a special way that grants them
special base stats. I only wanted to analyze the base stats from
‘normal’ wild Pokemon. Because I want to see if there is a [power
creep](https://tvtropes.org/pmwiki/pmwiki.php/Main/PowerCreep) as the
Pokemon world was built, and not as the player can manipulate their
caught Pokemon. I will also do some general exploration of the Pokemon
attributes.

``` r
# Creating Data Frames
Pokemon_Habitat <- habitat(avail_habitat)
Pokemon_Stats <- poke_stats(avail_pokemon)
Pokemon_Ability <- ability(avail_ability)
Pokemon_Generation <- generation(avail_gen)
```

    ## Warning: `as.tibble()` was deprecated in tibble 2.0.0.
    ## Please use `as_tibble()` instead.
    ## The signature and semantics have changed, see `?as_tibble`.

``` r
# Only querying the first 898 unique pokemon
Pokemon_Stats <- Pokemon_Stats[1:898, ]

# There are no Pokemon unknown or shadow types, so we only need to
# query the first 18 types
Pokemon_Types <- type(1:18)

# Creating a new variable that is the sum of the other statistics
Pokemon_Stats <- Pokemon_Stats %>% mutate(total_stats = hp + attack + defense +
                    sp_attack + sp_defense + speed)

# Here I merging
Pokemon_Stats <- merge(Pokemon_Stats, Pokemon_Generation, by = "Pokemon")

Pokemon_Type1 <- filter(Pokemon_Types, duplicated(Pokemon_Types$Pokemon) == FALSE)
Pokemon_Type2 <- filter(Pokemon_Types, duplicated(Pokemon_Types$Pokemon) == TRUE)

Pokemon_Type1 <- rename(Pokemon_Type1, Type1 = Type)
Pokemon_Type2 <- rename(Pokemon_Type2, Type2 = Type)

# I just want a left join because both Pokemon Types data sets 
# contains the "mega" Pokemon
Pokemon_Type_Stats <- merge(Pokemon_Stats, Pokemon_Type1,
                            by = "Pokemon", all.x = TRUE)
Pokemon_Type_Stats <- merge(Pokemon_Type_Stats, Pokemon_Type2,
                            by = "Pokemon", all.x = TRUE)

# I want to make a table of types, but I don't want to have NA's in
# Type2 because those Pokemon will be excluded so I'm filling in Type1's
# value for Type2 if Type2 is blank. 
Pokemon_Type_Stats <- Pokemon_Type_Stats %>% mutate(
  Type2 = if_else(is.na(Type2) == TRUE, Type1, Type2))

# Using the Quantile Stats, we're also going to make a categorical 
# variable based on the Pokemon's total stats
quantile(Pokemon_Type_Stats$total_stats)
```

    ##    0%   25%   50%   75%  100% 
    ## 180.0 320.0 430.5 500.0 720.0

``` r
# Here the categories split the total_stats into four groups, based on the 
# data quantiles. 
Pokemon_Type_Stats <- Pokemon_Type_Stats %>% mutate(
  TypeCat = if_else(total_stats <= 320, "poor", 
                if_else(total_stats <= 430.5, "fair", 
                    if_else(total_stats <= 500, "good", "great"))), 
  TypeCat = factor(TypeCat, levels = c("poor", "fair", "good", "great")),)
```

### Pokemon Attribute Exploration

Here we’re just getting a feel for the data set and viewing how the
Pokemon games may have changed over the course of generations.

``` r
# Here I'm doing a full join of the Pokemon_Habitat and Pokemon_Generation
# data sets by Pokemon. 
Habitat_Gen <- merge(Pokemon_Habitat, Pokemon_Generation, by = "Pokemon")

# Here is a table of the Pokemon that would be found in each combination
# of generation and habitat
table(Habitat_Gen$Habitat, Habitat_Gen$Generation)
```

    ##                
    ##                 generation-i generation-ii generation-iii
    ##   cave                     8             7             14
    ##   forest                  21            21             29
    ##   grassland               35            25             20
    ##   mountain                18            12             15
    ##   rare                     5             3              2
    ##   rough-terrain            8             5             14
    ##   sea                     15             8             17
    ##   urban                   22            10              5
    ##   waters-edge             19             9             19

I thought it was surprising that habitats were only provided up to
Generation III of the games. According to
[Bulbagarden](https://bulbapedia.bulbagarden.net/wiki/List_of_Pok%C3%A9mon_by_habitat)
and
[Bulbapedia](https://bulbapedia.bulbagarden.net/wiki/Talk:List_of_Pok%C3%A9mon_by_habitat),
the habitat classifications are only a feature in FireRed and LeafGreen,
which are reboots of the 1996 Red and Green games. This explains why
there are no observations included in our contingency table after
Generation III. The Pokemon video games are generally compatible with
previous generations of Pokemon so Generation III games include both
Generation I and Generation II.

``` r
Pokemon_Type_Plot <- ggplot(data = Pokemon_Types, aes(x = Type)) +
  geom_bar(aes(fill = Type)) +
  labs(title = "Prevalent Pokemon Types", x = "Pokemon Habitats",
     y = "Pokemon Counts") +
  theme(axis.text.x=element_text(angle=45))
Pokemon_Type_Plot
```

![](../images/unnamed-chunk-14-1.png)<!-- -->

``` r
addmargins(table(Pokemon_Type_Stats$Type1, Pokemon_Type_Stats$Type2))
```

    ##           
    ##            bug dark dragon electric fairy fighting fire flying ghost grass ground ice normal
    ##   bug       19    0      0        4     2        0    4      0     1     5      0   2      0
    ##   dark       0   11      0        0     3        0    0      0     0     0      0   0      0
    ##   dragon     0    4     13        0     0        0    0      0     0     0      0   0      0
    ##   electric   0    1      2       32     2        0    0      0     0     0      0   1      0
    ##   fairy      0    0      0        0    18        0    0      0     0     0      0   0      0
    ##   fighting   3    3      2        0     0       27    6      1     1     3      0   1      0
    ##   fire       0    3      2        0     0        0   32      0     0     0      0   0      0
    ##   flying    13    5      6        2     2        0    5      2     2     6      2   2      0
    ##   ghost      0    2      3        1     0        0    4      0    13     4      0   1      0
    ##   grass      0    4      3        0     5        0    0      0     0    42      0   2      0
    ##   ground     1    3      6        1     0        0    2      0     5     1     17   3      0
    ##   ice        0    2      1        0     0        0    0      0     0     0      0  13      0
    ##   normal     0    1      1        2     4        2    2     26     0     2      1   0     69
    ##   poison    12    3      3        1     0        0    2      0     3    14      2   0      0
    ##   psychic    0    2      2        0     7        0    0      0     0     0      0   3      0
    ##   rock       5    1      2        0     2        0    3      0     0     2      0   2      0
    ##   steel      0    2      2        4     3        0    1      0     0     3      0   0      0
    ##   water      0    4      3        2     4        0    0      0     0     3      0   7      0
    ##   Sum       53   51     51       49    52       29   61     29    25    85     22  37     69
    ##           
    ##            poison psychic rock steel water Sum
    ##   bug           0       2    0     5     5  49
    ##   dark          0       0    0     0     0  14
    ##   dragon        0       0    0     0     0  17
    ##   electric      0       0    0     0     0  38
    ##   fairy         0       0    0     0     0  18
    ##   fighting      2       3    1     2     1  56
    ##   fire          0       2    0     0     1  40
    ##   flying        3       6    3     3     8  70
    ##   ghost         0       2    0     2     2  34
    ##   grass         0       4    0     0     0  60
    ##   ground        0       2    9     2     9  61
    ##   ice           0       0    0     0     0  16
    ##   normal        0       2    0     0     1 113
    ##   poison       16       0    1     0     6  63
    ##   psychic       0      35    0     0     0  49
    ##   rock          0       2   12     7    11  49
    ##   steel         0       7    0     9     1  32
    ##   water         0       5    0     0    65  93
    ##   Sum          21      72   26    30   110 872

Here we can see what types of Pokemon are most and least prevalent.
Something to note is that while most of the Pokemon only take on one
Pokemon type (eg Water-Water or Electric-Electric types), there are some
types that clearly are very compatible, like Flying and Bug type pokemon
or Steel and Psychic type Pokemon. There are some unexpected results,
like Ice-Water combination Pokemon do not seem to be a thing despite ice
being made of water and water being the most prevalent Pokemon type.

### Exploring Generations

##### Is there a power creep between generations of pokemon?

``` r
Pokemon_Gen_Plot <- ggplot(data = Pokemon_Generation, aes(x = Generation)) +
  geom_bar(aes(fill = Generation)) +
  labs(title = "Number of Pokemon Per Generation", x = "First Gen Appearance",
       y = "Pokemon Counts of Unique Species") +
  theme(axis.text.x=element_text(angle=45))
Pokemon_Gen_Plot
```

![](../images/unnamed-chunk-15-1.png)<!-- -->

So we can see that the Generations with the most Pokemon cohorts is
Generation I and Generation V, both which have about 150 Pokemon added
for each game. Generation VI is the smallest group of new Pokemon, only
adding about 75 more. We should expect that there should be proportional
representation of generally strong and generally weak Pokemon in each
group. That means we should expect about twice as many strong and weak
Pokemon in Generations I and V than in Generation VI, and all the other
Generations should fall somewhere between them.

``` r
Pokemon_Gen_Plot <- ggplot(data = Pokemon_Type_Stats, aes(x = TypeCat)) +
  geom_bar(aes(fill = TypeCat)) +
  labs(title = "Pokemon Base Stat Categories", x = "First Gen Appearance",
       y = "Pokemon Species Counts", fill = "Cumulative Base Stats") +
  facet_wrap(vars(Generation)) +
  theme(axis.text.x=element_text(angle=45))
Pokemon_Gen_Plot
```

![](../images/unnamed-chunk-16-1.png)<!-- -->

``` r
table(Pokemon_Type_Stats$Generation, Pokemon_Type_Stats$TypeCat)
```

    ##                  
    ##                   poor fair good great
    ##   generation-i      40   41   44    26
    ##   generation-ii     26   31   24    19
    ##   generation-iii    41   35   38    20
    ##   generation-iv     20   24   23    37
    ##   generation-v      39   37   43    30
    ##   generation-vi     16   17   17    18
    ##   generation-vii    20   14   19    30
    ##   generation-viii   24   11   22    26

While there clearly isn’t the same proportion of poor, fair, good, and
great Pokemon added to each generations, it does not seem that there is
any pattern between the Pokemon’s total base stats and in what
generation they were added. Generation I, II, Generation III do seem to
lack great Pokemon, but so does Generation V. The later generations have
more “great” Pokemon than other categories of Pokemon with “poor”,
“fair”, and “good” base stats, but they don’t actually seem to have more
“great” Pokemon than the other generations. All of the Generations have
somewhere between 18 and 37 “great” Pokemon. Because these a categorical
variables as well, there is no quantify how much better Generation IV
Pokemon are than say Generation II. In other words, Generation IV could
have most of their great Pokemon, just barely in the upper quantile of
the total\_stats group.

``` r
# Creating a function to return the first quantile of a column
quant1 <- function(col){
  quant <- quantile(col)
  return(quant[2])
}

# Creating a function to return the third quantile of a column
quant3 <- function(col){
  quant <- quantile(col)
  return(quant[4])
}

# Creating the 5 basic summary stats - min, quantile 1, mean, 
# quantile 3, and max - for the Pokemon Types 
Summary_total_stats <- Pokemon_Type_Stats %>% group_by(Generation) %>%
  summarise(min_total_stats = min(total_stats),
            q1_total_stats = round(quant1(total_stats)),
            avg_total_stats = round(mean(total_stats)), 
            q3_total_stats = round(quant3(total_stats)),
            max_total_stats = max(total_stats))
Summary_total_stats
```

Here we have the spread of the data of the total\_stats for each
generation of game. I do think that the max of Generation IV is
surprisingly high at 720, while all the other maximum total\_stats for
each generation is either 680 or 690. Generation IV also has the
strongest “weakest” Pokemon. The lowest total\_stat for Generation IV is
255, while the next closes two are 200. The absolute lowest total\_stat
score comes from Generation VIII, taking on a value of 180. All the
averages of the total\_stats hang around 400 to 450, with the highest
total\_stats coming from Generation VII and Generation IV, at 452 and
442, respectively. Clearly, Generation IV has some of the strongest
Pokemon, based on total\_stats. This does not support the idea that
Pokemon have gotten progressively stronger as the franchise has
continued making games.

``` r
Stat_Boxplot <- ggplot(data = Pokemon_Stats) +
  geom_boxplot(mapping = aes(x = total_stats, y = Generation, color = Generation)) +
  coord_flip() +
  theme(axis.text.x=element_text(angle=45))
Stat_Boxplot
```

![](../images/unnamed-chunk-18-1.png)<!-- -->

This box plot graphically mostly shows what the previous table
represented numerically, but here we have the median instead of the
mean. I do think it is again clear that Generation IV may have the
“best” group of Pokemon based on total stats. Generations IV’s median is
equal to most of the other generations third quartiles. Generation VII
and Generation VIII also have a slightly higher median than the other
generations, but they do not exceed the third quartiles of the other
generations. I think it is worth pointing out that Generation I, II,
III, V, and VI all have nearly the same median. Generation V also have a
very short lower quantile tail indicating that it’s probably has fewer
“poor” Pokemon than it would have if the distributions of total stats
were proportional.

``` r
Stat_Hist <- ggplot(data = Pokemon_Stats)+
  geom_histogram(mapping = aes(x = total_stats)) +
  facet_wrap(vars(Generation))
Stat_Hist
```

    ## `stat_bin()` using `bins = 30`. Pick better value with `binwidth`.

![](../images/unnamed-chunk-19-1.png)<!-- -->

Looking at these histograms, we can most clearly see that there is
little pattern between total base stats and the Generation of Pokemon. I
do think it’s interesting that the total stats for each generation does
seem to be bimodal or multimodal instead of a normal or uniform
distribution. In each game there does seem to be a cohort of a few
particularly strong Pokemon that are probably the legendary Pokemon of
each generation. There also seems to be a cohort of weak Pokemon of each
generation. In later generations, these would probably be considered the
‘baby’ evolutions of Pokemon that you can hatch from eggs.

I don’t think we can definitively say that the base stats overall
increased with each generation, but if I did have to choose a “great” or
strong Pokemon, I would pick from Generation IV. It seems to have the
highest instance of “great” Pokemon compared to the rest of the
generations. We didn’t find any definitive evidence that the total base
stats between Pokemon of different generations were different, but I
thought I may look to see if there was a relationship between the three
main base stats - HP, attack, and defense. I think it would make sense
that attack and defense may be inversely related since they’re opposites
of each other in a video game. The special attack and special defense is
based on the Pokemon type so like a fire-type Pokemon with a high
special attack value may be able to more easily kill an ice-type Pokemon
than another fire-type Pokemon with low special attack. Special defense
works much in the same way, but decides how strong the Pokemon is
against the Pokemon types that they receive partial damage from. I’ve
excluded those stats because they so heavily rely on Pokemon types that
there isn’t an easy way to quantify their value - it would take much
more than just a simple numeric scatterplot to explore that. I also
excluded the Speed stat which decides which Pokemon has the first move
in battle, as well as has some effect on Pokemon in-game contests.

``` r
HP_Defense <- ggplot(data = Pokemon_Stats, aes(x = hp, y = defense)) +
  geom_point(aes(color = Generation))
HP_Defense
```

![](../images/unnamed-chunk-20-1.png)<!-- -->

``` r
HP_Attack <- ggplot(data = Pokemon_Stats, aes(x = hp, y = attack)) +
  geom_point(aes(color = Generation))
HP_Attack
```

![](../images/unnamed-chunk-20-2.png)<!-- -->

``` r
Defense_Attack <- ggplot(data = Pokemon_Stats, aes(x = defense, y = attack)) +
  geom_point(aes(color = Generation))
Defense_Attack
```

![](../images/unnamed-chunk-20-3.png)<!-- -->

All three of these scatterplots show a vague positive correlations
between the HP, attack, and defense stats, which I find surprisingly. At
the very least, I thought there would be an inverse relationship between
attack and defense, but that plot shows a stronger correlation than that
of defense and HP. The strongest positive linear relationship is between
attack and HP. There also is a clear trumpeting pattern in each of these
plots, with the most severe occurring between attack and defense. I
definitely don’t think any of the plots show a significant difference
between the generations and the pattern of the scatterplots. This could
be due to the number of points that we have plotted on each graph, 898.
The number of points may obscure any patterns that may be visible
between the scatterplots. Unfortunately, ggplot2’s shape attribute only
will count up to six unique values, so I could not make each generation
a separate shape.
