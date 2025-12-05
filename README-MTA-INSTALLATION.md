# Extensión MTA - Configuración

La extensión MTA está configurada en `.vscode/extensions.json` como recomendada y se instalará automáticamente desde el registry de extensiones del cluster de DevSpaces.

## Configuración

### Extensiones Recomendadas

El archivo `.vscode/extensions.json` contiene:

```json
{
  "recommendations": ["Continue.continue", "redhat.mta-vscode-extension"]
}
```

### Configuración de la Extensión

El archivo `.vscode/settings.json` tiene la configuración de MTA con el modo de agente GenAI habilitado:

```json
{
  "mta-vscode-extension.genai.agentMode": true
}
```

## Instalación Automática

La extensión se instalará automáticamente cuando:

1. Abres el workspace por primera vez
2. VS Code detecta las extensiones recomendadas en `.vscode/extensions.json`
3. El registry de extensiones del cluster de DevSpaces descarga e instala la extensión automáticamente

## Verificación

Para verificar que la extensión está instalada:

1. Abre VS Code en el workspace
2. Ve a Extensiones (Ctrl+Shift+X o Cmd+Shift+X)
3. Busca "Migration Toolkit for Applications" o "MTA"
4. Deberías ver la extensión instalada

## Notas

- La extensión se descarga automáticamente desde el registry configurado en el cluster de DevSpaces
- No se requieren scripts ni instalación manual
- La configuración está lista para usar con el modo GenAI habilitado

