param(
    [string]$OutputDir = "$PSScriptRoot\public_html_build",
    [string]$ZipFile = "$PSScriptRoot\public_html.zip"
)

Write-Host "=== 1. Menyiapkan Folder public_html ===" -ForegroundColor Cyan
if (Test-Path $OutputDir) {
    Remove-Item -Path $OutputDir -Recurse -Force
}
New-Item -ItemType Directory -Path $OutputDir | Out-Null
New-Item -ItemType Directory -Path "$OutputDir\api" | Out-Null
New-Item -ItemType Directory -Path "$OutputDir\uploads\videos" -Force | Out-Null
New-Item -ItemType Directory -Path "$OutputDir\uploads\images" -Force | Out-Null
New-Item -ItemType Directory -Path "$OutputDir\canvaskit\chromium" -Force | Out-Null
New-Item -ItemType Directory -Path "$OutputDir\assets\fonts" -Force | Out-Null
New-Item -ItemType Directory -Path "$OutputDir\assets\packages\font_awesome_flutter\lib\fonts" -Force | Out-Null
New-Item -ItemType Directory -Path "$OutputDir\assets\packages\cupertino_icons\assets" -Force | Out-Null
New-Item -ItemType Directory -Path "$OutputDir\icons" -Force | Out-Null

$baseGhUrl = "https://andriyan26.github.io/SOCIAL-HUB-FLUTTER-"

Write-Host "=== 2. Mengunduh Core Flutter Web Runtime ===" -ForegroundColor Cyan
$coreFiles = @(
    "main.dart.js",
    "flutter_bootstrap.js",
    "version.json",
    "canvaskit/canvaskit.js",
    "canvaskit/canvaskit.wasm",
    "canvaskit/chromium/canvaskit.wasm",
    "assets/FontManifest.json",
    "assets/AssetManifest.bin.json",
    "assets/fonts/MaterialIcons-Regular.otf",
    "assets/packages/font_awesome_flutter/lib/fonts/Font-Awesome-7-Brands-Regular-400.otf",
    "assets/packages/font_awesome_flutter/lib/fonts/Font-Awesome-7-Free-Regular-400.otf",
    "assets/packages/font_awesome_flutter/lib/fonts/Font-Awesome-7-Free-Solid-900.otf",
    "assets/packages/cupertino_icons/assets/CupertinoIcons.ttf"
)

foreach ($f in $coreFiles) {
    $src = "$baseGhUrl/$f"
    $dest = "$OutputDir\$($f.Replace('/', '\'))"
    $parent = Split-Path $dest
    if (!(Test-Path $parent)) { New-Item -ItemType Directory -Path $parent -Force | Out-Null }
    Write-Host "Downloading $f..."
    try {
        Invoke-WebRequest -Uri $src -OutFile $dest -UseBasicParsing -TimeoutSec 60
    } catch {
        Write-Warning "Could not fetch $f : $_"
    }
}

Write-Host "=== 3. Menyalin Aset Lokal (Images, Videos, Sounds, Icons) ===" -ForegroundColor Cyan
# Copy web assets
Copy-Item -Path "$PSScriptRoot\web\favicon.png" -Destination "$OutputDir\favicon.png" -Force
Copy-Item -Path "$PSScriptRoot\web\apple-touch-icon.png" -Destination "$OutputDir\apple-touch-icon.png" -Force
Copy-Item -Path "$PSScriptRoot\web\manifest.json" -Destination "$OutputDir\manifest.json" -Force
Copy-Item -Path "$PSScriptRoot\web\icons\*" -Destination "$OutputDir\icons" -Recurse -Force

# Copy application assets (both to assets/ and assets/assets/ for flutter compatibility)
Copy-Item -Path "$PSScriptRoot\assets" -Destination "$OutputDir\assets" -Recurse -Force

Write-Host "=== 4. Mempersiapkan index.html Khusus Hostinger (Base Href: /) ===" -ForegroundColor Cyan
$indexHtml = @"
<!DOCTYPE html>
<html>
<head>
  <base href="/">

  <meta charset="UTF-8">
  <meta content="IE=Edge" http-equiv="X-UA-Compatible">
  <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
  
  <!-- Disable browser cache so updates show immediately -->
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
    /* Disable Edge / Chrome native floating video toolbar (PiP and Video Enhance buttons) */
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
    // Force clear old service workers and web caches
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

    // Disable native browser PiP and enhancement overlay on all injected video tags
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
  <script src="flutter_bootstrap.js?v=hostinger" async></script>
</body>
</html>
"@

Set-Content -Path "$OutputDir\index.html" -Value $indexHtml -Encoding UTF8

Write-Host "=== 5. Menyalin Backend API, Database SQL & .htaccess ===" -ForegroundColor Cyan
Copy-Item -Path "$PSScriptRoot\api\*" -Destination "$OutputDir\api" -Recurse -Force
Copy-Item -Path "$PSScriptRoot\.htaccess" -Destination "$OutputDir\.htaccess" -Force
Copy-Item -Path "$PSScriptRoot\socialhub.sql" -Destination "$OutputDir\socialhub.sql" -Force

# Create index.html in uploads to prevent directory listing
Set-Content -Path "$OutputDir\uploads\index.html" -Value "<!DOCTYPE html><html><body>Access Denied</body></html>" -Encoding UTF8

Write-Host "=== 6. Mengompresi menjadi $ZipFile ===" -ForegroundColor Cyan
if (Test-Path $ZipFile) {
    Remove-Item -Path $ZipFile -Force
}
Compress-Archive -Path "$OutputDir\*" -DestinationPath $ZipFile -CompressionLevel Optimal

# Create duplicate named socialhub_hostinger.zip for convenience
$altZip = "$PSScriptRoot\socialhub_hostinger.zip"
if (Test-Path $altZip) { Remove-Item -Path $altZip -Force }
Copy-Item -Path $ZipFile -Destination $altZip -Force

$zipSize = (Get-Item $ZipFile).Length / 1MB
Write-Host "=== BERHASIL! File ZIP Hostinger Siap: $ZipFile ($([Math]::Round($zipSize, 2)) MB) ===" -ForegroundColor Green

