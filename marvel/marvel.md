---
title: "Marvel vs DC Comics"
subtitle: "Une comparaison des résultats au Box Office avec {ggplot2} et Tableau Public."
author: "Felix Luginbuhl"
date: "19/06/2017"
output:
  html_document:
    keep_md: yes
  github_document: default
---



Les adaptations de superhéros brillent aux Box Office. Les films *Marvel's The Avengers* et *Avengers: Age of Ultron* sont ainsi les 5ème et 7ème plus gros succès au Box Office international. L'envie m'a prise de comparer les succès commerciaux des deux sociétés qui se partagent un quasi monopole des superhéros: Marvel Studios et DC Entertainment.

Dans cet article, nous répondrons à trois questions:

1.  Quelle franchise a le plus d'adaptations au cinéma?
2.  Quelle franchise a engendré les films les plus rentables?
3.  Comment se répartissent les adaptations des franchises depuis 40 ans?

## Les données

Le site Box Office Mojo (filiale du site IMDb, lui-même propriété d´Amazon) propose deux tableaux des recettes des adaptations cinématographiques des franchises DC Comics ([ici](http://www.boxofficemojo.com/franchises/chart/?id=dccomics.htm)) et de Marvel Comics ([là](http://www.boxofficemojo.com/franchises/chart/?id=marvelcomics.htm)).

Ces données nous intéressent car Box Office Mojo calcule aussi les recettes en ajustant le prix du billet à l'inflation. Sans cet ajustement à l'inflation, il ne serait pas pertinent de comparer les revenus commerciaux des films des années 1980 à ceux des années 2010. Malheureusement, les données ajustées n'existent que pour le Box Office américain. Nous nous en contenterons.

Un simple copier-coller dans LibreOffice Calc permet de sauvegarder rapidement le tableau "Adjusted for Ticket Price Inflation" au format CSV. D'autres bloggeurs se sont amusés à importer les données directement depuis la console R ([ici](http://jkunst.com/r/viz-gross-income-movies/)) ou à partir d'un article de Wikipédia qui reprend les données du site Box Office Mojo ([là](http://opiateforthemass.es/articles/james-bond-film-ratings/)).

## Nombre de films adaptés par franchise

Avec le package {waffle}, comparons le nombre de films adaptés par franchise.


```r
library(tidyverse)
library(waffle)

dc_comics <- read_csv("input/dc_comics.csv") %>%
  mutate(Franchise = "DC Comics")

marvel <- read_csv("input/marvel.csv") %>%
  mutate(Franchise = "Marvel")

nb_films <- c("Marvel Comics (45)" = nrow(marvel), "DC Comics (29)" = nrow(dc_comics))

waffle(nb_films, row = 5, legend_pos = "bottom",
       title = "Nombre d'adaptations par franchise",
       colors = c("red3", "blue3"))
```

![](marvel_files/figure-html/waffle-1.png)<!-- -->

Le nombre d´adaptations de la franchise Marvel (45 films) est 1.5 fois supérieur à celle de DC Comics (29 films).

## Revenu total et médian par franchise

Voyons maintenant les recettes totales par franchise. Commençons par joindre les deux bases de données et faire un peu de nettoyage.


```r
library(lubridate)

df <- full_join(dc_comics, marvel) %>%
  mutate(Release = lubridate::mdy(Release)) %>%
  rename("Title" = "Title (click to view)",
         "AdjGross" = "Adjusted Gross",
         "UnadjGross" = "Unadjusted Gross") %>%
  mutate(AdjGross = str_remove_all(AdjGross, "[\\$|\\,]"), #enlever $ and ,
         UnadjGross = str_remove_all(UnadjGross, "[\\$|\\,]"),
         AdjGross = as.numeric(AdjGross)/1000000, # en millions de dollars
         UnadjGross = as.numeric(UnadjGross)/1000000) %>%
  select(-Rank)

print(df)
```

```
## # A tibble: 74 x 6
##    Title                    Studio AdjGross UnadjGross Release    Franchise
##    <chr>                    <chr>     <dbl>      <dbl> <date>     <chr>    
##  1 The Dark Knight          WB         657.       533. 2008-07-18 DC Comics
##  2 Batman                   WB         557.       251. 1989-06-23 DC Comics
##  3 The Dark Knight Rises    WB         509.       448. 2012-07-20 DC Comics
##  4 Superman                 WB         507.       134. 1978-12-15 DC Comics
##  5 Batman Forever           WB         374.       184. 1995-06-16 DC Comics
##  6 Batman Returns           WB         347.       163. 1992-06-19 DC Comics
##  7 Superman II              WB         344.       108. 1981-06-19 DC Comics
##  8 Batman v Superman: Dawn… WB         338.       330. 2016-03-25 DC Comics
##  9 Suicide Squad            WB         338.       325. 2016-08-05 DC Comics
## 10 Man of Steel             WB         307.       291. 2013-06-14 DC Comics
## # … with 64 more rows
```

A présent, calculons les recettes totales et médianes par franchise


```r
library(knitr)

df %>%
  group_by(Franchise) %>%
  summarise(sumGross = round(sum(AdjGross), 2)) %>%
  knitr::kable()
```



Franchise    sumGross
----------  ---------
DC Comics     6400.78
Marvel       11155.90


```r
df %>%
  group_by(Franchise) %>%
  summarise(medianGross = round(median(AdjGross), 2)) %>%
  knitr::kable()
```



Franchise    medianGross
----------  ------------
DC Comics         175.75
Marvel            215.37

Le revenu total du Box Office américain des adaptations de Marvel (11.15 milliards de dollars) est supérieur à celui de DC Comics (6.4 milliards). Il en est de même pour ses recettes médianes (215.3 millions contre 175.7 millions de dollars).

## Top 10 des films les plus rentables

Créons un tableau des dix adaptations de superhéros de bande dessinées les plus rentables aux États-Unis.


```r
df %>%
  select(Title, AdjGross, Franchise, Release) %>%
  arrange(desc(AdjGross)) %>%
  head(n = 10L) %>%
  knitr::kable()
```



Title                      AdjGross  Franchise   Release    
------------------------  ---------  ----------  -----------
Marvel's The Avengers      679.6299  Marvel      2012-05-04 
The Dark Knight            656.5381  DC Comics   2008-07-18 
Spider-Man                 614.2452  Marvel      2002-05-03 
Batman                     556.5188  DC Comics   1989-06-23 
Spider-Man 2               531.8033  Marvel      2004-06-30 
The Dark Knight Rises      509.0232  DC Comics   2012-07-20 
Superman                   507.0458  DC Comics   1978-12-15 
Avengers: Age of Ultron    473.1779  Marvel      2015-05-01 
Spider-Man 3               432.4023  Marvel      2007-05-04 
Iron Man 3                 431.4658  Marvel      2013-05-03 

Six des dix films les plus rentables proviennent de la franchise Marvel. L'ajustement du prix du ticket à l'inflation révèle que les films *Batman* (1989) et *Superman* (1978) ont généré plus de recettes que *Avengers: Age of Ultron* (2015) sur le marché américain.

## Visualisation de l'ensemble des adaptations

Mais qu'en est-il des autres films? Et qu'en est-il de la répartition des films au cours des années? Une simple fonction nous aidera a visualiser la prise en compte ou l'absence de l'ajustement des recettes à l'inflation.


```r
library(scales)

plot <- function(data, gross){
  data %>%
    ggplot(aes(x = Release, y = gross)) +
    geom_label(aes(label = Title, color = Franchise), 
               size = 2.5, alpha = 0.6) +
    scale_x_date(breaks = date_breaks("5 years"),
                 labels = date_format("%Y")) +
    scale_y_continuous(labels = dollar) +
    scale_color_manual(values = c("blue3", "red3")) +
    theme_bw() +
    theme(plot.title = element_text(face = "bold"),
          legend.position = "none") +
    labs(x = "", y = "millions de dollars",
         caption = "@lgnbhl | Source: boxofficemojo.com" )
  }

plot(data = df, gross = df$AdjGross) +
  labs(title = "Marvel vs. DC Comics",
       subtitle = "Box Office américain (revenu ajusté à l'inflation)")
```

![](marvel_files/figure-html/plot_marvel_dc_comics_adj-1.png)<!-- -->

La franchise Marvel semble avoir pris le dessus sur DC Comics depuis les années 2000. Le revenu ajusté à l'inflation révèle combien les sagas Superman et Batman ont été rentables durant les années 1980-90. C'est une surprise.

Finalement, voyons comment l'absence d'ajustement du prix du ticket à l'inflation fausse l'interprétation des données.


```r
plot(df, df$UnadjGross) +
  labs(title = "Marvel vs. DC Comics",
       subtitle = "Box Office américain (revenu non-ajusté à l'inflation)")
```

![](marvel_files/figure-html/plot_marvel_dc_comics_unadj-1.png)<!-- -->

La visualisation est fortement modifiée. Le succès commercial des sagas Superman et Batman de DC Comics des années 1980-90 est masquée.

Il suffit de modifier légèrement le script pour comparer d'autres [franchises](http://www.boxofficemojo.com/franchises/) comme Star Wars et Star Treck ou James Bond et Jason Bourne.

Cliquez sur l'image pour l'agrandir.


```r
starwars <- read_csv("input/star_wars.csv") %>%
  mutate(Franchise = "Star Wars")
startreck <- read_csv("input/star_treck.csv") %>%
  mutate(Franchise = "Star Treck")
jamesbond <- read_csv("input/james_bond.csv") %>%
  mutate(Franchise = "James Bond")
jasonbourne <- read_csv("input/jason_bourne.csv") %>%
  mutate(Franchise = "Jason Bourne")

df_starwars_startreck <- full_join(starwars, startreck) %>%
  mutate(Release = lubridate::mdy(Release)) %>%
  rename("Title" = "Title (click to view)",
         "AdjGross" = "Adjusted Gross",
         "UnadjGross" = "Unadjusted Gross") %>%
  mutate(AdjGross = str_remove_all(AdjGross, "[\\$|\\,]"), #enlever $ and ,
         UnadjGross = str_remove_all(UnadjGross, "[\\$|\\,]"),
         AdjGross = as.numeric(AdjGross)/1000000, # en millions de dollars
         UnadjGross = as.numeric(UnadjGross)/1000000) %>%
  select(-Rank)

df_jamesbond_jasonbourne <- full_join(jamesbond, jasonbourne) %>%
  mutate(Release = lubridate::mdy(Release)) %>%
  rename("Title" = "Title (click to view)",
         "AdjGross" = "Adjusted Gross",
         "UnadjGross" = "Unadjusted Gross") %>%
  mutate(AdjGross = str_remove_all(AdjGross, "[\\$|\\,]"), #enlever $ and ,
         UnadjGross = str_remove_all(UnadjGross, "[\\$|\\,]"),
         AdjGross = as.numeric(AdjGross)/1000000, # en millions de dollars
         UnadjGross = as.numeric(UnadjGross)/1000000) %>%
  select(-Rank)
```


```r
plot(df_starwars_startreck, df_starwars_startreck$AdjGross) +
  labs(title = "Star Wars vs. Star Treck",
       subtitle = "Box Office américain (revenu ajusté à l'inflation)")
```

![](marvel_files/figure-html/plot_starwars_startreck-1.png)<!-- -->


```r
plot(df_jamesbond_jasonbourne, df_jamesbond_jasonbourne$AdjGross) +
  labs(title = "James Bond vs. Jason Bourne",
       subtitle = "Box Office américain (revenu ajusté à l'inflation)")
```

![](marvel_files/figure-html/plot_jamesbond_jasonbourne-1.png)<!-- -->


## Visualisation interactive

[Tableau public](https://www.tableau.com/) permet de créer des visualisations interactives. Je me suis amusé à l'utiliser avec les données créées dans cet article (en anglais).

<p><div class='tableauPlaceholder' id='viz1522829883428' style='position: relative'><noscript><a href='#'><img alt='Comparing Movie Franchises SuccessUS Box Office (Gross ajusted to inflation) ' src='https:&#47;&#47;public.tableau.com&#47;static&#47;images&#47;Da&#47;Data_MarvelDC&#47;ComparingMovieFranchisesSuccess&#47;1_rss.png' style='border: none' /></a></noscript><object class='tableauViz'  style='display:none;'><param name='host_url' value='https%3A%2F%2Fpublic.tableau.com%2F' /> <param name='embed_code_version' value='3' /> <param name='site_root' value='' /><param name='name' value='Data_MarvelDC&#47;ComparingMovieFranchisesSuccess' /><param name='tabs' value='no' /><param name='toolbar' value='yes' /><param name='static_image' value='https:&#47;&#47;public.tableau.com&#47;static&#47;images&#47;Da&#47;Data_MarvelDC&#47;ComparingMovieFranchisesSuccess&#47;1.png' /> <param name='animate_transition' value='yes' /><param name='display_static_image' value='yes' /><param name='display_spinner' value='yes' /><param name='display_overlay' value='yes' /><param name='display_count' value='yes' /></object></div>                <script type='text/javascript'>                    var divElement = document.getElementById('viz1522829883428');                    var vizElement = divElement.getElementsByTagName('object')[0];                    vizElement.style.width='100%';vizElement.style.height=(divElement.offsetWidth*0.75)+'px';                    var scriptElement = document.createElement('script');                    scriptElement.src = 'https://public.tableau.com/javascripts/api/viz_v1.js';                    vizElement.parentNode.insertBefore(scriptElement, vizElement);                </script></p>

## Conclusion

Notre analyse a montré que la franchise Marvel fait mieux que sa rivale DC Comics au Box Office américain à tous les niveaux: ses recettes individuelles, totales et médianes sont plus élevées, tout comme son nombre d'adaptations.

Mais dans le 7ème art, comme ailleurs, popularité ne rime pas toujours avec qualité.

## Références

D'autres bloggeurs ont étudié la base de donnée de Box Office Mojo:

- Joshua Kunst (2016, mars). [Visualizing Movies Gross Income]("http://jkunst.com/r/viz-gross-income-movies).
- Christoph Safferling (2015, 14 novembre). [James Bond movies]("http://opiateforthemass.es/articles/james-bond-film-ratings/).
