#!/usr/bin/env python3
"""
Cross-platform launcher for the MimicXI web character creator.
Works on Windows, macOS, and Linux without needing a shell script.

Usage:
    python run.py          # starts on port 5000
    python run.py 8080     # starts on a custom port
"""
import os
import subprocess
import sys
from pathlib import Path

HERE = Path(__file__).parent.resolve()

def venv_python():
    """Return the path to the venv Python binary for the current platform."""
    if sys.platform == 'win32':
        return HERE / '.venv' / 'Scripts' / 'python.exe'
    return HERE / '.venv' / 'bin' / 'python'

def venv_pip():
    if sys.platform == 'win32':
        return HERE / '.venv' / 'Scripts' / 'pip.exe'
    return HERE / '.venv' / 'bin' / 'pip'

def run(cmd, **kwargs):
    result = subprocess.run(cmd, **kwargs)
    if result.returncode != 0:
        print(f'\nERROR: command failed: {" ".join(str(c) for c in cmd)}')
        sys.exit(result.returncode)

def main():
    port = sys.argv[1] if len(sys.argv) > 1 else '5000'

    # Create venv if missing
    if not venv_python().exists():
        print('Creating virtual environment...')
        run([sys.executable, '-m', 'venv', str(HERE / '.venv')])
        print('Installing dependencies...')
        run([str(venv_pip()), 'install', '--quiet', '-r', str(HERE / 'requirements.txt')])

    # Sanity-check: try importing Flask before launching so the error is readable
    check = subprocess.run(
        [str(venv_python()), '-c', 'import flask, mariadb, bcrypt'],
        capture_output=True, text=True
    )
    if check.returncode != 0:
        print('Dependency check failed — reinstalling...')
        run([str(venv_pip()), 'install', '--quiet', '-r', str(HERE / 'requirements.txt')])

    print(f'Starting MimicXI Character Creator at http://127.0.0.1:{port}')
    print('Press Ctrl+C to stop.\n')

    env = os.environ.copy()
    env['FLASK_APP'] = 'app.py'

    # Patch port into app.py env so Flask picks it up
    env['FLASK_RUN_PORT'] = port

    try:
        subprocess.run([str(venv_python()), 'app.py', port], cwd=str(HERE), env=env)
    except KeyboardInterrupt:
        print('\nStopped.')

if __name__ == '__main__':
    main()
