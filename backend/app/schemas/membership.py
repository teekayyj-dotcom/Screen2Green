from pydantic import BaseModel
from app.api.deps import get_db
from app.core.config import BaseSettings

class MembershipResponse(BaseModel):

    membership: str
    points: int
