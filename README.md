# play-zvec

R bindings for the [zvec](https://pypi.org/project/zvec/) vector database.

## Quick start

### rszvec — simplest path

```r
remotes::install_github("keneo/play-zvec/rszvec")

library(rszvec)
rszvec_install()   # one-time

col <- rszvec_open("/tmp/my_collection", dim = 4)

rszvec_add(col, "doc_1", c(0.1, 0.2, 0.3, 0.4))
rszvec_add(col, "doc_2", c(0.2, 0.3, 0.4, 0.1))

rszvec_search(col, c(0.4, 0.3, 0.3, 0.1), n = 5)
#      id score
# 1 doc_2  0.30
# 2 doc_1  0.23
```

### rzvec — full API

```r
remotes::install_github("keneo/play-zvec/rzvec")

library(rzvec)
rzvec_install()   # one-time

schema <- collection_schema(
  "my_docs",
  vectors = vector_schema("embedding", zvec_data_type()$VECTOR_FP32, 4L)
)
col <- create_collection("/tmp/my_collection", schema)

col_insert(col,
  zvec_doc("doc_1", vectors = list(embedding = c(0.1, 0.2, 0.3, 0.4))),
  zvec_doc("doc_2", vectors = list(embedding = c(0.2, 0.3, 0.4, 0.1)))
)

col_query(col, vector_query("embedding", vector = c(0.4, 0.3, 0.3, 0.1)), topk = 5L)
```

## Example scripts

| Script | Abstraction level |
|---|---|
| [`play-zvec-example.R`](play-zvec-example.R) | Raw `reticulate` + Python zvec API |
| [`play-rzvec-example.R`](play-rzvec-example.R) | `rzvec` R package |
| [`play-rszvec-example.R`](play-rszvec-example.R) | `rszvec` R package |

## Contents

| Package | Who it's for | What you get | Example |
|---|---|---|---|
| [`rzvec`](rzvec/) | R developers who want the full zvec API | Thin, idiomatic R wrappers over every zvec Python class and method | [`example`](play-rzvec-example.R) |
| [`rszvec`](rszvec/) | R developers who want minimal ceremony | 5-function API; results come back as plain `data.frame`s | [`example`](play-rszvec-example.R) |

## Platform support

Determined by the `zvec` Python package, which ships binary wheels for:

| Platform | x86_64 | arm64 |
|---|---|---|
| Linux |  ✅ | ✅ |
| macOS | — | ✅ |
| Windows | — | — |

Python 3.10, 3.11, and 3.12 are supported. Python 3.9 and earlier are not.

## Docker smoke test

The [`docker/`](docker/) folder contains the Docker image definition and R
scripts that run inside it, for validating the packages on Linux ARM64.

| File | Purpose |
|---|---|
| `docker/Dockerfile` | Base image (`rocker/r-ver:4.4` + Python deps + `remotes`) |
| `docker/test.R` | Full smoke test: installs packages from GitHub, runs end-to-end |
| `docker/test-all.R` | Installs from mounted repo, runs all 82 tests (rzvec + rszvec) |
| `docker/ci-test.R` | No-install variant used by CI after packages are pre-installed |
| `run-tests-in-docker.sh` | Builds the image if needed, then runs `test-all.R` inside it |
| `run-tests-local.sh` | Runs both test suites directly (no Docker; uses local renv + venv) |

**Run tests in Docker** (Linux, clean environment):

```bash
./run-tests-in-docker.sh
```

**Run tests locally** (faster, uses your installed packages):

```bash
./run-tests-local.sh
```

**Build the base image manually** (one-time):

```bash
docker build -t play-zvec-test docker/
```

**Run the full smoke test** (installs from GitHub each time):

```bash
docker run --rm play-zvec-test Rscript /dev/stdin < docker/test.R
```

Or mount the repo to avoid a GitHub download:

```bash
docker run --rm -v $(pwd):/repo play-zvec-test Rscript /repo/docker/test.R
```

## Acknowledgments

- [zvec](https://github.com/alibaba/zvec) - The underlying vector database
- [Alibaba Proxima](https://github.com/alibaba/proxima) - The core vector search engine

## License

MIT
