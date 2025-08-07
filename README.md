# Spec-Driven Development with AI in Eclipse Che

This repository provides a template to demonstrate and experiment with the concept of **Specification-Driven Development** using AI assistants in a pre-configured Eclipse Che workspace.

The goal is for you to define an application's requirements in the [spec.md](./spec.md) file and then use AI tools ([`RA.Aid`](https://www.ra-aid.ai/) and [`Aider`](https://aider.chat/#getting-started)) to autonomously generate the code.

## How to Use This Template

### 1. Launch the Workspace

Use the [`devfile.yaml`](./devfile.yaml) in this repository to create a new workspace in Eclipse Che or Red Hat OpenShift Dev Spaces. This will automatically pull a pre-configured container image with all the necessary AI tools installed.

### 2. Configure Your API Key

The AI assistants require an API key from a Large Language Model (LLM) provider to function. `RA.Aid` and `Aider` are flexible and support many providers, including Gemini, OpenAI, Anthropic, Groq, and more.

The recommended way to provide your key is by creating a Kubernetes `Secret`. The workspace is configured to automatically mount this secret as an environment variable.

For example, to use the Gemini API, you would create a secret for the `GEMINI_API_KEY` environment variable like this:

```sh
oc apply -f - <<EOF
kind: Secret
apiVersion: v1
metadata:
  name: gemini-api-key
  labels:
    controller.devfile.io/mount-to-devworkspace: 'true'
    controller.devfile.io/watch-secret: 'true'
  annotations:
    controller.devfile.io/mount-as: env
data:
  GEMINI_API_KEY: [base64 encoded Gemini API key]
type: Opaque
EOF
```

If you prefer to use a different provider, simply consult the `RA.Aid` or `Aider` documentation for the correct environment variable name (e.g., `OPENAI_API_KEY`) and adapt the secret accordingly.

### 3. Write Your Specification

Edit the [`spec.md`](./spec.md) file to describe the application you want to build. Be as detailed as possible, defining user stories, UI/UX, API endpoints, data models, and technologies.

### 4. Run the AI Agent

Once you have crafted your specification, run this command in the workspace terminal:

```sh
ra-aid --use-aider --cowboy-mode --show-cost --track-cost --msg-file spec.md
```

The AI will read your specification and begin building your application.

## Example Project: URL Shortener

To see a complete, working example, check out the [`demo-url-shortener`](https://github.com/akurinnoy/demo-spec-driven-development-with-ai/tree/demo-url-shortener) branch. It contains the exact [spec.md](https://github.com/akurinnoy/demo-spec-driven-development-with-ai/blob/demo-url-shortener/spec.md) used to generate a full-stack URL shortener and all of the resulting source code.
