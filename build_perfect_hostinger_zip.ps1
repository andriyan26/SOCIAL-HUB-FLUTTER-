param(
    [string]$OutputDir = "$PSScriptRoot\public_html_build",
    [string]$ZipFile = "$PSScriptRoot\public_html.zip",
    [string]$AltZipFile = "$PSScriptRoot\socialhub_hostinger.zip"
)

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "   MEMPERSIAPKAN PAKET HOSTINGER LINUX-COMPLIANT (ZIP)   " -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

# 1. Clean and recreate directory structure
if (Test-Path $OutputDir) {
    Remove-Item -Path $OutputDir -Recurse -Force
}

$dirs = @(
    "$OutputDir",
    "$OutputDir\api",
    "$OutputDir\uploads\videos",
    "$OutputDir\uploads\images",
    "$OutputDir\icons",
    "$OutputDir\canvaskit",
    "$OutputDir\canvaskit\chromium",
    "$OutputDir\assets",
    "$OutputDir\assets\assets",
    "$OutputDir\assets\assets\images",
    "$OutputDir\assets\assets\videos",
    "$OutputDir\assets\assets\audio",
    "$OutputDir\assets\images",
    "$OutputDir\assets\videos",
    "$OutputDir\assets\audio",
    "$OutputDir\assets\fonts",
    "$OutputDir\fonts",
    "$OutputDir\assets\packages\font_awesome_flutter\lib\fonts",
    "$OutputDir\assets\packages\cupertino_icons\assets",
    "$OutputDir\packages\font_awesome_flutter\lib\fonts",
    "$OutputDir\packages\cupertino_icons\assets"
)

foreach ($d in $dirs) {
    if (!(Test-Path $d)) {
        New-Item -ItemType Directory -Path $d -Force | Out-Null
    }
}

$baseGhUrl = "https://andriyan26.github.io/SOCIAL-HUB-FLUTTER-"

Write-Host "`n[1/6] Mengunduh File Engine & Fonts Lengkap dari GitHub Pages..." -ForegroundColor Yellow
$coreDownloads = @(
    "main.dart.js",
    "flutter_bootstrap.js",
    "version.json",
    "canvaskit/canvaskit.js",
    "canvaskit/canvaskit.wasm",
    "canvaskit/chromium/canvaskit.js",
    "canvaskit/chromium/canvaskit.wasm",
    "canvaskit/skwasm.js",
    "canvaskit/skwasm.wasm",
    "canvaskit/skwasm_heavy.wasm",
    "assets/FontManifest.json",
    "assets/AssetManifest.bin.json",
    "assets/fonts/MaterialIcons-Regular.otf",
    "assets/packages/font_awesome_flutter/lib/fonts/Font-Awesome-7-Brands-Regular-400.otf",
    "assets/packages/font_awesome_flutter/lib/fonts/Font-Awesome-7-Free-Regular-400.otf",
    "assets/packages/font_awesome_flutter/lib/fonts/Font-Awesome-7-Free-Solid-900.otf",
    "assets/packages/cupertino_icons/assets/CupertinoIcons.ttf"
)

foreach ($rel in $coreDownloads) {
    $src = "$baseGhUrl/$rel"
    $dest = "$OutputDir\$($rel.Replace('/', '\'))"
    $parent = Split-Path $dest
    if (!(Test-Path $parent)) { New-Item -ItemType Directory -Path $parent -Force | Out-Null }
    Write-Host "  -> $rel"
    try {
        Invoke-WebRequest -Uri $src -OutFile $dest -UseBasicParsing -TimeoutSec 60
    } catch {
        Write-Warning "Gagal download $rel : $_"
    }
}

# Duplicate fonts and manifests to fallback paths for maximum compatibility
Copy-Item "$OutputDir\assets\fonts\MaterialIcons-Regular.otf" "$OutputDir\fonts\MaterialIcons-Regular.otf" -Force
Copy-Item "$OutputDir\assets\fonts\MaterialIcons-Regular.otf" "$OutputDir\assets\MaterialIcons-Regular.otf" -Force
Copy-Item "$OutputDir\assets\FontManifest.json" "$OutputDir\FontManifest.json" -Force
Copy-Item "$OutputDir\assets\AssetManifest.bin.json" "$OutputDir\AssetManifest.bin.json" -Force
Copy-Item "$OutputDir\assets\packages\*" "$OutputDir\packages\" -Recurse -Force

Write-Host "`n[2/6] Menyalin Semua Aset Media Lokal (Videos, Images, Audio, Icons)..." -ForegroundColor Yellow
$localAssets = @(
    "assets\images\andrian_feed_poster.jpg",
    "assets\images\app_icon.png",
    "assets\images\img_8664.jpg",
    "assets\images\img_8665.jpg",
    "assets\images\img_8666.jpg",
    "assets\images\img_8667.jpg",
    "assets\images\img_8668.jpg",
    "assets\videos\andrian_feed.mp4",
    "assets\videos\konsep_login.mp4",
    "assets\videos\konsep_sebelum_login.mp4",
    "assets\audio\splash_sound.mp3"
)

foreach ($la in $localAssets) {
    $src = "$PSScriptRoot\$la"
    if (Test-Path $src) {
        # Copy to assets/assets/ (standard flutter web prefix)
        Copy-Item $src "$OutputDir\assets\$la" -Force
        # Copy to assets/ (direct relative path)
        $subPath = $la.Substring(7) # strip 'assets\'
        Copy-Item $src "$OutputDir\assets\$subPath" -Force
    }
}

