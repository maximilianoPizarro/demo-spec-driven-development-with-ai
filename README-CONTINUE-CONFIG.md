# Continue Configuration with Authentication

This project is configured to use Continue with the MaaS Llama-3-2-3b model. To work correctly, you need to configure authentication credentials.

## Error 403: Authentication failed

If you see the "403 Authentication failed" error when using Continue, it means the authentication token is missing.

## Solution: Configure Kubernetes Secret

The workspace is configured to read credentials from a Kubernetes Secret named `openapi-api-key`.

### 1. Create or Update the Secret

Make sure the `openapi-api-key` secret has the following variables configured:

```yaml
kind: Secret
apiVersion: v1
metadata:
  name: openapi-api-key
  labels:
    controller.devfile.io/mount-to-devworkspace: 'true'
    controller.devfile.io/watch-secret: 'true'
  annotations:
    controller.devfile.io/mount-as: env
stringData:
  LLM_SERVER_TOKEN: "your-token-here"
  LLM_SERVER_URL: "https://llama-3-2-3b-maas-apicast-production.apps.prod.rhoai.rh-aiservices-bu.com:443/v1"
type: Opaque
```

### 2. Required Environment Variables

- **`LLM_SERVER_TOKEN`**: Authentication token for the LLM model (required)
- **`LLM_SERVER_URL`**: API base URL (optional, has a default value)
- **`OPENAI_API_KEY`**: Alternative to `LLM_SERVER_TOKEN` if not available

### 3. Apply the Secret

```bash
oc apply -f secret.yaml
```

Or create the secret manually:

```bash
oc create secret generic openapi-api-key \
  --from-literal=LLM_SERVER_TOKEN="your-token" \
  --from-literal=LLM_SERVER_URL="https://llama-3-2-3b-maas-apicast-production.apps.prod.rhoai.rh-aiservices-bu.com:443/v1" \
  --dry-run=client -o yaml | \
  oc label -f - \
    controller.devfile.io/mount-to-devworkspace=true \
    controller.devfile.io/watch-secret=true \
    --local -o yaml | \
  oc annotate -f - \
    controller.devfile.io/mount-as=env \
    --local -o yaml | \
  oc apply -f -
```

### 4. Restart the Workspace

After creating or updating the secret, restart the workspace so environment variables are loaded:

1. Stop the current workspace
2. Start a new workspace from the devfile

The `setup-continue-config.sh` script will run automatically on startup and configure Continue with the correct credentials.

## Verification

To verify that the configuration is correct:

1. Open VS Code in the workspace
2. Open Continue (Ctrl+Shift+P > "Continue")
3. Try asking the model a question
4. If it works, you'll see the model's response. If you see a 403 error, verify that the secret is configured correctly.

## File Structure

- `continue-config.json`: Template with placeholders for environment variables
- `setup-continue-config.sh`: Script that processes the template and creates the final configuration in `/home/user/.continue/config.json`
- `devfile.yaml`: Workspace configuration that runs the script on startup
- `secret.yaml`: Kubernetes secret template (update with your real credentials)

## Notes

- The token should never be in source code. Always use Kubernetes secrets.
- The `continue-config.json` file in the repository contains placeholders, not real credentials.
- The final configuration is generated in `/home/user/.continue/config.json` when the workspace starts.
