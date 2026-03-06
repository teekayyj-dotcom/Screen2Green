from datetime import datetime
from sqlalchemy import Boolean, Integer, Column, DateTime, func


class TimestampMixin:
    """Mixin that adds created_at and updated_at columns."""

    created_at = Column(DateTime, server_default=func.now(), nullable=False)
    updated_at = Column(DateTime, server_default=func.now(), onupdate=func.now(), nullable=False)
