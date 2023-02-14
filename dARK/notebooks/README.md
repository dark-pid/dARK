# Documentation

- files : detail

## configure

## dARK Benchmarking
jupyter nbconvert dark_benchmark_setup.ipynb dark_benchmark.ipynb --to script

jupyter nbconvert dark_benchmark_abstract.ipynb dark_benchmark_nopayload.ipynb --to script

$ cd /home/thiagonobrega/dark/dARK
thiagonobrega@dev-seois:~/dark/dARK$ time python3 notebooks/evaluation/01_basic/dark_benchmark_abstract.py | tee saida_abstract_00001.log


## dARK Example

(web3) thiagonobrega@dev-seois:~/dark/dARK$ pwd
/home/thiagonobrega/dark/dARK
(web3) thiagonobrega@dev-seois:~/dark/dARK$ python3 notebooks/dark_benchmark.py
## Dspace Importer