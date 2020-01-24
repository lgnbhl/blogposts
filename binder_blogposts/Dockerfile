## Build binder_blogposts images

# TO RUN LOCALLY:
# docker login registry.gitlab.com
# docker build -t registry.gitlab.com/lgnbhl/blogposts/binder_blogposts .
# docker push registry.gitlab.com/lgnbhl/blogposts/binder_blogposts

# Reference: https://lumao.ch/post/gitlab-private-registry-docker/

FROM rocker/binder:latest

## copy files
COPY /install_packages.R /install_packages.R

## Run an install.R script, if it exists.
RUN Rscript /install_packages.R
