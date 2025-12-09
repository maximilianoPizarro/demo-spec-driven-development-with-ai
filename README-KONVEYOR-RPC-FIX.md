# Konveyor Analyzer RPC Server Connection Error Fix

## Problem

The Konveyor Analyzer RPC Server is not starting, causing connection errors:

```
ENOENT: socket not found
ERR_STREAM_DESTROYED: stream destroyed
RPC connection error
```

## Root Cause

The RPC server may fail to start due to:
1. Invalid YAML configuration
2. Missing or incorrect environment variables
3. Server needs restart after configuration changes

## Solution Steps

### Step 1: Ensure Configuration is Processed

The `provider-settings.yaml` file now uses environment variable placeholders. Run the setup script to process it:

```bash
cd ${PROJECT_SOURCE}
chmod +x setup-konveyor-config.sh
./setup-konveyor-config.sh
```

This will:
- Copy `provider-settings.yaml` to `~/.konveyor/provider-settings.yaml`
- Replace `${LLM_SERVER_TOKEN}`, `${LLM_SERVER_URL}`, etc. with actual values
- Validate YAML syntax
- Export environment variables

### Step 2: Verify Configuration

Check that the processed configuration exists and is valid:

```bash
# Check if config file exists
ls -la ~/.konveyor/provider-settings.yaml

# Validate YAML syntax
python3 -c "import yaml; yaml.safe_load(open('${HOME}/.konveyor/provider-settings.yaml'))"

# Check for unexpanded variables
grep -n '\${' ~/.konveyor/provider-settings.yaml
```

If you see unexpanded variables (like `${LLM_SERVER_TOKEN}`), the script didn't run or environment variables weren't available.

### Step 3: Restart Konveyor Analyzer RPC Server

After updating the configuration, restart the RPC server:

**Option A: Via Command Palette**
1. Press `Ctrl+Shift+P` (or `Cmd+Shift+P` on Mac)
2. Type: `Konveyor: Restart Analyzer RPC Server`
3. Press Enter

**Option B: Reload VS Code Window**
1. Press `Ctrl+Shift+P` (or `Cmd+Shift+P` on Mac)
2. Type: `Developer: Reload Window`
3. Press Enter

**Option C: Restart VS Code**
- Close and reopen VS Code completely

### Step 4: Verify Server Started

After restarting, check the Konveyor logs:

1. Open VS Code Output panel (`View` → `Output`)
2. Select "Konveyor" or "Konveyor Analyzer" from the dropdown
3. Look for successful startup messages:

```
✓ Analyzer RPC server started successfully
✓ Connected to RPC server
```

Instead of:
```
✗ RPC connection error
✗ Socket not found
```

## Troubleshooting

### If RPC server still doesn't start:

1. **Check environment variables are set:**
   ```bash
   echo "LLM_SERVER_TOKEN: ${LLM_SERVER_TOKEN:+SET}"
   echo "LLM_SERVER_URL: ${LLM_SERVER_URL:+SET}"
   ```

2. **Run diagnostics:**
   ```bash
   cd ${PROJECT_SOURCE}
   chmod +x diagnose-konveyor.sh
   ./diagnose-konveyor.sh
   ```

3. **Manually verify config file:**
   ```bash
   cat ~/.konveyor/provider-settings.yaml
   ```
   
   Ensure all `${...}` placeholders are replaced with actual values.

4. **Check VS Code extension logs:**
   - Open `View` → `Output`
   - Select "Konveyor" or "Konveyor Analyzer"
   - Look for error messages

5. **Verify secret is applied:**
   ```bash
   # In Kubernetes/OpenShift
   kubectl get secret openapi-api-key -o yaml
   # or
   oc get secret openapi-api-key -o yaml
   ```

## Prevention

To avoid this issue in the future:

1. **Always use environment variables** in `provider-settings.yaml`:
   ```yaml
   OPENAI_API_KEY: "${LLM_SERVER_TOKEN}"
   baseURL: "${LLM_SERVER_URL}"
   ```

2. **Run setup script** after workspace starts (already in `postStart`)

3. **Restart RPC server** after any configuration changes

## Current Configuration

- **Source config**: `${PROJECT_SOURCE}/provider-settings.yaml` (uses placeholders)
- **Target config**: `~/.konveyor/provider-settings.yaml` (processed with actual values)
- **Setup script**: `${PROJECT_SOURCE}/setup-konveyor-config.sh`
- **Diagnostics**: `${PROJECT_SOURCE}/diagnose-konveyor.sh`

