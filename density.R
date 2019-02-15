#https://cimentadaj.github.io/blog/2018-05-25-installing-rjava-on-windows-10/installing-rjava-on-windows-10/
Sys.setenv(JAVA_HOME="C:/Program Files/Java/jdk-11.0.2/") #(JAVA_HOME PROBLEM)
library(rJava)
library(sf)
library(OpenStreetMap) 
library(tmap)
library(tmaptools)

#    [out:json][timeout:25];
# {{geocodeArea:Hamburg}}->.searchArea;
# (
#    node["amenity" = "restaurant"](area.searchArea);
#    //way["amenity" = "bar"](area.searchArea);
#    //relation["amenity" = "bar"](area.searchArea);
# );
# out body;
# >;
# out skel qt;

#    [out:json][timeout:25];
# {{geocodeArea:Hamburg}}->.searchArea;
#(
#    way["natural"="water"](area.searchArea);
#    relation["natural"="water"](area.searchArea);
# );
# out body;
# >;
# out skel qt;

# [out:json][timeout:25];
# {{geocodeArea:Hamburg}}->.searchArea;
# (
#    node["highway"="primary"](area.searchArea);
#    way["highway"="primary"](area.searchArea);
#    relation["highway"="primary"](area.searchArea);
#    node["highway"="secondary"](area.searchArea);
#    way["highway"="secondary"](area.searchArea);
#    relation["highway"="secondary"](area.searchArea);
# );
# out body;
# >;
# out skel qt;

# curl -f -o hamburg.zip --url "https://wambachers-osm.website/boundaries/exportBoundaries?cliVersion=1.0&cliKey=6f4b0380-1ef1-4cdf-ae75-0ce88e32e15a&exportAreas=land&from_AL=10&to_AL=10&exportFormat=json&union=false&selected=62782"

rm(list = ls())
viertel <- read_sf("./Hamburg_AL10.geojson")
viertel <- viertel[-36,]
bars <- read_sf("./Hamburgbars.geojson")
restaurants <- read_sf("./Hamburgrestaurants.geojson")
water <- read_sf("./Water.geojson")
dulsberg <- read_sf("./Dulsberg.geojson")
other <- read_sf("./AL4.geojson")
limits <- read_sf("./Limits.geojson")
parks <- read_sf("./Parks.geojson")
roads <- read_sf("./Roads.geojson")

limits <- st_transform(limits, crs = 2154)
viertel <- st_transform(viertel, crs = 2154)
restaurants <- st_transform(restaurants, crs = 2154)
water <- st_transform(water, crs = 2154)
dulsberg <- st_transform(dulsberg, crs = 2154)
other <- st_transform(other, crs = 2154)
parks <- st_transform(parks, crs = 2154)
roads <- st_transform(roads, crs = 2154)

other <- crop_shape(other, viertel)
viertel <- crop_shape(viertel, limits)
parks <- crop_shape(parks, limits)
roads <- crop_shape(roads, limits)

rest_density <- smooth_map(restaurants, 
                           bandwidth = 0.3, 
                           nlevels = 30,
                           unit = "km")

library(RColorBrewer)

pal <- brewer.pal(9, "YlOrBr")
pal[1] <- "#FFFFFF"

pdf(file = "./map.pdf", width = 80, height = 56)
tm_shape(viertel) +
    tm_borders(col = "grey20") +
    tm_text("name", col = "black", size = 4.8) +
    tm_shape(parks) +
    tm_borders(col = "grey85") +
    tm_fill(col = "chartreuse3", alpha = 0.6) +
    tm_shape(other) +
    tm_fill(col = "black") +
    tm_shape(dulsberg) +
    tm_fill(col = "grey", alpha = 0.4) +
    tm_shape(rest_density$polygons) +
    tm_fill(palette = pal, 
            col = "level", 
            alpha = 0.6) +
    tm_shape(water) +
    tm_borders(col = "grey85", alpha = 0.8) +
    tm_fill(col = "lightblue", alpha = 0.45) +
    tm_shape(roads) + 
    tm_sf(col = "red", alpha = 0.3, lty = 5, lwd = 1.2) +
    tm_style("white", 
             title = "Restaurants in Hamburg") +
    tm_layout(frame = FALSE, 
              legend.show = FALSE, 
              title.size = 16,
              inner.margins = c(0,0),
              title.position = c("left", "top"),
              fontfamily = "mono") +
    tm_credits("Source: OpenStreetMap. Geometry: Wambacher OSM Boundaries. Computed by J. Beley.",
               position = c("left", "bottom"),
               size = 6) 
dev.off()
