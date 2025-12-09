# PostStart Optimization

## Problem

The `postStart` hook was timing out because commands were taking too long to execute.

## Solution

All setup commands have been moved out of `postStart` to avoid timeouts. They are now available as manual commands that you can run when needed.

## Available Commands

Run these commands manually after the workspace starts:

1. **Quick Maven Check** - `quick-maven-check`
   - Fast verification if Maven is available
   - Run this first to check if Maven is already installed

2. **Setup Maven for Konveyor** - `setup-maven`
   - Full Maven installation if needed
   - Run this if Maven is not available

3. **Configure Continue AI and Konveyor** - `copyconfig`
   - Sets up Continue AI and Konveyor configuration
   - Processes environment variables and creates config files
   - Run this after workspace starts to configure AI tools

## Recommended Workflow

After workspace starts:

1. **Check Maven** (if using Konveyor):
   ```bash
   # Run command: "Quick Maven Check"
   # Or manually:
   cd ${PROJECT_SOURCE}
   ./quick-setup-maven.sh
   ```

2. **Install Maven if needed**:
   ```bash
   # Run command: "2. Setup Maven for Konveyor"
   # Or manually:
   cd ${PROJECT_SOURCE}
   ./setup-maven.sh
   ```

3. **Configure AI tools**:
   ```bash
   # Run command: "3. Configure Continue AI and Konveyor"
   # Or manually:
   cd ${PROJECT_SOURCE}
   ./setup-continue-config.sh
   ./setup-konveyor-config.sh
   ```

## Why This Approach?

- **Faster workspace startup**: No delays from postStart hooks
- **No timeouts**: Commands run on-demand when you need them
- **Better control**: You decide when to run setup commands
- **Easier debugging**: You can see output and fix issues immediately

## Automatic Setup (Optional)

If you want automatic setup, you can add commands back to `postStart`, but be aware:
- Commands must complete in < 60 seconds
- Long-running operations will timeout
- Use only quick verification scripts

