"""
Simple HTTP server for Shaadi Song website.
Run this file, then open http://localhost:8080 in your browser.
"""
import http.server, socketserver, webbrowser, threading, os

PORT = 8080
os.chdir(os.path.dirname(os.path.abspath(__file__)))

Handler = http.server.SimpleHTTPRequestHandler
Handler.extensions_map.update({'.mp3': 'audio/mpeg', '.jpg': 'image/jpeg'})

def open_browser():
    import time; time.sleep(1.2)
    webbrowser.open(f'http://localhost:{PORT}')

threading.Thread(target=open_browser, daemon=True).start()

print(f"\n🎊 Shaadi Song server running at http://localhost:{PORT}")
print("   Opening your browser automatically...")
print("   Press Ctrl+C to stop.\n")

with socketserver.TCPServer(("", PORT), Handler) as httpd:
    httpd.serve_forever()
