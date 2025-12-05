# Configuración de Continue con Autenticación

Este proyecto está configurado para usar Continue con el modelo MaaS Llama-3-2-3b. Para que funcione correctamente, necesitas configurar las credenciales de autenticación.

## Error 403: Authentication failed

Si ves el error "403 Authentication failed" al usar Continue, significa que falta configurar el token de autenticación.

## Solución: Configurar el Secret de Kubernetes

El workspace está configurado para leer las credenciales desde un Secret de Kubernetes llamado `openapi-api-key`.

### 1. Crear o actualizar el Secret

Asegúrate de que el secret `openapi-api-key` tenga las siguientes variables configuradas:

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
  LLM_SERVER_TOKEN: "tu-token-aqui"
  LLM_SERVER_URL: "https://llama-3-2-3b-maas-apicast-production.apps.prod.rhoai.rh-aiservices-bu.com:443/v1"
type: Opaque
```

### 2. Variables de entorno requeridas

- **`LLM_SERVER_TOKEN`**: Token de autenticación para el modelo LLM (requerido)
- **`LLM_SERVER_URL`**: URL base del API (opcional, tiene un valor por defecto)
- **`OPENAI_API_KEY`**: Alternativa a `LLM_SERVER_TOKEN` si no está disponible

### 3. Aplicar el Secret

```bash
oc apply -f secret.yaml
```

O crea el secret manualmente:

```bash
oc create secret generic openapi-api-key \
  --from-literal=LLM_SERVER_TOKEN="tu-token" \
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

### 4. Reiniciar el workspace

Después de crear o actualizar el secret, reinicia el workspace para que las variables de entorno se carguen:

1. Detén el workspace actual
2. Inicia un nuevo workspace desde el devfile

El script `setup-continue-config.sh` se ejecutará automáticamente al iniciar y configurará Continue con las credenciales correctas.

## Verificación

Para verificar que la configuración es correcta:

1. Abre VS Code en el workspace
2. Abre Continue (Ctrl+Shift+P > "Continue")
3. Intenta hacer una pregunta al modelo
4. Si funciona, verás la respuesta del modelo. Si ves un error 403, verifica que el secret esté configurado correctamente.

## Estructura de archivos

- `continue-config.json`: Template con placeholders para variables de entorno
- `setup-continue-config.sh`: Script que procesa el template y crea la configuración final en `/home/user/.continue/config.json`
- `devfile.yaml`: Configuración del workspace que ejecuta el script al iniciar
- `secret.yaml`: Template del secret de Kubernetes (actualiza con tus credenciales reales)

## Notas

- El token nunca debe estar en el código fuente. Siempre usa secrets de Kubernetes.
- El archivo `continue-config.json` en el repositorio contiene placeholders, no credenciales reales.
- La configuración final se genera en `/home/user/.continue/config.json` cuando se inicia el workspace.

