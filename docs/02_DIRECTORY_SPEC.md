# Directory Specification

## Local (Not committed)
artifacts/<dataset>/<model>/seed<k>/L<L>_a<alpha>_eps<e>/
runs/<dataset>/seed<k>/eps<e>/

## Committed (GitHub)
results/summary/
  dataset_summary_<dataset>.csv
  summary_all_datasets.csv
  fig_tradeoff.png

## Audit
runs/audit/run_meta.jsonl