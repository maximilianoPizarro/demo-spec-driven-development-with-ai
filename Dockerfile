FROM quay.io/devfile/universal-developer-image:ubi8-latest

# Metadatos
LABEL maintainer="maximilianopizarro"
LABEL description="Universal Developer Image with MTA VS Code Extension pre-installed"
LABEL version="1.0.0"

# Variables de entorno
ENV VSIX_URL=https://github.com/migtools/editor-extensions/releases/download/v8.0.2/mta-vscode-extension-8.0.2.vsix
ENV VSIX_FILE=/tmp/mta-vscode-extension.vsix
ENV EXT_DIR=/home/user/.vscode-server/extensions

# Instalar unzip si no está disponible
USER root
RUN if ! command -v unzip >/dev/null 2>&1; then \
        if command -v yum >/dev/null 2>&1; then \
            yum install -y unzip && yum clean all; \
        elif command -v dnf >/dev/null 2>&1; then \
            dnf install -y unzip && dnf clean all; \
        elif command -v apt-get >/dev/null 2>&1; then \
            apt-get update && apt-get install -y unzip && apt-get clean && rm -rf /var/lib/apt/lists/*; \
        fi; \
    fi

# Crear directorio de extensiones y cambiar permisos
RUN mkdir -p ${EXT_DIR} && \
    chown -R user:user ${EXT_DIR}

# Volver al usuario original
USER user

# Descargar e instalar la extensión MTA
RUN echo "Descargando extensión MTA desde migtools/editor-extensions..." && \
    curl -L -o ${VSIX_FILE} ${VSIX_URL} || wget -O ${VSIX_FILE} ${VSIX_URL} && \
    echo "Instalando extensión MTA..." && \
    TEMP_DIR=$(mktemp -d) && \
    unzip -q ${VSIX_FILE} -d ${TEMP_DIR} && \
    EXT_ID=$(grep -o '"name": "[^"]*"' ${TEMP_DIR}/package.json | head -1 | cut -d'"' -f4) && \
    EXT_VERSION=$(grep -o '"version": "[^"]*"' ${TEMP_DIR}/package.json | head -1 | cut -d'"' -f4) && \
    TARGET_DIR=${EXT_DIR}/${EXT_ID}-${EXT_VERSION} && \
    mv ${TEMP_DIR} ${TARGET_DIR} && \
    echo "✅ Extensión MTA instalada: ${EXT_ID}-${EXT_VERSION}" && \
    rm -f ${VSIX_FILE} && \
    echo "Extensión MTA pre-instalada exitosamente"

# Verificar la instalación
RUN if [ -d "${EXT_DIR}" ] && [ "$(ls -A ${EXT_DIR})" ]; then \
        echo "Extensiones instaladas:" && \
        ls -la ${EXT_DIR}; \
    else \
        echo "Advertencia: No se encontraron extensiones instaladas"; \
    fi

# Mantener el working directory y usuario por defecto de la imagen base
WORKDIR /projects

