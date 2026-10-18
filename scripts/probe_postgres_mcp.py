"""Probe the postgres MCP recipe's read-only guard against a real database.

Starts a throwaway Postgres with pgserver, creates a users table with one row,
then sends postgres-mcp the payloads that escape a plain read-only transaction
(the bypass in the archived @modelcontextprotocol/server-postgres) through the
MCP execute_sql tool. Prints each result and the row count afterwards, so
"the table survived" is measured, not assumed.

Run it with the access mode as the only argument. unrestricted is the control
run: it shows the probe does detect a drop.

    uv run --python 3.12 --with postgres-mcp==0.3.0 --with "mcp<2"       --with pgserver --with "psycopg[binary]"       python scripts/probe_postgres_mcp.py restricted

Linux and macOS only: pglast, which postgres-mcp needs, ships no Windows
wheel. On Windows run it inside WSL.
"""

import asyncio
import os
import shutil
import sys
import tempfile

import pgserver
import psycopg
from mcp import ClientSession, StdioServerParameters
from mcp.client.stdio import stdio_client

PAYLOADS = [
    "SELECT count(*) AS n FROM users",
    "COMMIT; DROP TABLE users;",
    "ROLLBACK; DROP TABLE users;",
    "DROP TABLE users",
    "DELETE FROM users",
    "SELECT 1; DROP TABLE users;",
]


async def main(mode: str) -> int:
    data = tempfile.mkdtemp(prefix="pgprobe-")
    srv = pgserver.get_server(data, cleanup_mode="stop")
    uri = srv.get_uri()
    with psycopg.connect(uri, autocommit=True) as conn:
        conn.execute("CREATE TABLE users (id int primary key, name text)")
        conn.execute("INSERT INTO users VALUES (1, 'ada')")

    params = StdioServerParameters(
        command=shutil.which("postgres-mcp") or "postgres-mcp",
        args=[f"--access-mode={mode}"],
        env={**os.environ, "DATABASE_URI": uri},
    )
    async with (
        stdio_client(params) as (read, write),
        ClientSession(read, write) as session,
    ):
        await session.initialize()
        tools = await session.list_tools()
        print("tools:", ", ".join(sorted(t.name for t in tools.tools)))
        for sql in PAYLOADS:
            result = await session.call_tool("execute_sql", {"sql": sql})
            text = " ".join(getattr(c, "text", "") for c in result.content).replace(
                "\n", " "
            )
            print(f"{sql!r:40} isError={result.isError} -> {text[:160]}")

    with psycopg.connect(uri) as conn:
        exists = conn.execute(
            "SELECT to_regclass('public.users') IS NOT NULL"
        ).fetchone()[0]
        rows = conn.execute("SELECT count(*) FROM users").fetchone()[0] if exists else 0
    print(f"mode={mode} users_table_exists={exists} rows={rows}")
    srv.cleanup()
    return 0 if exists else 1


if __name__ == "__main__":
    access_mode = sys.argv[1] if len(sys.argv) > 1 else "restricted"
    if access_mode not in ("restricted", "unrestricted"):
        sys.exit("usage: probe_postgres_mcp.py [restricted|unrestricted]")
    sys.exit(asyncio.run(main(access_mode)))
