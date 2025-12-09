# Konveyor Troubleshooting Guide

## Common Issues and Solutions

### Issue 1: "panic: unable to get build tool"

**Error Message:**
```
panic: unable to get build tool
```

**Cause:**
The Konveyor analyzer requires Maven (or Gradle) to analyze Java projects, but Maven is not available or not in the PATH.

**Solution:**

1. **Automatic Setup (Recommended):**
   The devfile now includes `setup-maven` in `postStart` events, which will automatically install Maven when the workspace starts.

2. **Manual Setup:**
   If Maven is still not available, run:
   ```bash
   cd ${PROJECT_SOURCE}
   chmod +x setup-maven.sh
   ./setup-maven.sh
   ```

3. **Verify Maven Installation:**
   ```bash
   mvn --version
   ```

4. **Restart Konveyor Analyzer:**
   After installing Maven, restart the analyzer:
   - Command Palette (`Ctrl+Shift+P`) → `Konveyor: Restart Analyzer RPC Server`
   - Or reload the window: `Developer: Reload Window`

### Issue 2: "401 You didn't provide an API key"

**Error Message:**
```
401 You didn't provide an API key. You need to provide your API key in an Authorization header using Bearer auth
```

**Cause:**
The API key is not being sent correctly to the LLM server. This can happen if:
- Environment variables are not set
- The configuration file has unexpanded variables
- The API key format is incorrect

**Solution:**

1. **Verify Environment Variables:**
   ```bash
   echo "LLM_SERVER_TOKEN: ${LLM_SERVER_TOKEN:+SET}"
   echo "LLM_SERVER_URL: ${LLM_SERVER_URL:+SET}"
   ```

2. **Run Configuration Script:**
   ```bash
   cd ${PROJECT_SOURCE}
   chmod +x setup-konveyor-config.sh
   ./setup-konveyor-config.sh
   ```

3. **Verify Processed Configuration:**
   ```bash
   # Check VS Code Server location (primary)
   cat ~/.checode/remote/data/User/globalStorage/konveyor.konveyor/provider-settings.yaml | grep -A 10 "&active"
   
   # Or check fallback location
   cat ~/.konveyor/provider-settings.yaml | grep -A 10 "&active"
   ```
   
   You should see:
   ```yaml
   apiKey: "your-actual-token-here"  # NOT ${LLM_SERVER_TOKEN}
   baseURL: "https://your-api-url.com/v1"  # NOT ${LLM_SERVER_URL}
   ```

4. **Test Configuration:**
   ```bash
   cd ${PROJECT_SOURCE}
   chmod +x test-konveyor-config.sh
   ./test-konveyor-config.sh
   ```

5. **Verify Secret is Applied:**
   ```bash
   # For Kubernetes
   kubectl get secret openapi-api-key
   
   # For OpenShift
   oc get secret openapi-api-key
   ```

6. **Restart Konveyor:**
   After fixing the configuration:
   - Command Palette → `Konveyor: Restart Analyzer RPC Server`
   - Or reload the window

### Issue 3: RPC Connection Errors

**Error Messages:**
```
ECONNREFUSED /tmp/vscode-*.sock
RPC connection error
```

**Cause:**
The analyzer RPC server crashed or failed to start, often due to:
- Missing build tools (Maven/Gradle)
- Invalid configuration
- GLIBC compatibility issues

**Solution:**

1. **Check Analyzer Logs:**
   - Open VS Code Output panel (`View` → `Output`)
   - Select "Konveyor" or "Konveyor Analyzer"
   - Look for error messages

2. **Verify Build Tools:**
   ```bash
   mvn --version  # For Maven projects
   # or
   gradle --version  # For Gradle projects
   ```

3. **Check Configuration:**
   ```bash
   cd ${PROJECT_SOURCE}
   ./test-konveyor-config.sh
   ```

4. **Restart Everything:**
   - Stop the workspace
   - Start a new workspace
   - Or restart VS Code completely

## Diagnostic Scripts

### Available Scripts:

1. **`setup-maven.sh`** - Installs/verifies Maven
2. **`setup-konveyor-config.sh`** - Processes provider-settings.yaml with environment variables
3. **`test-konveyor-config.sh`** - Tests configuration and API connection
4. **`verify-konveyor-api-key.sh`** - Verifies API key configuration
5. **`diagnose-konveyor.sh`** - General diagnostics

### Running Diagnostics:

```bash
cd ${PROJECT_SOURCE}

# Check Maven
chmod +x setup-maven.sh && ./setup-maven.sh

# Check configuration
chmod +x test-konveyor-config.sh && ./test-konveyor-config.sh

# Verify API key
chmod +x verify-konveyor-api-key.sh && ./verify-konveyor-api-key.sh
```

## Configuration Files

- **Source Config**: `${PROJECT_SOURCE}/provider-settings.yaml` (uses placeholders)
- **Processed Config (VS Code Server)**: `~/.checode/remote/data/User/globalStorage/konveyor.konveyor/provider-settings.yaml` (primary location)
- **Processed Config (fallback)**: `~/.konveyor/provider-settings.yaml` (for compatibility)
- **Secret**: `${PROJECT_SOURCE}/secret.yaml` (Kubernetes secret definition)

**Note:** The Konveyor extension reads from VS Code Server's global storage directory. The setup script copies to both locations.

## Verification Checklist

- [ ] Maven is installed and in PATH (`mvn --version`)
- [ ] Environment variables are set (`echo $LLM_SERVER_TOKEN`)
- [ ] Configuration file exists (`ls ~/.checode/remote/data/User/globalStorage/konveyor.konveyor/provider-settings.yaml`)
- [ ] Configuration has no unexpanded variables (`grep '\${' ~/.checode/remote/data/User/globalStorage/konveyor.konveyor/provider-settings.yaml`)
- [ ] API key is in args (`grep apiKey ~/.checode/remote/data/User/globalStorage/konveyor.konveyor/provider-settings.yaml`)
- [ ] Secret is applied (`kubectl get secret openapi-api-key`)
- [ ] Analyzer RPC server is running (check VS Code Output panel)

## Still Having Issues?

1. **Check VS Code Output Panel:**
   - `View` → `Output`
   - Select "Konveyor" or "Konveyor Analyzer"
   - Look for specific error messages

2. **Check Extension Logs:**
   - `View` → `Output`
   - Select "Log (Extension Host)"
   - Look for Konveyor-related errors

3. **Restart Everything:**
   - Restart Konveyor Analyzer RPC Server
   - Reload VS Code window
   - Restart workspace if needed

4. **Contact Support:**
   - Konveyor GitHub Issues: https://github.com/konveyor/konveyor/issues
   - Include logs from VS Code Output panel
   - Include output from diagnostic scripts

