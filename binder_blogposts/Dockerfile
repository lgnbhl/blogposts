## Build Docker binder_blogposts

## TO RUN LOCALLY:
## docker login registry.gitlab.com # only if the project is private
## docker build -t registry.gitlab.com/lgnbhl/blogposts/binder_blogposts .
## docker push registry.gitlab.com/lgnbhl/blogposts/binder_blogposts

## Reference: https://lumao.ch/post/gitlab-private-registry-docker/

FROM rocker/binder:latest

COPY /install_packages.R /install_packages.R
RUN Rscript /install_packages.R
