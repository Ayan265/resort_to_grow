#!/usr/bin/env python3
import http.server
import socketserver
import json
import os
import sys
import webbrowser
from pathlib import Path

PORT = 1422
DIRECTORY = os.path.dirname(os.path.abspath(__file__))

class DashboardHandler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=DIRECTORY, **kwargs)

    def do_GET(self):
        if self.path == '/api/history':
            history_path = Path.home() / '.accountability_history.json'
            if history_path.exists():
                try:
                    with open(history_path, 'r') as f:
                        data = json.load(f)
                    self.send_response(200)
                    self.send_header('Content-type', 'application/json')
                    self.send_header('Access-Control-Allow-Origin', '*')
                    self.end_headers()
                    self.wfile.write(json.dumps(data).encode('utf-8'))
                except Exception as e:
                    self.send_response(500)
                    self.send_header('Content-type', 'application/json')
                    self.send_header('Access-Control-Allow-Origin', '*')
                    self.end_headers()
                    self.wfile.write(json.dumps({"error": str(e)}).encode('utf-8'))
            else:
                self.send_response(200)
                self.send_header('Content-type', 'application/json')
                self.send_header('Access-Control-Allow-Origin', '*')
                self.end_headers()
                self.wfile.write(b'[]')
        elif self.path == '/api/config':
            import re
            timer_mins = 30
            user_name = 'Friend'
            # Locate config.js relative to this server's directory (../app/src/config.js)
            config_path = Path(DIRECTORY).parent / 'app' / 'src' / 'config.js'
            if config_path.exists():
                try:
                    with open(config_path, 'r') as f:
                        content = f.read()
                        match = re.search(r'timerIntervalMinutes:\s*(\d+)', content)
                        if match:
                            timer_mins = int(match.group(1))
                        # Extract user name from pleaQuestion (e.g. "Ayan, Don't you want me?")
                        name_match = re.search(r"pleaQuestion:\s*['\"]([^,]+),", content)
                        if name_match:
                            user_name = name_match.group(1).strip()
                except Exception:
                    pass
            self.send_response(200)
            self.send_header('Content-type', 'application/json')
            self.send_header('Access-Control-Allow-Origin', '*')
            self.end_headers()
            self.wfile.write(json.dumps({"timerIntervalMinutes": timer_mins, "userName": user_name}).encode('utf-8'))
        else:
            super().do_GET()

def is_port_in_use(port):
    import socket
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
        return s.connect_ex(('localhost', port)) == 0

def main():
    # If server is already running, just open the browser and exit
    if is_port_in_use(PORT):
        print(f"Dashboard server is already running on port {PORT}. Launching browser page...")
        webbrowser.open(f"http://localhost:{PORT}")
        sys.exit(0)

    # Change working directory to directory of this file
    os.chdir(DIRECTORY)

    # Allow reusing address/port immediately after restarts
    socketserver.TCPServer.allow_reuse_address = True
    
    try:
        with socketserver.TCPServer(("", PORT), DashboardHandler) as httpd:
            print(f"Starting dashboard server at http://localhost:{PORT}")
            # Open browser in a separate thread/process so it doesn't block server start
            webbrowser.open(f"http://localhost:{PORT}")
            httpd.serve_forever()
    except KeyboardInterrupt:
        print("\nShutting down server.")
    except Exception as e:
        print(f"Error starting server: {e}", file=sys.stderr)
        sys.exit(1)

if __name__ == '__main__':
    main()
