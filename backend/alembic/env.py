import os
import sys
from logging.config import fileConfig

from sqlalchemy import engine_from_config
from sqlalchemy import pool
from alembic import context

# 1. Định vị thư mục gốc (backend) để Python hiểu các import bắt đầu bằng 'app.'
sys.path.append(os.path.dirname(os.path.dirname(__file__)))

# 2. Import cấu hình và Base của dự án FastAPI
from app.core.config import settings
from app.models import Base  # Nơi chứa tất cả metadata của các bảng (đã gom ở __init__.py)

# Cấu hình file log của Alembic
config = context.config
if config.config_file_name is not None:
    fileConfig(config.config_file_name)

# 3. Trỏ target_metadata vào Base của chúng ta để Alembic biết cần so sánh DB với Model nào
target_metadata = Base.metadata

# 4. Lấy Database URL từ file settings của FastAPI (Ghi đè cấu hình trong alembic.ini)
config.set_main_option("sqlalchemy.url", str(settings.DATABASE_URL))

def run_migrations_offline() -> None:
    url = config.get_main_option("sqlalchemy.url")
    context.configure(
        url=url,
        target_metadata=target_metadata,
        literal_binds=True,
        dialect_opts={"paramstyle": "named"},
    )
    with context.begin_transaction():
        context.run_migrations()

def run_migrations_online() -> None:
    connectable = engine_from_config(
        config.get_section(config.config_ini_section, {}),
        prefix="sqlalchemy.",
        poolclass=pool.NullPool,
    )
    with connectable.connect() as connection:
        context.configure(
            connection=connection, target_metadata=target_metadata
        )
        with context.begin_transaction():
            context.run_migrations()

if context.is_offline_mode():
    run_migrations_offline()
else:
    run_migrations_online()