# ==============================================================================
# Resumer Backend Safe Deployment Script
# Target: https://resumer.cellanoma.my.id
# Server: Hostinger 153.92.8.198:65002 (u731410318)
# Path: /home/u731410318/domains/cellanoma.my.id/public_html/resumer/
# ==============================================================================

param(
    [string[]]$Files = @(
        "app/Http/Controllers/Api/CoinController.php",
        "routes/api.php"
    ),
    [switch]$AllChanged
)

$ErrorActionPreference = "Stop"

$REMOTE_USER = "u731410318"
$REMOTE_HOST = "153.92.8.198"
$REMOTE_PORT = 65002
$REMOTE_DIR = "domains/cellanoma.my.id/public_html/resumer"
$KEY_PATH = "$env:USERPROFILE\.ssh\id_ed25519_resumer"
$BASE_URL = "https://resumer.cellanoma.my.id/api/v1"

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host " [RESUMER] Memulai Deployment ke Server Produksi" -ForegroundColor Cyan
Write-Host " Target Domain: resumer.cellanoma.my.id" -ForegroundColor Yellow
Write-Host " Remote Dir: $REMOTE_DIR" -ForegroundColor Yellow
Write-Host "==========================================================" -ForegroundColor Cyan

if (-not (Test-Path $KEY_PATH)) {
    Write-Error "SSH Key tidak ditemukan di $KEY_PATH!"
    exit 1
}

# Jika flag -AllChanged diset, cari file backend yang modified
if ($AllChanged) {
    $gitStatus = git status --porcelain backend/
    $Files = @()
    foreach ($line in $gitStatus) {
        $filePath = $line.Substring(3).Trim()
        if ($filePath.StartsWith("backend/")) {
            $relPath = $filePath.Substring(8)
            $Files += $relPath
        }
    }
}

if ($Files.Count -eq 0) {
    Write-Host "[INFO] Tidak ada file backend yang ditentukan untuk diupload." -ForegroundColor Yellow
} else {
    Write-Host "[1/3] Mengunggah file ke server..." -ForegroundColor Green
    foreach ($file in $Files) {
        $localFile = "backend/$file"
        $remoteTarget = "$REMOTE_USER@$REMOTE_HOST`:$REMOTE_DIR/$file"
        if (Test-Path $localFile) {
            Write-Host "  -> Upload: $localFile -> $remoteTarget"
            scp -P $REMOTE_PORT -i $KEY_PATH $localFile $remoteTarget
        } else {
            Write-Warning "File lokal tidak ditemukan: $localFile (Dilewati)"
        }
    }
}

Write-Host "[2/3] Membersihkan cache Laravel di server..." -ForegroundColor Green
# Selalu sertakan -T -n untuk mencegah Windows OpenSSH hang
ssh -T -n -i $KEY_PATH -p $REMOTE_PORT "$REMOTE_USER@$REMOTE_HOST" "cd $REMOTE_DIR && php artisan optimize:clear"

Write-Host "[3/3] Melakukan Health-Check ke $BASE_URL/app-config..." -ForegroundColor Green
try {
    $res = Invoke-RestMethod -Uri "$BASE_URL/app-config" -Method Get -TimeoutSec 10
    if ($res.success -eq $true) {
        Write-Host " [HEALTH-CHECK OK] Server live merespons dengan sukses!" -ForegroundColor Green
    } else {
        Write-Warning "Respons health-check tidak memiliki success:true"
    }
} catch {
    Write-Error "Gagal melakukan health-check: $_"
}

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host " [SELESAI] Deployment backend berhasil dieksekusi 100%!" -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan
