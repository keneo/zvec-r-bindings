FROM rocker/r-ver:4.4

# Layer 1: system deps (rarely changes)
RUN apt-get update -qq && \
    apt-get install -y -q python3-venv python3-dev python3-pip && \
    rm -rf /var/lib/apt/lists/*

RUN Rscript -e "install.packages('remotes', repos='https://cloud.r-project.org', quiet=TRUE)"

# Layer 2: copy DESCRIPTION files (changes when deps change)
COPY rzvec/DESCRIPTION  /tmp/rzvec-desc/DESCRIPTION
COPY rszvec/DESCRIPTION /tmp/rszvec-desc/DESCRIPTION

# Layer 3: install R dependencies from DESCRIPTION files (rebuilds only when deps change)
RUN Rscript -e "remotes::install_deps('/tmp/rzvec-desc',  dependencies=TRUE, quiet=TRUE)" && \
    Rscript -e "remotes::install_deps('/tmp/rszvec-desc', dependencies=TRUE, quiet=TRUE)"

# Layer 4: Python venv at the path rzvec_install() expects
# tools::R_user_dir("rzvec", "cache") resolves to /root/.cache/R/rzvec for root
ENV RZVEC_VENV=/root/.cache/R/rzvec/rzvec-venv
RUN python3 -m venv "$RZVEC_VENV" && \
    "$RZVEC_VENV/bin/pip" install --no-cache-dir zvec
