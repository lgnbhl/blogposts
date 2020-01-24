## Build binder-blogposts images

FROM rocker/binder:latest

## copy files
COPY /install_packages.R /install_packages.R

## Run an install.R script, if it exists.
RUN Rscript /install_packages.R
