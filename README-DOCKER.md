# podman Image con Extensión MTA Pre-instalada

Este Dockerfile crea una imagen personalizada basada en `quay.io/devfile/universal-developer-image:ubi8-latest` con la extensión MTA (Migration Toolkit for Applications) pre-instalada.

## Construir la Imagen

### En Linux/Mac (Bash)

```bash
chmod +x build-and-push.sh
./build-and-push.sh [version]
```

Ejemplo:
```bash
./build-and-push.sh v1.0.0
```

### En Windows (PowerShell)

```powershell
.\build-and-push.ps1 -Version v1.0.0
```

### Manualmente

```bash
# Construir la imagen
podman build -t quay.io/maximilianopizarro/lightspeed-demo:latest .

# Subir a quay.io (requiere login primero)
podman login quay.io
podman push quay.io/maximilianopizarro/lightspeed-demo:latest
```

## Usar la Imagen en Devfile

Actualiza tu `devfile.yaml` para usar la imagen personalizada:

```yaml
components:
  - name: tools
    container:
      image: quay.io/maximilianopizarro/lightspeed-demo:latest
      # ... resto de la configuración
```

## Ventajas

- ✅ **Extensión pre-instalada**: La extensión MTA está lista al iniciar el workspace
- ✅ **Más rápido**: No necesita descargar e instalar la extensión en cada inicio
- ✅ **Consistente**: Todos los workspaces usan la misma versión de la extensión
- ✅ **Optimizado**: La imagen está optimizada y lista para producción

## Estructura del Dockerfile

1. **Base**: `quay.io/devfile/universal-developer-image:ubi8-latest`
2. **Dependencias**: Instala `unzip` si es necesario
3. **Instalación**: Descarga e instala la extensión MTA v8.0.2 desde migtools
4. **Verificación**: Confirma que la extensión se instaló correctamente

## Versiones Disponibles

- `latest` - Última versión construida
- `v1.0.0` - Versión específica (ejemplo)

## Actualizar la Extensión

Para actualizar a una nueva versión de la extensión MTA:

1. Edita `Dockerfile` y actualiza la variable `VSIX_URL` con la nueva versión
2. Reconstruye la imagen: `./build-and-push.sh v1.0.1`
3. Actualiza el devfile para usar la nueva versión

## Verificar la Instalación

Una vez que el workspace esté corriendo con esta imagen:

```bash
# Verificar que la extensión está instalada
ls -la /home/user/.vscode-server/extensions/

# Deberías ver algo como:
# redhat.mta-vscode-extension-8.0.2
```

## Notas

- La extensión se instala en `/home/user/.vscode-server/extensions/`
- El tamaño de la imagen aumenta aproximadamente 25MB por la extensión
- La imagen mantiene todas las características de la imagen base original

