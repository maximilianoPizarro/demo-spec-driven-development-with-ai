# Instalación de la Extensión MTA

Este proyecto incluye scripts para descargar e instalar automáticamente la extensión Migration Toolkit for Applications (MTA) desde el repositorio [migtools/editor-extensions](https://github.com/migtools/editor-extensions).

## Instalación Automática

### En Windows (PowerShell)

Ejecuta el siguiente comando desde la raíz del proyecto:

```powershell
.\install-mta-extension.ps1
```

### En Linux/Mac (Bash)

Ejecuta el siguiente comando desde la raíz del proyecto:

```bash
chmod +x install-mta-extension.sh
./install-mta-extension.sh
```

### En Devfile (Che/CodeReady Workspaces)

La extensión se instalará automáticamente cuando se inicie el workspace gracias al comando `install-mta-extension` en el `devfile.yaml`.

## Instalación Manual

Si los scripts no funcionan, puedes instalar la extensión manualmente:

1. Descarga el archivo `.vsix` más reciente desde: https://github.com/migtools/editor-extensions/releases
2. Abre VS Code
3. Ve a Extensiones (Ctrl+Shift+X o Cmd+Shift+X)
4. Haz clic en los tres puntos (...) en la esquina superior derecha
5. Selecciona "Instalar desde VSIX..."
6. Navega hasta el archivo descargado y selecciónalo

## Verificación

Para verificar que la extensión está instalada:

1. Abre VS Code
2. Ve a Extensiones (Ctrl+Shift+X)
3. Busca "Migration Toolkit for Applications" o "MTA"
4. Deberías ver la extensión instalada

## Configuración

La extensión está configurada en `.vscode/settings.json` con el modo de agente GenAI habilitado:

```json
{
  "mta-vscode-extension.genai.agentMode": true
}
```

## Notas

- La extensión recomendada en `.vscode/extensions.json` es `redhat.mta-vscode-extension` (del marketplace oficial)
- Los scripts descargan la versión desde migtools/editor-extensions (fork con actualizaciones)
- Si prefieres usar la versión oficial del marketplace, simplemente instala `redhat.mta-vscode-extension` desde VS Code

