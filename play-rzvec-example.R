library(reticulate)
use_virtualenv(file.path(getwd(), "rzvec-venv"), required = TRUE)

library(rzvec)

schema <- collection_schema(
  "example",
  vectors = vector_schema("embedding", zvec_data_type()$VECTOR_FP32, as.integer(4))
)

col <- create_collection("/tmp/rzvec_example", schema)

col_insert(col,
  zvec_doc("doc_1", vectors = list(embedding = c(0.1, 0.2, 0.3, 0.4))),
  zvec_doc("doc_2", vectors = list(embedding = c(0.2, 0.3, 0.4, 0.1)))
)

res <- col_query(col, vector_query("embedding", vector = c(0.4, 0.3, 0.3, 0.1)), topk = 10L)

for (r in res) cat(r$id, r$score, "\n")

unlink("/tmp/rzvec_example", recursive = TRUE)
