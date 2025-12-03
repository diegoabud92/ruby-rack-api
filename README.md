# Ruby Rack API

API REST simple para gestión de productos usando Ruby, Rack y Cuba.

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

## Docker

```bash
docker-compose up --build
```

## Endpoints

- `POST /auth` - Obtener token
- `GET /products` - Listar productos (usa auth)
- `POST /products` - Crear producto (usa auth)
- `GET /products/:id` - Obtener producto (usa auth)
- `GET /products/last` - Último producto (usa auth)

## Ejemplos

### Autenticación

```bash
curl -X POST http://localhost:9292/auth \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"fudo"}'
```

**Respuesta exitosa (200):**
```json
{"token":"bf5c7686-9124-4b6c-aa61-d0a5a57478f3"}
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
[{"id":1,"name":"Pizza Napolitana"},{"id":2,"name":"Lasagna"}]
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
{"message":"Producto creado asincronamente, para obtener el producto use el endpoint GET /products/last"}
```

### Ver ultimo producto creado

```bash
curl http://localhost:9292/products/last \
  -H "Authorization: Bearer <TOKEN>"
```

**Respuesta:**
```json
{"id":3,"name":"Lasagna"}
```

### Buscar producto por ID

```bash
curl http://localhost:9292/products/3 \
  -H "Authorization: Bearer <TOKEN>"
```

**Respuesta:**
```json
{"id":3,"name":"Lasagna"}
```

### Compresion gzip

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

## Documentación de la API

La especificación OpenAPI está disponible en `/openapi.yaml`

## Links y documentación usada

- [A rack application from scratch - by Tommaso Pavese](https://tommaso.pavese.me/2016/06/05/a-rack-application-from-scratch-part-1-introducting-rack/#a-naive-and-incomplete-framework)
- [Ruby rack tutorial](https://thoughtbot.com/blog/ruby-rack-tutorial)
- [Rack Github](https://github.com/rack/rack/blob/main/README.md)
- [Cuba](https://www.rubydoc.info/gems/cuba)
- [Rack-test](https://github.com/rack/rack-test)
- [Rack::Deflater](https://thoughtbot.com/blog/content-compression-with-rack-deflater)
