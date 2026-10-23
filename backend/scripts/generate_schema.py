"""Generate supabase/schema.sql (Postgres DDL) from the SQLAlchemy models so the two can never drift.
    python scripts/generate_schema.py > ../supabase/schema.sql
"""
import os, sys
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
os.environ.setdefault("DATABASE_URL", "sqlite://")

from sqlalchemy.dialects import postgresql
from sqlalchemy.schema import CreateIndex, CreateTable

import models  # noqa
from db import Base

d = postgresql.dialect()
print("-- GlobalGuru schema for Supabase (Postgres). Paste into the Supabase SQL Editor and run.")
print("-- Generated from backend/models.py by backend/scripts/generate_schema.py — do not edit by hand.\n")
for t in Base.metadata.sorted_tables:
    print(str(CreateTable(t, if_not_exists=True).compile(dialect=d)).strip() + ";\n")
    for ix in sorted(t.indexes, key=lambda i: i.name):
        print(str(CreateIndex(ix, if_not_exists=True).compile(dialect=d)).strip() + ";")
    print()
print("""-- The API connects with the database owner (DATABASE_URL), which bypasses Row Level Security, and
-- never exposes PostgREST to the browser. Enabling RLS with no policies makes these tables
-- unreachable through Supabase's public anon/authenticated REST API, which is what we want.""")
for t in Base.metadata.sorted_tables:
    print(f"ALTER TABLE public.{t.name} ENABLE ROW LEVEL SECURITY;")
