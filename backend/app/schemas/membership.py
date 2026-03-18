from pydantic import BaseModel


class MembershipResponse(BaseModel):
    """Thông tin membership đầy đủ của user."""
    membership_level: str
    points_per_tree:  int
    min_trees:        int
    tree_planted:     int
    points:           int
