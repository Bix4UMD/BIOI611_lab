# BIOI611_lab


Lab Note for BIOI611: https://bix4umd.github.io/BIOI611_lab/

## Editing the Basic Linux lesson

The source for the main lesson is `docs/basic_linux.ipynb`. Its Markdown cells
contain terminal instructions; students copy the Bash examples into Zaratan Shell
Access. Do not execute the lesson as Python notebook cells. Keeping the terminal
examples in Markdown also avoids publishing notebook-only `%%bash` prefixes or
stale account-specific outputs.

The optional material is in `docs/basic_linux_optional.md`. Small synthetic data
and the downloadable Slurm script live in `docs/assets/basic_linux/`. The main
lesson also creates these files directly in the terminal so its setup works
before publication or without downloads. Keep the inline file-creation examples
and downloadable copies identical when changing the data or script.

The GitHub Actions workflow converts notebooks to Markdown before building the
site. Edit the notebook, not its generated `basic_linux.md` file. To preview the
whole site in a Python environment with `mkdocs-material` and `nbconvert` installed:

```bash
find docs -name '*.ipynb' -not -path '*/.ipynb_checkpoints/*' \
    -not -name 'BIOI611_scRNA_res0.1.ipynb' \
    -exec jupyter nbconvert --to markdown {} \;
mkdocs serve -f mkdocs.yaml
```

The excluded legacy notebook is currently empty and is not used in the site navigation.
Notebook conversion does not execute cluster commands. Generated Markdown,
notebook image directories, and the `site/` build directory are preview outputs;
do not commit them. Before publishing lesson changes, check the practice dataset
answers (3 FASTA records and 2 genes passing both count thresholds), inspect the
rendered page, and test the batch example using a student allocation on Zaratan.
