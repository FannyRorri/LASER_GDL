# Locality-Aware Graph-Rewiring in GNNs

<img src="https://i.imgur.com/QUFyYPz.png" align="right" width="400" style="background-color:white;"/>

In this repository, we release the code required to replicate and expand upon our results in our work: `Locality-Aware Graph-Rewiring in GNNs`. We release our work under the MIT license.

> DISCLAIMER:
The baseline results on LRGB are outdated as others has found that the original models were heavily undertuned. Please see [this work](https://arxiv.org/abs/2309.00367) for more details. As a consequence, we heavily encourage not using this repository as is, but rather running using the updated version of LRGB. As the main author is now working on different research, this repository is now not maintained anymore. 

The core of the functionality of LASER may be found in the `laser/rewiring` directory, with the details being described in the paper and in the docs within the code.

## Environment for LASER with Conda
<!-- We recommend building the environment through `Conda`. 
```bash
conda create -n laser python=3.9
conda activate laser

conda install pytorch=1.9 torchvision torchaudio -c pytorch -c nvidia
conda install pyg=2.0.2 -c pyg -c conda-forge
conda install pandas scikit-learn

# RDKit is required for OGB-LSC PCQM4Mv2 and datasets derived from it.  
conda install openbabel fsspec rdkit -c conda-forge

# Check https://www.dgl.ai/pages/start.html to install DGL based on your CUDA requirements
pip install dgl-cu111 dglgo -f https://data.dgl.ai/wheels/repo.html

pip install performer-pytorch --no-deps
pip install torchmetrics==0.7.2
pip install ogb
pip install wandb
pip install torch_geometric==2.0.2 pytorch_lightning yacs torch_scatter torch_sparse numba pytest

conda clean --all
``` -->


#### ✅ 1. Create Clean Environment

``` bash
conda create -n laser python=3.9 -y
conda activate laser
```

#### ✅ 2. Install PyTorch + CUDA (Correct Binary Pair)

``` bash
conda install pytorch=1.9.1 torchvision=0.10.1 torchaudio=0.9.1 cudatoolkit=11.1 \
  -c pytorch -c nvidia -y
```

#### ✅ 3. Core Scientific Stack

``` bash
conda install numpy=1.24.3 scipy scikit-learn pandas networkx -c conda-forge -y
```

#### ✅ 4. RDKit + OGB Dependencies

``` bash
conda install openbabel rdkit fsspec -c conda-forge -y
pip install ogb
```

#### ✅ 5. PyTorch Geometric + CUDA Extensions (Matched to Torch 1.9.1)

``` bash
conda install pyg=2.0.2 pytorch-scatter=2.0.9 pytorch-sparse=0.6.12 \
  pytorch-cluster=1.5.9 pytorch-spline-conv=1.2.1 \
  -c pyg -c conda-forge -y
```

#### ✅ 6. DGL (CUDA 11.1 Build)

``` bash
pip install dgl-cu111 dglgo -f https://data.dgl.ai/wheels/repo.html
```

#### ✅ 7. LASER-Specific Python Packages

``` bash
pip install performer-pytorch==1.1.4
pip install local-attention==1.11.2
pip install torchmetrics==0.7.2
pip install pytorch-lightning==1.6.5.post0
pip install yacs wandb einops hyper-connections
```

#### ✅ 8. JIT + Rewiring Dependencies

``` bash
conda install numba llvmlite ninja -c conda-forge -y
```

#### ✅ 9. Development & Testing Tools

``` bash
pip install pytest autopep8 rich typer
```




### Running LASER
The configuration files may be found in `/configs`, while utility running scripts may be found in `/run`. Here are some examples: 
```bash
conda activate laser

# Run automated tests
pytest . 

# Running LASER on PCQM-Contact
python main.py --cfg configs/Contact-laser/pcqm-contact-GCN-laserglobal.yaml wandb.use False

# Running the LASER ablation study on Peptides-func
bash run/run_peptides_laser_ablation_func.sh

# Running the SAGE results on Peptides
bash run/run_sage_lrgb.sh

# Running the LASER TUDatasets results (warning that there is some stochasticity in the results)
bash run/run_tudataset_baselines.sh
bash run/run_tudataset_laser.sh
```
We note that for the TUDatasets experiments, as discussed in the paper, there is a lot of stochasticity which makes reproducing the results less reliable. This is instead not the case for the LRGB experiments.

## Acknowledgments
In order to accurately replicate part of the baseline results, our code builds upon the [Long-Range Graph Benchmark (LRGB) repository](https://github.com/vijaydwivedi75/lrgb). We additionally borrow the implementations of [First Order Spectral Rewiring (FOSR)](https://github.com/kedar2/FoSR) and [Stochastic Discrete Ricci Flow (SDRF)](https://github.com/jctops/understanding-oversquashing) from their respective authors.
