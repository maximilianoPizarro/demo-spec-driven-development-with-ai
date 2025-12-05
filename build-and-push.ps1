# Script PowerShell para construir y subir la imagen podman con la extension MTA pre-instalada

param(
    [string]$Version = "latest"
)

$ImageName = "quay.io/maximilianopizarro/lightspeed-demo"
$FullImageName = "${ImageName}:${Version}"

Write-Host "Construyendo imagen podman..." -ForegroundColor Green
Write-Host "   Imagen: $FullImageName" -ForegroundColor Yellow
Write-Host ""

# Construir la imagen
podman build -t $FullImageName .

if ($LASTEXITCODE -ne 0) {
    Write-Host "Error al construir la imagen" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "Imagen construida exitosamente" -ForegroundColor Green
Write-Host ""

# Preguntar si quiere hacer push
$response = Read-Host "Deseas subir la imagen a quay.io? (y/n)"
if ($response -eq "y" -or $response -eq "Y") {
    Write-Host "Subiendo imagen a quay.io..." -ForegroundColor Yellow
    
    # Login a quay.io si es necesario
    podman login quay.io
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Error: No se pudo hacer login a quay.io" -ForegroundColor Red
        Write-Host "   Asegurate de tener las credenciales configuradas" -ForegroundColor Yellow
        exit 1
    }
    
    # Push de la imagen
    podman push $FullImageName
    
    # Si no es latest, tambien hacer push como latest
    if ($Version -ne "latest") {
        podman tag $FullImageName "${ImageName}:latest"
        podman push "${ImageName}:latest"
        Write-Host "Tambien se subio como 'latest'" -ForegroundColor Green
    }
    
    Write-Host ""
    Write-Host "Imagen subida exitosamente a $FullImageName" -ForegroundColor Green
}
else {
    Write-Host "Push cancelado. La imagen esta disponible localmente como $FullImageName" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Para usar esta imagen, actualiza tu devfile.yaml:" -ForegroundColor Cyan
Write-Host "  image: $FullImageName" -ForegroundColor White
