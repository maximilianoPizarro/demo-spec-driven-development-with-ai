# MTA Extension - Configuration

The MTA extension is configured in `.vscode/extensions.json` as recommended and will be automatically installed from the extension registry of the DevSpaces cluster.

## Configuration

### Recommended Extensions

The `.vscode/extensions.json` file contains:

```json
{
  "recommendations": ["Continue.continue", "redhat.mta-vscode-extension"]
}
```

### Extension Settings

The `.vscode/settings.json` file has MTA configuration with GenAI agent mode enabled:

```json
{
  "mta-vscode-extension.genai.agentMode": true
}
```

## Automatic Installation

The extension will be automatically installed when:

1. You open the workspace for the first time
2. VS Code detects recommended extensions in `.vscode/extensions.json`
3. The extension registry of the DevSpaces cluster downloads and installs the extension automatically

## Verification

To verify that the extension is installed:

1. Open VS Code in the workspace
2. Go to Extensions (Ctrl+Shift+X or Cmd+Shift+X)
3. Search for "Migration Toolkit for Applications" or "MTA"
4. You should see the extension installed

## Notes

- The extension is automatically downloaded from the registry configured in the DevSpaces cluster
- No scripts or manual installation required
- Configuration is ready to use with GenAI mode enabled

