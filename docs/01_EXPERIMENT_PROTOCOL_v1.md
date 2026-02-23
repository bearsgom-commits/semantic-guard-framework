# Semantic-Guard Experiment Protocol v1

## Research Assumption
This study assumes a high-security battle management environment.
Original documents are not stored.
Only semantic embeddings and document identifiers are maintained.

## Fixed Configuration
- Model: intfloat/multilingual-e5-base
- Seeds: {7,13,42}
- Eps sweep: {0,2,4,8,16,32,64}
- Index: HNSW (M=32, efConstruction=200, efSearch=128)
- Normalize: True

## 14-Step Experimental Procedure
1. Environment fixation
2. Dataset preparation
3. Dataset loop
4. Seed loop
5. Embedding generation
6. Guard transformation (including eps=0)
7. Index construction
8. Retrieval evaluation
9. Privacy evaluation
10. Seed aggregation
11. Dataset-level statistics
12. Cross-dataset comparison
13. Qualitative transition analysis
14. Reproducibility verification

## Output Artifacts
See DIRECTORY_SPEC.md