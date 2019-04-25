---
title: "James Bond Tourism"
subtitle: "Mapping and comparing 007 travel locations of the movie franchise."
author: "Felix Luginbuhl"
date: "24/08/2017"
output:
  html_document:
    keep_md: yes
  github_document: default
---



![](https://raw.githubusercontent.com/lgnbhl/lgnbhl.github.io/master/images/image_Skyfall.jpg)

James Bond must be the most well-travelled man in the history of movies. As it is summer time, let's have a look at the 007 travel locations in the 24 films of the spy franchise with the R packages {maps}, {ggplot2} and {ggmap}.

In this article, we will answer three questions:

1.  What are the countries that James Bond has visited?
2.  Which countries has James Bond visited the most?
3.  Have mission's locations of James Bond changed over time?

## The Data

We can find on Wikipedia a full [list of James Bond film locations](https://en.wikipedia.org/wiki/List_of_James_Bond_film_locations). I copied the list on LibreOffice Calc and made some quick cleaning. For reproductivity, the data can be downloaded on my [Github repository](https://github.com/lgnbhl/lgnbhl.github.io/blob/master/images/data_bond.csv).


```r
library(tidyverse)

bond <- read_csv("https://raw.githubusercontent.com/lgnbhl/lgnbhl.github.io/master/images/data_bond.csv")

print(bond)
```

```
## # A tibble: 143 x 3
##    Film                  Location                           region        
##    <chr>                 <chr>                              <chr>         
##  1 Dr. No                MI6 headquarters in central London England       
##  2 Dr. No                Kingston                           Jamaica       
##  3 Dr. No                Crab Key                           Jamaica       
##  4 From Russia with Love Unnamed river                      United Kingdom
##  5 From Russia with Love Zagreb                             Croatia       
##  6 From Russia with Love Belgrade                           Serbia        
##  7 From Russia with Love Istanbul                           Turkey        
##  8 From Russia with Love Venice                             Italy         
##  9 Goldfinger            Stoke Park                         England       
## 10 Goldfinger            Geneva                             Switzerland   
## # … with 133 more rows
```

## Mapping Bond's worldwide missions

We can count and map all the countries visited by James Bond in the film series. The package {ggalt} gives the possibility to choose between different map projections. We selected the [Winkel Tripel projection](https://en.wikipedia.org/wiki/Winkel_tripel_projection) for mapping.


```r
library(maps)

world <- map_data("world") %>% 
  filter(region != "Antarctica")

# Renaming regions for mapping
bond <- bond %>%
  mutate(region = recode(region,
    "United Kingdom" = "UK",
    "England" = "UK",
    "United States" = "USA"
  )) 

bond_number <- bond %>%
  count(region, sort = TRUE)

library(ggalt)
library(ggthemes)

ggplot() +
  geom_map(data = world, map = world,
           aes(x = long, y = lat, map_id = region),
           fill="lightgrey", col="white", size = 0.2) +
  geom_map(data = bond_number, map = world,
           aes(map_id = region, fill = n)) +
  scale_fill_distiller(breaks = c(1, 2, 4, 6, 8, 10, 12, 14),
                       labels = c( "1", "2", "3-4", "5-6", "7-8", "9-10", "11-12", "13-14"),
                       name = "Number of visits",
                       palette = "OrRd", direction = 1,
                       guide = guide_legend(title.position = "top")) +
  ggalt::coord_proj("+proj=wintri") +
  ggthemes::theme_map() +
  theme(plot.title = element_text(size = 20, face = "bold"),
        plot.subtitle = element_text(size = 11),
        legend.position = "right",
        legend.justification = "center") +
  labs(title = "James Bond Tourism",
       subtitle = "007 locations in the movie franchise",
       caption = "Félix Luginbühl (@lgnbhl)\n Data source: Wikipedia")
```

![](bond_files/figure-html/bond_worldwide-1.png)<!-- -->

James Bond has been to the United States 13 times. But in which movies did these visits happen?


```r
bond %>%
  select(Film, region) %>%
  filter(region == "USA") %>%
  count(Film, sort = TRUE) %>%
  rename(US_visits_by_film = n)
```

```
## # A tibble: 9 x 2
##   Film                 US_visits_by_film
##   <chr>                            <int>
## 1 Goldfinger                           3
## 2 Diamonds Are Forever                 2
## 3 Live and Let Die                     2
## 4 A View to a Kill                     1
## 5 Casino Royale                        1
## 6 Licence to Kill                      1
## 7 Moonraker                            1
## 8 Thunderball                          1
## 9 You Only Live Twice                  1
```

## Locating 007 missions

In order to locate the places in the films where James Bond has been, we need to get their geolocations (latitude and longitude). The ```geocoding``` function of the package {ggmap} does the job well with the Google Maps API. We will use the loop described in the blog article of [Mitchell Craver](http://whatdothedatasay.com/2016/03/16/geocoding-addresses-in-r-with-ggmap/).

However, we face a problem. There are plenty of imaginary locations in the James Bond movies that Google Maps cannot geolocate. So for each imaginary place, we will just replace it by the name of the country. As this work has to be done manually, we selected only the movies starring the first and last actors playing James Bond: Sean Connery and Daniel Craig.

Let's begin by locating Bond's missions in movies starring Sean Connery.


```r
# Identify locations by country, otherwise imprecisions
bond_2 <- tidyr::unite(bond, loc, c(Location, region), sep = ", ", remove = FALSE)

# Selecting movies starring Sean Connery
connery <- c("Dr. No", "From Russia with Love", "Goldfinger", "Thunderball", "You Only Live Twice", "Diamonds Are Forever")
bond_connery <- filter(bond_2, Film %in% connery)

# Change imaginary locations in country names
bond_connery[18,2] <- "England" # "Shrublands Health Retreat" in "Thunderball"
bond_connery[24,2] <- "Japan" # "SPECTRE's hideout" in "You Only Live Twice"
bond_connery[25,2] <- "Norway" # "Secret CIA base" in "You Only Live Twice"
bond_connery <- bond_connery[-29,] # remove unknown country in Latin America
bond_connery[29,2] <- "South Africa" # "Unnamed location" in "Diamonds Are Forever"
bond_connery[33,2] <- "Mexico" # "Oil rig in Baja California" in "Diamonds Are Forever"

# Google Maps API
# Loop from Mitchell Craver: http://whatdothedatasay.com/2016/03/16/geocoding-addresses-in-r-with-ggmap/
library(ggmap)

# ?register_google()
# register_google(key = "KEY_HERE")

#for(i in 1:nrow(bond_connery)){
    #result <- ggmap::geocode(bond_connery$loc[i], output = "latlona", source = "google")
    #bond_connery$lon[i] <- as.numeric(result[1])
    #bond_connery$lat[i] <- as.numeric(result[2])
    #bond_connery$geoAddress[i] <- as.character(result[3])
    #Sys.sleep(1) #slow down the requests speed
    #}

# write_csv(bond_connery, "output/bond_connery.csv")
bond_connery <- read.csv("output/bond_connery.csv", header = T) # keep factor

levels(bond_connery$Film) <- c("Dr. No", "From Russia with Love", "Goldfinger", "Thunderball", "You Only Live Twice", "Diamonds Are Forever")

library(ggiraph)

g1 <- ggplot() +
  geom_map(data = world, map = world, aes(x = long, y = lat, map_id = region),
           fill = "lightgrey", col = "white", size = 0.2) +
  geom_point_interactive(data = bond_connery, aes(lon, lat, tooltip = loc), 
           color = "white", size = 3, fill= "brown1", pch = 21) +
  coord_proj("+proj=wintri") +
  theme_map() +
  labs(labs(title = "James Bond locations in movies starring Sean Connery",
            caption = "Félix Luginbühl (@lgnbhl)\n Data source: Wikipedia")) +
  theme(plot.title = element_text(size = 14, hjust = 0.5, face = "bold"),
               plot.caption = element_text(size = 8, color = "dimkgrey"))

ggiraph(print(g1))
```

<!--html_preserve--><div id="htmlwidget-b8151e4fed9ff0d181bd" style="width:672px;height:480px;" class="girafe html-widget"></div>

A nice interactive map!

And what about the locations by movie?


```r
g1 + facet_wrap(~ Film)
```

![](bond_files/figure-html/bond_connery_by_movie-1.png)<!-- -->

Let's do the same work for the James Bond movies starring Daniel Craig.


```r
craig <- c("Casino Royale", "Quantum of Solace", "Skyfall", "Spectre")
bond_craig <- filter(bond_2, Film %in% craig)

bond_craig[3,2] <- "Madagascar"
bond_craig[22,2] <- "Scotland"

#for(i in 1:nrow(bond_craig)){
  #result <- geocode(bond_craig$loc[i], output = "latlona", source = "google")
  #bond_craig$lon[i] <- as.numeric(result[1])
  #bond_craig$lat[i] <- as.numeric(result[2])
  #bond_craig$geoAddress[i] <- as.character(result[3])
  #}

# write.csv(bond_craig, "bond_craig.csv")
bond_craig <- read.csv("output/bond_craig.csv", header = T) # keep factor

levels(bond_craig$Film) <- c("Casino Royale", "Quantum of Solace", "Skyfall", "Spectre")

g2 <- ggplot() +
  geom_map(data = world, map = world, aes(x = long, y = lat, map_id = region),
           fill = "lightgrey", col = "white", size = 0.2) +
  geom_point_interactive(data = bond_craig, aes(lon, lat, tooltip = loc), 
           color = "white", size = 3, fill = "brown1", pch = 21) +
  coord_proj("+proj=wintri") +
  theme_map() +
  labs(labs(title = "James Bond locations in movies starring Daniel Craig",
            caption = "Félix Luginbühl (@lgnbhl)\n Data source: Wikipedia")) +
  theme(plot.title = element_text(size = 14, hjust = 0.5, face = "bold"),
        plot.caption = element_text(size = 8, color = "dimkgrey"))

ggiraph(print(g2))
```

<!--html_preserve--><div id="htmlwidget-b4ee90248ed92bef58e6" style="width:672px;height:480px;" class="girafe html-widget"></div>

And the locations by movie:


```r
g2 + facet_wrap(~ Film)
```

![](bond_files/figure-html/bond_craig_by_movie-1.png)<!-- -->

Comparing James Bond's locations in the first and last movies of the franchise, we can see that those starring Sean Connery are mostly in Europe and USA when those starring Daniel Craig are mostly in Latin America and Asia.

Thanks for reading. For updates of recent blog posts, [follow me on Twitter](https://twitter.com/lgnbhl).