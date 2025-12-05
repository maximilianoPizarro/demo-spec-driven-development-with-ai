# Script para descargar e instalar la extensión MTA desde migtools/editor-extensions
# Uso: .\install-mta-extension.ps1

Write-Host "Descargando extensión MTA desde migtools/editor-extensions..." -ForegroundColor Green

# URL del release más reciente (v8.0.2)
$releaseUrl = "https://github.com/migtools/editor-extensions/releases/download/v8.0.2/mta-vscode-extension-8.0.2.vsix"
$vsixPath = "$PSScriptRoot\mta-vscode-extension.vsix"

try {
    # Descargar el archivo VSIX
    Write-Host "Descargando desde: $releaseUrl" -ForegroundColor Yellow
    Invoke-WebRequest -Uri $releaseUrl -OutFile $vsixPath -UseBasicParsing
    
    if (Test-Path $vsixPath) {
        Write-Host "Archivo descargado exitosamente: $vsixPath" -ForegroundColor Green
        
        # Instalar la extensión usando VS Code CLI
        Write-Host "Instalando extensión..." -ForegroundColor Yellow
        
        # Buscar code.exe en las ubicaciones comunes
        $codePaths = @(
            "${env:LOCALAPPDATA}\Programs\Microsoft VS Code\Code.exe",
            "${env:ProgramFiles}\Microsoft VS Code\Code.exe",
            "${env:ProgramFiles(x86)}\Microsoft VS Code\Code.exe"
        )
        
        $codeExe = $null
        foreach ($path in $codePaths) {
            if (Test-Path $path) {
                $codeExe = $path
                break
            }
        }
        
        if ($codeExe) {
            Write-Host "Instalando extensión con VS Code..." -ForegroundColor Yellow
            & "$codeExe" --install-extension $vsixPath --force
            Write-Host "Extensión instalada exitosamente!" -ForegroundColor Green
        } else {
            Write-Host "VS Code no encontrado. Por favor instala la extensión manualmente:" -ForegroundColor Yellow
            Write-Host "1. Abre VS Code" -ForegroundColor Yellow
            Write-Host "2. Ve a Extensiones (Ctrl+Shift+X)" -ForegroundColor Yellow
            Write-Host "3. Haz clic en '...' (tres puntos) > 'Instalar desde VSIX...'" -ForegroundColor Yellow
            Write-Host "4. Selecciona: $vsixPath" -ForegroundColor Yellow
        }
    } else {
        Write-Host "Error: No se pudo descargar el archivo" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "Error al descargar/instalar: $_" -ForegroundColor Red
    Write-Host "Intentando descargar la versión más reciente desde la API de GitHub..." -ForegroundColor Yellow
    
    # Intentar obtener la última versión desde la API de GitHub
    try {
        $apiUrl = "https://api.github.com/repos/migtools/editor-extensions/releases/latest"
        $releaseInfo = Invoke-RestMethod -Uri $apiUrl -UseBasicParsing
        
        $vsixAsset = $releaseInfo.assets | Where-Object { $_.name -like "*.vsix" } | Select-Object -First 1
        
        if ($vsixAsset) {
            Write-Host "Descargando versión más reciente: $($vsixAsset.name)" -ForegroundColor Yellow
            Invoke-WebRequest -Uri $vsixAsset.browser_download_url -OutFile $vsixPath -UseBasicParsing
            
            if (Test-Path $vsixPath) {
                Write-Host "Archivo descargado: $vsixPath" -ForegroundColor Green
                Write-Host "Por favor instala manualmente desde VS Code usando este archivo." -ForegroundColor Yellow
            }
        }
    } catch {
        Write-Host "Error al obtener información del release: $_" -ForegroundColor Red
        exit 1
    }
}