# Copy web files
Copy-Item "$PSScriptRoot\web\favicon.png" "$OutputDir\favicon.png" -Force
Copy-Item "$PSScriptRoot\web\apple-touch-icon.png" "$OutputDir\apple-touch-icon.png" -Force
Copy-Item "$PSScriptRoot\web\manifest.json" "$OutputDir\manifest.json" -Force
Copy-Item "$PSScriptRoot\web\icons\*" "$OutputDir\icons" -Recurse -Force

Write-Host "`n[3/6] Menyiapkan index.html Khusus Hostinger (<base href=`"/`">)..." -ForegroundColor Yellow
$indexHtml = @"
<!DOCTYPE html>
<html>
<head>
  <base href="/">

  <meta charset="UTF-8">
  <meta content="IE=Edge" http-equiv="X-UA-Compatible">
  <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
  
  <meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate">
  <meta http-equiv="Pragma" content="no-cache">
  <meta http-equiv="Expires" content="0">
  
  <meta name="description" content="Social Hub - Hostinger MySQL Edition">
  <meta name="apple-mobile-web-app-capable" content="yes">
  <meta name="apple-mobile-web-app-status-bar-style" content="black-translucent">
  <meta name="apple-mobile-web-app-title" content="Social Hub">

  <title>Social Hub</title>
  <link rel="icon" type="image/png" href="favicon.png"/>
  <link rel="apple-touch-icon" href="apple-touch-icon.png">
  <link rel="manifest" href="manifest.json">

  <style>
    video {
      pointer-events: none !important;
      -webkit-user-select: none !important;
      user-select: none !important;
    }
    video::-webkit-media-controls {
      display: none !important;
    }
    video::-webkit-media-controls-enclosure {
      display: none !important;
    }
    video::-webkit-media-controls-picture-in-picture-button {
      display: none !important;
    }
  </style>
</head>
<body style="background-color: #07080A; margin: 0; padding: 0; overflow: hidden; width: 100vw; height: 100vh;">
  <script>
    if ('caches' in window) {
      caches.keys().then(function(names) {
        for (let name of names) caches.delete(name);
      });
    }
    if ('serviceWorker' in navigator) {
      navigator.serviceWorker.getRegistrations().then(function(registrations) {
        for (var i = 0; i < registrations.length; i++) {
          registrations[i].unregister();
        }
      });
    }

    const observer = new MutationObserver(function(mutations) {
      document.querySelectorAll('video').forEach(function(vid) {
        try {
          vid.disablePictureInPicture = true;
          vid.setAttribute('disablePictureInPicture', 'true');
          vid.setAttribute('controlsList', 'nodownload noplaybackrate noremoteplayback');
          vid.style.pointerEvents = 'none';
        } catch(e) {}
      });
    });
    observer.observe(document.documentElement, { childList: true, subtree: true });
  </script>
  <script src="flutter_bootstrap.js?v=hostinger_v2" async></script>
</body>
</html>
"@

[System.IO.File]::WriteAllText("$OutputDir\index.html", $indexHtml, [System.Text.UTF8Encoding]::new($false))

Write-Host "`n[4/6] Menyalin Backend API, Database SQL & .htaccess..." -ForegroundColor Yellow
Copy-Item "$PSScriptRoot\api\*" "$OutputDir\api" -Recurse -Force
Copy-Item "$PSScriptRoot\.htaccess" "$OutputDir\.htaccess" -Force
Copy-Item "$PSScriptRoot\socialhub.sql" "$OutputDir\socialhub.sql" -Force
Set-Content -Path "$OutputDir\uploads\index.html" -Value "<!DOCTYPE html><html><body>Access Denied</body></html>" -Encoding UTF8

Write-Host "`n[5/6] Mengompresi Menggunakan bsdtar (Linux POSIX Forward Slashes)..." -ForegroundColor Yellow
if (Test-Path $ZipFile) { Remove-Item $ZipFile -Force }
if (Test-Path $AltZipFile) { Remove-Item $AltZipFile -Force }

# Use tar to generate a true Linux-compatible zip with '/' separators
Push-Location $OutputDir
tar -a -c -f $ZipFile *
Pop-Location

# Create copy
Copy-Item $ZipFile $AltZipFile -Force

$zipSize = (Get-Item $ZipFile).Length / 1MB
Write-Host "`n[6/6] Verifikasi Format ZIP..." -ForegroundColor Yellow
Add-Type -AssemblyName System.IO.Compression.FileSystem
$zipArchive = [System.IO.Compression.ZipFile]::OpenRead($ZipFile)
$firstEntries = $zipArchive.Entries | Select-Object -First 10 FullName
$hasBackslash = ($zipArchive.Entries | Where-Object { $_.FullName -like "*\*" }).Count -gt 0
$zipArchive.Dispose()

Write-Host "  Contoh Entry di dalam ZIP:"
$firstEntries | ForEach-Object { Write-Host "    -> $($_.FullName)" }

if ($hasBackslash) {
    Write-Warning "PERINGATAN: Masih ada backslash di dalam ZIP!"
} else {
    Write-Host "  VERIFIKASI SUKSES: 100% menggunakan format '/' (Linux Forward Slash)!" -ForegroundColor Green
}

Write-Host "`n==========================================================" -ForegroundColor Green
Write-Host "  BERHASIL! ZIP BARU SIAP DIUPLOAD KE HOSTINGER:          " -ForegroundColor Green
Write-Host "  $ZipFile ($([Math]::Round($zipSize, 2)) MB)" -ForegroundColor Green
Write-Host "==========================================================" -ForegroundColor Green
