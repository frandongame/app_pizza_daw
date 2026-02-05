FROM php:8.2-fpm

# 1. Instalar dependencias del sistema y extensiones PHP necesarias
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip \
    libpq-dev \
    nginx

# 2. Limpiar cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# 3. Instalar extensiones de PHP (importante pgsql para Postgres)
RUN docker-php-ext-install pdo_pgsql mbstring exif pcntl bcmath gd

# 4. Obtener Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# 5. Configurar directorio de trabajo
WORKDIR /var/www

# 6. Copiar el proyecto
COPY . .

# 7. Instalar dependencias de Laravel
RUN composer install --no-dev --optimize-autoloader

# 8. Dar permisos a la carpeta de almacenamiento
RUN chown -R www-data:www-data /var/www/storage /var/www/bootstrap/cache

# 9. Copiar configuración de Nginx (crearemos este archivo abajo)
COPY docker/nginx.conf /etc/nginx/sites-available/default

# 10. Copiar script de arranque
COPY docker/startup.sh /usr/local/bin/startup.sh
RUN chmod +x /usr/local/bin/startup.sh

# 11. Exponer el puerto
EXPOSE 8080

# 12. Comando de inicio
CMD ["/usr/local/bin/startup.sh"]