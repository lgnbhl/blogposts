## Build Docker binder_image

## TO RUN LOCALLY:
## docker login registry.gitlab.com
## docker build -t registry.gitlab.com/lgnbhl/blogposts/binder_image .
## docker push registry.gitlab.com/lgnbhl/blogposts/binder_image

## Reference: https://lumao.ch/post/gitlab-private-registry-docker/

FROM rocker/binder:latest

COPY /install_packages.R /install_packages.R
RUN Rscript /install_packages.R
