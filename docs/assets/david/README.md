# DAVID worked-example assets

These files support `docs/BIOI611_DAVID.ipynb` and were prepared from
`BIOI_bulkRNAseq_SE_DESeq2_res_filter.xlsx` (source SHA-256
`4b7e7794fbb738a0d39be34da95168efa6f617e2c8e0a2f43c545bdb4dfd5012`).
The source workbook was supplied separately and is not duplicated here.

## Foreground and background contracts

- Foreground: unique WormBase IDs with `log2FoldChange > 2` and `padj < 0.05`.
  Count: 1,039. SHA-256:
  `a18bd43b7f87075cc00fd4dba350340a8223621d80a307f5f5d0f5be45a0ae16`.
- Background: unique WormBase IDs with non-missing `padj`, because these genes
  were eligible for the adjusted-P foreground rule. Count: 18,709. SHA-256:
  `aa1fc55d23133ad24670017f77cf58ab5f93030b9df91cacb55371e6b89c09bc`.
- Every foreground ID is present in the background. Both lists contain one ID
  per line, no header, no duplicates, and only IDs matching
  `WBGene[0-9]{8}`.
- The source workbook alone does not identify why a gene has `padj=NA`; do not
  attribute those missing values to a particular DESeq2 filtering mechanism.

## DAVID snapshot and mapping QC

Screenshots were captured on 2026-11-03 using the DAVID 2025 system release
(March 2026) and DAVID Knowledgebase v2026_2 (released 2026-10-06).

- Foreground: 1,039/1,039 submitted identifiers mapped (100%).
- Background: 18,702/18,709 submitted identifiers mapped (99.96%); seven were
  unmapped in this Knowledgebase snapshot. DAVID returned 18,703 mapping rows
  because `WBGene00000464` mapped to two DAVID genes. Conversely,
  `WBGene00022661` and `WBGene00022662` collapsed to the same DAVID gene
  (`191228`). After de-duplication, the effective population is 18,702 DAVID
  genes.
- Results use the custom background named
  `DESeq2-tested genes (padj not NA; n=18709)`. The `n=18709` in that name is
  the submitted-ID count, not the effective DAVID-gene population.

The `*_raw.png` files are unannotated browser captures. The corresponding SVG
files add numbered, editable callouts. The self-contained `*_annotated.png`
renders are embedded in the notebook so that both Colab and the course site
display the screenshot layer reliably. Because DAVID data and interfaces
change, regenerate and re-check the mapping counts and results before a future
course release.
