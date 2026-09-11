# Shaadi Song - Local HTTP Server
# Uses .NET HttpListener built into Windows PowerShell - no installs needed

$ErrorActionPreference = "Stop"

$ports = @(8080, 3000, 5000, 7000)
$root  = $PSScriptRoot
$listener = $null
$chosenPort = $null

foreach ($p in $ports) {
    try {
        $l = New-Object System.Net.HttpListener
        $l.Prefixes.Add("http://localhost:$p/")
        $l.Start()
        $listener = $l
        $chosenPort = $p
        break
    } catch {
        Write-Host "  Port $p busy, trying next..." -ForegroundColor DarkGray
    }
}

if (-not $listener) {
    Write-Host ""
    Write-Host "  ERROR: Could not bind to any port (8080, 3000, 5000, 7000)" -ForegroundColor Red
    Write-Host "  Try running this script as Administrator." -ForegroundColor Yellow
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host ""
Write-Host "  ============================================" -ForegroundColor Yellow
Write-Host "   Shaadi Song Server RUNNING!" -ForegroundColor Green
Write-Host "  ============================================" -ForegroundColor Yellow
Write-Host "  URL: http://localhost:$chosenPort" -ForegroundColor Cyan
Write-Host "  Root: $root" -ForegroundColor Gray
Write-Host "  Press Ctrl+C to stop." -ForegroundColor Gray
Write-Host ""

# Open browser
Start-Process "http://localhost:$chosenPort"

# MIME helper
function Get-Mime([string]$ext) {
    switch ($ext.ToLower()) {
        ".html"  { return "text/html; charset=utf-8" }
        ".css"   { return "text/css" }
        ".js"    { return "application/javascript" }
        ".mp3"   { return "audio/mpeg" }
        ".jpg"   { return "image/jpeg" }
        ".jpeg"  { return "image/jpeg" }
        ".png"   { return "image/png" }
        ".gif"   { return "image/gif" }
        ".ico"   { return "image/x-icon" }
        ".svg"   { return "image/svg+xml" }
        ".woff2" { return "font/woff2" }
        default  { return "application/octet-stream" }
    }
}

# Request loop
while ($listener.IsListening) {
    try {
        $ctx = $listener.GetContext()
    } catch {
        break
    }

    $req = $ctx.Request
    $res = $ctx.Response

    try {
        $urlPath = $req.Url.LocalPath.TrimStart('/')
        $urlPath = [Uri]::UnescapeDataString($urlPath)
        if ($urlPath -eq "" -or $urlPath -eq "/") { $urlPath = "index.html" }

        # Prevent directory traversal
        $filePath = [IO.Path]::GetFullPath((Join-Path $root $urlPath))
        if (-not $filePath.StartsWith($root)) {
            $res.StatusCode = 403
            $msg = [Text.Encoding]::UTF8.GetBytes("403 Forbidden")
            $res.OutputStream.Write($msg, 0, $msg.Length)
        } elseif (Test-Path $filePath -PathType Leaf) {
            $ext   = [IO.Path]::GetExtension($filePath)
            $bytes = [IO.File]::ReadAllBytes($filePath)
            $res.StatusCode      = 200
            $res.ContentType     = Get-Mime $ext
            $res.ContentLength64 = $bytes.Length
            $res.AddHeader("Cache-Control", "no-cache")
            $res.OutputStream.Write($bytes, 0, $bytes.Length)
            Write-Host "  [200] $urlPath" -ForegroundColor DarkGreen
        } else {
            $res.StatusCode = 404
            $msg = [Text.Encoding]::UTF8.GetBytes("404 Not Found: $urlPath")
            $res.OutputStream.Write($msg, 0, $msg.Length)
            Write-Host "  [404] $urlPath" -ForegroundColor DarkRed
        }
    } catch {
        try {
            $res.StatusCode = 500
            $msg = [Text.Encoding]::UTF8.GetBytes("500 Error: $_")
            $res.OutputStream.Write($msg, 0, $msg.Length)
        } catch {}
    } finally {
        try { $res.OutputStream.Close() } catch {}
    }
}

$listener.Stop()
Write-Host "Server stopped." -ForegroundColor Gray
