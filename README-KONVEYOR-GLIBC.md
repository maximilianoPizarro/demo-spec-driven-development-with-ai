# Konveyor External Providers - GLIBC Compatibility Issue

## Problem

The Konveyor external providers (Java and JavaScript) require GLIBC 2.32 or higher, but UBI8 (Red Hat Universal Base Image 8) only includes GLIBC 2.28.

**Error Message:**
```
/lib64/libc.so.6: version `GLIBC_2.32' not found
/lib64/libc.so.6: version `GLIBC_2.34' not found
```

## Solution

The devfile has been updated to use `ubi9-latest` instead of `ubi8-latest`, which includes a newer version of GLIBC that should be compatible with the Konveyor external providers.

## Alternative Solutions

If UBI9 doesn't resolve the issue, you can try:

### Option 1: Use a different base image

Update the devfile to use a more recent base image:

```yaml
image: quay.io/devfile/universal-developer-image:ubi9-latest
```

Or try the latest tag:

```yaml
image: quay.io/devfile/universal-developer-image:latest
```

### Option 2: Use a Debian/Ubuntu-based image

If Red Hat images don't work, you can use a Debian-based image:

```yaml
image: mcr.microsoft.com/devcontainers/base:ubuntu-22.04
```

Then install the required tools manually in the devfile.

### Option 3: Check GLIBC version

To check the GLIBC version in your container:

```bash
ldd --version
```

Or check what versions are available:

```bash
strings /lib64/libc.so.6 | grep GLIBC
```

### Option 4: Contact Konveyor team

If none of the above solutions work, this might be a known issue with the Konveyor extension. Consider:
- Opening an issue on the Konveyor GitHub repository
- Checking if there's a version of the extension compatible with older GLIBC versions
- Using the extension without external providers (limited functionality)

## Verification

After updating the image, restart your workspace and check the Konveyor logs:

1. Open VS Code Output panel
2. Select "Konveyor" or "Konveyor Analyzer" from the dropdown
3. Look for successful provider startup messages

You should see messages like:
```
java-external-provider started successfully
javascript-external-provider started successfully
```

Instead of:
```
java-external-provider crashed with code 1
javascript-external-provider crashed with code 1
```

## Current Configuration

The devfile is currently configured to use:
- **Image**: `quay.io/devfile/universal-developer-image:latest`
- **Expected GLIBC**: Should be 2.34+ (compatible with Konveyor providers)

## Important: Restart Required

**After changing the image in devfile.yaml, you MUST restart your workspace** for the changes to take effect:

1. Stop the current workspace
2. Delete the workspace (or wait for it to be recreated)
3. Start a new workspace from the updated devfile

The workspace will continue using the old image until it's restarted.

