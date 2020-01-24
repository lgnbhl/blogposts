# Install all packages used in each of my blog posts

# TO RUN:
# docker login registry.gitlab.com
# docker build -t registry.gitlab.com/lgnbhl/blogposts/install .
# docker push registry.gitlab.com/lgnbhl/blogposts


# install/load needed R packages
if (!require("pacman")) install.packages("pacman")

pacman::p_load(tidyverse, ggalt, ggiraph, ggmap, ggthemes, maps) # bond
pacman::p_load(tidyverse, DT, ggthemes, wordcloud, SnowballC, tidytext, tm, caret, h2o, rpart.plot, rsample, xgboost) # cooking
pacman::p_load(tidyverse, lubridate, dygraphs, hrbrthemes, forecast, scales, sweep, timetk) # forecasting
pacman::p_load(tidyverse, rvest, janitor, WikipediR, tidytext, countrycode, leaflet, rnaturalearth, rnaturalearthdata, htmltools) # leaflet-map
pacman::p_load(tidyverse, rvest, sf, countrycode, ggalt, ggthemes, hrbrthemes, leaflet, RColorBrewer, readxl, rnaturalearth, rnaturalearthdata, rgeos) # mapping
pacman::p_load(tidyverse, lubridate, scales, waffle) # marvel
pacman::p_load(Amelia, caret, e1071, hrbrthemes, rvest, tidytext, tidyverse, tm, xgboost) # movies
pacman::p_load(tidyverse, rvest, tidygraph, ggraph, ggforce, visNetwork) # network
pacman::p_load(broom, gvlma, countrycode, ggimage, ggthemes, plotly, pscl, readxl, reshape2, rvest, tidyverse) # olympics
pacman::p_load(tidyverse, ggthemes, scales, tidyr, tidytext, wordcloud) # orwell
pacman::p_load(tidyverse, DT, treemap, sunburstR, d3r, htmlwidgets) # pokemon
pacman::p_load(tidyverse, sf, tmap, srvyr, plotly, gganimate, quantreg, countrycode, hrbrthemes, knitr) # shdi
pacman::p_load(tidyverse, scales, colorspace, plotly, RSwissMaps, BFS) # swiss-data
pacman::p_load(tidyverse, dygraphs, ggthemes, lubridate, magick, RColorBrewer, rtweet, httpuv, scales, tidytext, xts) # tennis
