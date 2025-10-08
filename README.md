# glintstone

[![Package Version](https://img.shields.io/hexpm/v/glintstone)](https://hex.pm/packages/glintstone)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/glintstone/)

Type safe http clients based on OpenAPI specs

## Installation

```sh
gleam add glintstone@1
```

## Usage

```sh
gleam run -- 'example/api.json' '/path/to/client.gleam'
```

## Development

```sh
gleam run   # Run the project
gleam test  # Run the tests
```

## TODO

- [ ] Implement the full OpenApi spec
- [ ] Check for paths which might lead to inconsistency, e.g. '/users/posts' & '/posts/users'
- [ ] Write tests for generated code
