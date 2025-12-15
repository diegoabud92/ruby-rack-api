# Ruby Rack API

API REST simple para gestión de productos usando Ruby, Rack y Cuba con autenticación JWT.

## Requisitos

- Ruby 3.4
- Bundler

## Instalación

```bash
bundle install
```

## Ejecutar

```bash
# Copiar variables de entorno
cp .env.example .env

# Iniciar servidor
bundle exec rackup
```

## Variables de Entorno

```bash
JWT_SECRET=tu_clave_secreta_para_jwt
```

## Docker

```bash
docker-compose up --build
```

## Endpoints

### Autenticación
- `POST /users` - Crear usuario
- `POST /auth` - Obtener token JWT

### Productos (requieren autenticación)
- `GET /products` - Listar productos
- `POST /products` - Crear producto (asíncrono)
- `GET /products/:id` - Obtener producto por ID

### Otros
- `GET /AUTHORS` - Información del autor
- `GET /openapi.yaml` - Especificación OpenAPI

## Ejemplos

### Crear usuario

```bash
curl -X POST http://localhost:9292/users \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"password"}'
```

**Respuesta exitosa (201):**
```json
{"message":"User created","user":{"id":1,"username":"admin"}}
```

### Autenticación

```bash
curl -X POST http://localhost:9292/auth \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"password"}'
```

**Respuesta exitosa (200):**
```json
{"token":"eyJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoxLCJ1c2VybmFtZSI6ImFkbWluIn0.abc123"}
```

**Respuesta error (401):**
```json
{"error":"Unauthorized"}
```

### Listar productos

```bash
curl http://localhost:9292/products \
  -H "Authorization: Bearer <TOKEN>"
```

**Respuesta:**
```json
[{"id":1,"name":"Pizza Napolitana","user_id":1},{"id":2,"name":"Lasagna","user_id":1}]
```

### Crear producto

```bash
curl -X POST http://localhost:9292/products \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <TOKEN>" \
  -d '{"name":"Pizza Napolitana"}'
```

**Respuesta (201):** La creación es asíncrona (tarda 5 segundos)
```json
{"message":"Producto creado asincronamente, para visualizar el producto use el endpoint GET /products/1"}
```

### Buscar producto por ID

```bash
curl http://localhost:9292/products/1 \
  -H "Authorization: Bearer <TOKEN>"
```

**Respuesta:**
```json
{"id":1,"name":"Pizza Napolitana","user_id":1}
```

### Compresión gzip

La API soporta compresión gzip cuando el cliente lo solicita:

```bash
curl -v --compressed http://localhost:9292/products \
  -H "Authorization: Bearer <TOKEN>"
```

**Headers de respuesta:**
```
Content-Encoding: gzip
Vary: Accept-Encoding
```

## Tests

```bash
bundle exec rspec app/spec/
```

## Arquitectura

```
app/
├── controllers/
│   ├── base_controller.rb    # Autenticación JWT
│   ├── products_controller.rb
│   └── users_controller.rb
├── models/
│   ├── base.rb               # Almacenamiento en PStore
│   ├── products.rb
│   └── users.rb
├── lib/
│   └── jwt_auth.rb           # JWT encode/decode
└── spec/
    ├── auth_spec.rb
    ├── products_spec.rb
    └── spec_helper.rb
```

## Seguridad

- **Passwords**: Hasheados con BCrypt
- **Tokens**: JWT firmados con HS256
- **Autenticación**: Bearer token en header `Authorization`

## Documentación de la API

La especificación OpenAPI está disponible en `/openapi.yaml`

## Links y documentación usada

- [A rack application from scratch - by Tommaso Pavese](https://tommaso.pavese.me/2016/06/05/a-rack-application-from-scratch-part-1-introducting-rack/#a-naive-and-incomplete-framework)
- [Ruby rack tutorial](https://thoughtbot.com/blog/ruby-rack-tutorial)
- [Rack Github](https://github.com/rack/rack/blob/main/README.md)
- [Cuba](https://www.rubydoc.info/gems/cuba)
- [Rack-test](https://github.com/rack/rack-test)
- [Rack::Deflater](https://thoughtbot.com/blog/content-compression-with-rack-deflater)
- [JWT Ruby Gem](https://github.com/jwt/ruby-jwt)
- [BCrypt Ruby](https://github.com/bcrypt-ruby/bcrypt-ruby)

## Notas

- Se utiliza PStore para el almacenamiento persistente de productos y usuarios
- La creación de productos es asíncrona (5 segundos de delay)
- Para un entorno de producción se recomienda usar Sidekiq para jobs asíncronos
