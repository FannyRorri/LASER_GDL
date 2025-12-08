import torch
import torch.nn.functional as F
import torch_geometric.transforms as T
from dataclasses import dataclass

def get_snapshot_edge_index(data, snapshot_idx): # computes exactly the edges where edge_weights == ℓ, i.e. a discrete representation of E_ℓ and hence of A_ℓ
    """
    Helper method to access the rewirings of the class. As a speedup,
    the method also saves to the data object the snapshot rewirings. This is to
    avoid recomputing the edge_index mask on every iteration which is wasteful.
    This means that subsequent accesses to the rewirings are O(1).

    Args:
        data: PyTorch Geometric data object.
        snapshot_idx: Snasphot we want the edge_index for.
    """
    if snapshot_idx == 0:
        raise ValueError("Snapshots start at 1.")

    if not hasattr(data, "edge_rewirings_store"):
        data.edge_rewirings_store = {}

    if snapshot_idx in data.edge_rewirings_store:
        return data.edge_rewirings_store[snapshot_idx]

    # if we could not find the rewiring in storage,
    # calculate it and store it
    rewiring = data.edge_index.T[data.edge_weights == snapshot_idx].T
    data.edge_rewirings_store[snapshot_idx] = rewiring

    # assert rewiring.shape[1] > 0, f"Rewiring for {snapshot_idx} not found."

    return rewiring

def get_snapshot_edge_attr(data, snapshot_idx):
    if snapshot_idx == 0:
        raise ValueError("Snapshots start at 1.")

    if not hasattr(data, "edge_attr_rewirings_store"):
        data.edge_attr_rewirings_store = {}

    if snapshot_idx in data.edge_attr_rewirings_store:
        return data.edge_attr_rewirings_store[snapshot_idx]

    # If there are no edge attributes at all, nothing to return.
    if not hasattr(data, "edge_attr") or data.edge_attr is None:
        data.edge_attr_rewirings_store[snapshot_idx] = None
        return None

    edge_attr = data.edge_attr           # shape [E_attr, F]
    weights = data.edge_weights          # shape [E_edges]

    # Make sure lengths match: one attribute row per edge.
    if edge_attr.size(0) != weights.size(0):
        if edge_attr.size(0) > weights.size(0):
            # More attributes than edges -> truncate extras
            edge_attr = edge_attr[:weights.size(0)]
        else:
            # More edges than attributes -> pad new edges with zeros
            pad_rows = weights.size(0) - edge_attr.size(0)
            pad = edge_attr.new_zeros(pad_rows, edge_attr.size(1))
            edge_attr = torch.cat([edge_attr, pad], dim=0)

    mask = (weights == snapshot_idx)     # shape [E_edges]
    attr = edge_attr[mask]               # shape [E_snapshot, F]

    data.edge_attr_rewirings_store[snapshot_idx] = attr

    # assert rewiring.shape[1] > 0, f"Rewiring for {snapshot_idx} not found."

    return attr

def one_hot_transform(g):
    g.y = F.one_hot(g.y, num_classes=6)
    return g

def process_TUDataset(g, dataset):
    if dataset in ["MUTAG", "ENZYMES", "PROTEINS"]:
        g = one_hot_transform(g)
    elif dataset in ["REDDIT-BINARY", "IMDB-BINARY", "COLLAB"]:
        g = one_hot_transform(g)
        g = T.Constant()(g)
    
    return g

@dataclass
class TUDatasetTransform:
    dataset: str = None

    def transform(self, g):
        return process_TUDataset(g,dataset=self.dataset)