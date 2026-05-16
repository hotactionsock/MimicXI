import os
import re
import mariadb


def _read_network_settings():
    script_dir = os.path.dirname(os.path.abspath(__file__))
    candidates = [
        os.environ.get('MIMIC_NETWORK_LUA', ''),
        os.path.join(script_dir, '../../settings/network.lua'),
        os.path.join(script_dir, '../../settings/default/network.lua'),
    ]
    for path in candidates:
        if path and os.path.exists(path):
            creds = {}
            with open(path) as f:
                for line in f:
                    for m in re.findall(r"(SQL_\w+)\s*=\s*(?:'([^']*)'|\"([^\"]*)\"|([^\s,}]+))", line):
                        key = m[0]
                        val = next((v for v in m[1:] if v), '')
                        creds[key] = val
            return creds
    raise FileNotFoundError(
        "Cannot find network.lua. Set MIMIC_NETWORK_LUA env var to the full path."
    )


def get_connection():
    c = _read_network_settings()
    return mariadb.connect(
        host=c.get('SQL_HOST', '127.0.0.1'),
        port=int(c.get('SQL_PORT', 3306)),
        user=c.get('SQL_LOGIN', 'root'),
        password=c.get('SQL_PASSWORD', ''),
        database=c.get('SQL_DATABASE', 'xidb'),
        autocommit=True,
    )
