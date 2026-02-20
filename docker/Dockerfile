FROM rocker/r-ver:4.4

RUN apt-get update -qq && \
    apt-get install -y -q python3-venv python3-dev python3-pip && \
    rm -rf /var/lib/apt/lists/*

RUN Rscript -e "install.packages('remotes', repos='https://cloud.r-project.org', quiet=TRUE)"
