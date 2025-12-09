# VS Code Extensions Visibility Issues

## Problem

Extensions like Continue and MTA are installed but don't appear in the Command Palette or are not visible.

## Common Causes

1. **Extensions are installed but not activated**
2. **VS Code needs to be reloaded**
3. **Extensions are disabled**
4. **Extension host needs restart**

## Solutions

### Solution 1: Reload VS Code Window

The simplest solution is to reload the VS Code window:

1. Press `Ctrl+Shift+P` (or `Cmd+Shift+P` on Mac)
2. Type: `Developer: Reload Window`
3. Press Enter

This will reload the window and activate all installed extensions.

### Solution 2: Check Extension Status

Verify that extensions are installed and enabled:

1. Press `Ctrl+Shift+X` (or `Cmd+Shift+X` on Mac) to open Extensions panel
2. Search for "Continue" or "MTA"
3. Check the status:
   - **Installed** ✓ - Extension is installed
   - **Enabled** ✓ - Extension is active
   - **Disabled** ✗ - Click "Enable" to activate

### Solution 3: Enable Extensions Manually

If extensions show as disabled:

1. Open Extensions panel (`Ctrl+Shift+X`)
2. Find the extension (Continue or MTA)
3. Click the **"Enable"** button
4. Reload the window if prompted

### Solution 4: Restart Extension Host

Sometimes the extension host needs to be restarted:

1. Press `Ctrl+Shift+P` (or `Cmd+Shift+P` on Mac)
2. Type: `Developer: Restart Extension Host`
3. Press Enter

### Solution 5: Check Extension Commands

After reloading, check if commands are available:

1. Press `Ctrl+Shift+P` to open Command Palette
2. Type the extension name:
   - For **Continue**: Type `Continue` - you should see commands like:
     - `Continue: Open Continue`
     - `Continue: Toggle Continue`
   - For **MTA**: Type `MTA` - you should see commands like:
     - `MTA: Analyze Application`
     - `MTA: Generate Report`

### Solution 6: Verify Extension Installation

Run the verification script:

```bash
cd ${PROJECT_SOURCE}
chmod +x verify-extensions.sh
./verify-extensions.sh
```

This will check if extensions are installed and provide troubleshooting steps.

## Extension-Specific Instructions

### Continue Extension

**Extension ID:** `Continue.continue`

**Commands to look for:**
- `Continue: Open Continue`
- `Continue: Toggle Continue`
- `Continue: New Chat`

**Verification:**
1. Open Command Palette (`Ctrl+Shift+P`)
2. Type `Continue:`
3. You should see Continue commands listed

**If not visible:**
1. Check Extensions panel - ensure it's enabled
2. Reload window (`Developer: Reload Window`)
3. Check Output panel for errors (`View` → `Output` → Select "Continue")

### MTA Extension

**Extension IDs:**
- `redhat.mta-vscode-extension` (Red Hat MTA)
- `konveyor.vscode-mta` (Konveyor MTA)

**Commands to look for:**
- `MTA: Analyze Application`
- `MTA: Generate Report`
- `MTA: View Analysis Results`

**Verification:**
1. Open Command Palette (`Ctrl+Shift+P`)
2. Type `MTA:`
3. You should see MTA commands listed

**If not visible:**
1. Check Extensions panel - ensure it's enabled
2. Reload window (`Developer: Reload Window`)
3. Check Output panel for errors (`View` → `Output` → Select "MTA")

## Troubleshooting

### Check Extension Logs

1. Open VS Code Output panel:
   - `View` → `Output`
   - Or press `Ctrl+Shift+U` (or `Cmd+Shift+U` on Mac)

2. Select extension log:
   - For Continue: Select "Continue" from dropdown
   - For MTA: Select "MTA" or "Migration Toolkit" from dropdown

3. Look for error messages:
   - Extension activation errors
   - Missing dependencies
   - Configuration errors

### Check Extension Host Logs

1. Open Output panel (`View` → `Output`)
2. Select "Log (Extension Host)" from dropdown
3. Look for errors related to Continue or MTA

### Verify Configuration Files

Check that configuration files exist:

```bash
# Check extensions.json
cat .vscode/extensions.json

# Check settings.json
cat .vscode/settings.json
```

### Manual Extension Installation

If extensions are not installing automatically:

1. Open Extensions panel (`Ctrl+Shift+X`)
2. Search for extension ID:
   - `Continue.continue`
   - `redhat.mta-vscode-extension`
   - `konveyor.vscode-mta`
3. Click "Install"
4. Reload window after installation

## Prevention

To ensure extensions are always visible:

1. **Keep extensions enabled** - Don't disable them unless necessary
2. **Reload after workspace changes** - Reload window after modifying `.vscode/extensions.json`
3. **Check extension status** - Periodically verify extensions are enabled
4. **Update extensions** - Keep extensions updated to latest versions

## Still Having Issues?

If extensions still don't appear after trying all solutions:

1. **Check VS Code version compatibility**
2. **Check extension compatibility** with VS Code Server/Remote
3. **Review extension documentation** for specific requirements
4. **Contact extension support** or open an issue on GitHub

## Quick Reference

| Action | Command Palette |
|--------|----------------|
| Reload Window | `Developer: Reload Window` |
| Restart Extension Host | `Developer: Restart Extension Host` |
| Open Extensions | `Extensions: Show Extensions` |
| Open Continue | `Continue: Open Continue` |
| Open MTA | `MTA: Analyze Application` |

