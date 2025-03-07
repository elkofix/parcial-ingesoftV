# Usa una imagen base ligera de Node.js
FROM node:18-alpine

# Establece el directorio de trabajo
WORKDIR /app

# Copia solo los archivos necesarios para instalar dependencias
# lo hago primero para evitar invalidaciones de caché
COPY package*.json ./

# Instala dependencias con npm ci para mayor consistencia y rendimiento
# porque omite la resolucion de versiones
RUN npm ci --only=production

# Copia el resto de los archivos de la aplicación
COPY . .

# Define la variable de entorno para producción
ENV NODE_ENV=production

# Expone el puerto de la aplicación
EXPOSE 8080

# Comando para ejecutar la aplicación
CMD ["node", "app.js"]
