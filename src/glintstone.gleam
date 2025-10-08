import argv
import gleam/dict.{type Dict}
import gleam/dynamic.{type Dynamic}
import gleam/dynamic/decode
import gleam/io
import gleam/json
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result
import gleam/string
import simplifile

// Core OpenAPI spec types
pub type OpenApiSpec {
  OpenApiSpec(
    info: Info,
    paths: Dict(String, PathItem),
    components: Option(Components),
    servers: Option(List(ServerInfo)),
  )
}

pub type Info {
  Info(title: String, version: String)
}

pub type ServerInfo {
  ServerInfo(url: String, description: String)
}

pub type Components {
  Components(schemas: Dict(String, Schema))
}

pub type PathItem {
  PathItem(
    get: Option(Operation),
    post: Option(Operation),
    put: Option(Operation),
    delete: Option(Operation),
    parameters: List(Parameter),
  )
}

pub type Operation {
  Operation(
    operation_id: Option(String),
    summary: Option(String),
    parameters: List(Parameter),
    request_body: Option(RequestBody),
    responses: Dict(String, Response),
    security: Option(List(Dict(String, Dynamic))),
  )
}

pub type Parameter {
  Parameter(name: String, in: ParameterLocation, required: Bool, schema: Schema)
}

pub type ParameterLocation {
  PathParam
  QueryParam
  HeaderParam
  CookieParam
}

pub type RequestBody {
  RequestBody(content: Dict(String, MediaType), required: Bool)
}

pub type Example {
  Example(
    summary: Option(String),
    description: Option(String),
    value: Option(Dynamic),
    external_value: Option(Dynamic),
  )
}

pub type MediaType {
  MediaType(schema: Option(Schema), examples: Option(Dict(String, Example)))
}

pub type Response {
  Response(description: String, content: Option(Dict(String, MediaType)))
}

pub type BearerScheme {
  BearerScheme(sec_type: String, scheme: String, format: String)
}

pub type Schema {
  ObjectSchema(properties: Dict(String, Schema), required: List(String))
  ArraySchema(items: Schema)
  StringSchema(format: Option(String), example: Option(String))
  IntegerSchema(format: Option(String), example: Option(Int))
  NumberSchema(format: Option(String), example: Option(Float))
  DateTimeSchema(format: Option(String))
  BooleanSchema
  RefSchema(ref: String)
  SecuritySchemas(bearer: Option(BearerScheme))
  DynamicSchema(object: Dict(String, Dynamic))
}

// ============================================================================
// Code Generation Types
// ============================================================================

pub type GeneratedClient {
  GeneratedClient(types: String, builders: String, examples: String)
}

pub type PathSegment {
  StaticSegment(name: String)
  ParameterSegment(name: String, param_type: String)
}

pub type ApiEndpoint {
  ApiEndpoint(
    path_segments: List(PathSegment),
    method: HttpMethod,
    operation_id: String,
    parameters: List(Parameter),
    request_body: Option(RequestBody),
    response_type: String,
    builder_chain: List(String),
  )
}

pub type HttpMethod {
  Get
  Post
  Put
  Delete
}

// ============================================================================
// OpenAPI JSON Parsing
// ============================================================================

pub fn parse_openapi_spec(json_string: String) -> Result(OpenApiSpec, String) {
  json.parse(from: json_string, using: openapi_decoder())
  |> result.map_error(fn(_) { "Failed to parse OpenAPI JSON" })
}

pub fn openapi_decoder() {
  use info <- decode.field("info", info_decoder())
  use paths <- decode.field("paths", dict_decoder(path_item_decoder()))
  use servers <- decode.optional_field(
    "servers",
    None,
    decode.optional(decode.list(server_info_decoder())),
  )
  use components <- decode.optional_field(
    "components",
    None,
    decode.optional(components_decoder()),
  )
  decode.success(OpenApiSpec(
    info: info,
    paths: paths,
    components: components,
    servers:,
  ))
}

pub fn info_decoder() -> decode.Decoder(Info) {
  use title <- decode.field("title", decode.string)
  use version <- decode.field("version", decode.string)
  decode.success(Info(title:, version:))
}

pub fn server_info_decoder() -> decode.Decoder(ServerInfo) {
  use url <- decode.field("url", decode.string)
  use description <- decode.field("description", decode.string)
  decode.success(ServerInfo(url:, description:))
}

pub fn components_decoder() {
  use schemas <- decode.field("schemas", dict_decoder(schema_decoder()))
  decode.success(Components(schemas:))
}

pub fn path_item_decoder() -> decode.Decoder(PathItem) {
  use get <- decode.optional_field(
    "get",
    None,
    decode.optional(operation_decoder()),
  )
  use post <- decode.optional_field(
    "post",
    None,
    decode.optional(operation_decoder()),
  )
  use put <- decode.optional_field(
    "put",
    None,
    decode.optional(operation_decoder()),
  )
  use delete <- decode.optional_field(
    "delete",
    None,
    decode.optional(operation_decoder()),
  )
  use parameters <- decode.optional_field(
    "parameters",
    [],
    decode.list(parameter_decoder()),
  )
  decode.success(PathItem(
    get: get,
    post: post,
    put: put,
    delete: delete,
    parameters: parameters,
  ))
}

pub fn operation_decoder() -> decode.Decoder(Operation) {
  use operation_id <- decode.optional_field(
    "operationId",
    None,
    decode.optional(decode.string),
  )
  use summary <- decode.optional_field(
    "summary",
    None,
    decode.optional(decode.string),
  )
  use parameters <- decode.optional_field(
    "parameters",
    [],
    decode.list(parameter_decoder()),
  )
  use request_body <- decode.optional_field(
    "requestBody",
    None,
    decode.optional(request_body_decoder()),
  )
  use security <- decode.optional_field(
    "security",
    None,
    decode.optional(decode.list(dict_decoder(decode.dynamic))),
  )
  use responses <- decode.field("responses", dict_decoder(response_decoder()))
  decode.success(Operation(
    operation_id: operation_id,
    summary: summary,
    parameters: parameters,
    request_body: request_body,
    responses: responses,
    security: security,
  ))
}

pub fn parameter_decoder() -> decode.Decoder(Parameter) {
  use name <- decode.field("name", decode.string)
  use in <- decode.field("in", parameter_location_decoder())
  use required <- decode.optional_field("required", False, decode.bool)
  use schema <- decode.field("schema", schema_decoder())
  decode.success(Parameter(
    name: name,
    in: in,
    required: required,
    schema: schema,
  ))
}

pub fn parameter_location_decoder() -> decode.Decoder(ParameterLocation) {
  decode.string
  |> decode.then(fn(location) {
    case location {
      "path" -> decode.success(PathParam)
      "query" -> decode.success(QueryParam)
      "header" -> decode.success(HeaderParam)
      "cookie" -> decode.success(CookieParam)
      _ ->
        decode.failure(
          PathParam,
          "Parameter location should be one of path|query|header|cookie",
        )
    }
  })
}

pub fn request_body_decoder() -> decode.Decoder(RequestBody) {
  use content <- decode.field("content", dict_decoder(media_type_decoder()))
  use required <- decode.optional_field("required", False, decode.bool)
  decode.success(RequestBody(content: content, required: required))
}

pub fn example_decoder() -> decode.Decoder(Example) {
  use description <- decode.optional_field(
    "description",
    None,
    decode.optional(decode.string),
  )
  use summary <- decode.optional_field(
    "summary",
    None,
    decode.optional(decode.string),
  )
  use value <- decode.optional_field(
    "value",
    None,
    decode.optional(decode.dynamic),
  )
  use external_value <- decode.optional_field(
    "externalValue",
    None,
    decode.optional(decode.dynamic),
  )
  decode.success(Example(summary:, description:, value:, external_value:))
}

pub fn media_type_decoder() -> decode.Decoder(MediaType) {
  use schema <- decode.optional_field(
    "schema",
    None,
    decode.optional(schema_decoder()),
  )
  use examples <- decode.optional_field(
    "examples",
    None,
    decode.optional(dict_decoder(example_decoder())),
  )
  decode.success(MediaType(schema:, examples:))
}

pub fn response_decoder() -> decode.Decoder(Response) {
  use description <- decode.field("description", decode.string)
  use content <- decode.optional_field(
    "content",
    None,
    decode.optional(dict_decoder(media_type_decoder())),
  )
  decode.success(Response(description:, content:))
}

pub fn ref_schema_decoder() {
  use ref <- decode.field("$ref", decode.string)
  decode.success(RefSchema(ref))
}

pub fn object_schema_decoder() {
  use properties <- decode.optional_field(
    "properties",
    dict.from_list([]),
    dict_decoder(schema_decoder()),
  )
  use required <- decode.optional_field(
    "required",
    [],
    decode.list(decode.string),
  )
  decode.success(ObjectSchema(properties:, required:))
}

pub fn array_schema_decoder() {
  use items <- decode.field("items", schema_decoder())
  decode.success(ArraySchema(items:))
}

pub fn dynamic_object_decoder() {
  use object <- decode.then(dict_decoder(decode.dynamic))
  decode.success(DynamicSchema(object:))
}

pub fn security_schema_decoder() {
  use bearer <- decode.optional_field(
    "securitySchemes",
    None,
    decode.optional(bearer_auth_decoder()),
  )
  decode.success(SecuritySchemas(bearer:))
}

pub fn bearer_auth_decoder() {
  use sec_type <- decode.field("type", decode.string)
  use scheme <- decode.field("scheme", decode.string)
  use format <- decode.field("bearerFormat", decode.string)
  decode.success(BearerScheme(sec_type:, scheme:, format:))
}

pub fn string_schema_decoder() {
  use example <- decode.optional_field(
    "example",
    None,
    decode.optional(decode.string),
  )
  use format <- decode.optional_field(
    "format",
    None,
    decode.optional(decode.string),
  )
  decode.success(StringSchema(example:, format:))
}

pub fn integer_schema_decoder() {
  use example <- decode.optional_field(
    "example",
    None,
    decode.optional(decode.int),
  )
  use format <- decode.optional_field(
    "format",
    None,
    decode.optional(decode.string),
  )
  decode.success(IntegerSchema(example:, format:))
}

pub fn number_schema_decoder() {
  use example <- decode.optional_field(
    "example",
    None,
    decode.optional(decode.float),
  )
  use format <- decode.optional_field(
    "format",
    None,
    decode.optional(decode.string),
  )
  decode.success(NumberSchema(example:, format:))
}

pub fn typed_schema_decoder() {
  use tag <- decode.field("type", decode.string)
  case tag {
    "object" -> object_schema_decoder()
    "string" -> string_schema_decoder()
    "integer" -> integer_schema_decoder()
    "number" -> number_schema_decoder()
    "boolean" -> decode.success(BooleanSchema)
    "array" -> array_schema_decoder()
    _ -> decode.failure(BooleanSchema, "Unknown schema type")
  }
}

pub fn schema_decoder() -> decode.Decoder(Schema) {
  decode.one_of(
    // Try $ref first
    ref_schema_decoder(),
    or: [
      security_schema_decoder(),
      typed_schema_decoder(),
      dynamic_object_decoder(),
    ],
  )
}

fn dict_decoder(
  value_decoder: decode.Decoder(a),
) -> decode.Decoder(Dict(String, a)) {
  decode.dict(decode.string, value_decoder)
}

// ============================================================================
// Code Generation Logic
// ============================================================================

/// Parse a path string into segments
pub fn parse_path(path: String) -> List(PathSegment) {
  path
  |> string.split("/")
  |> list.filter(fn(s) { s != "" })
  |> list.map(fn(segment) {
    case string.starts_with(segment, "{") && string.ends_with(segment, "}") {
      True -> {
        let name =
          segment
          |> string.drop_start(1)
          |> string.drop_end(1)
        ParameterSegment(name: name, param_type: "Int")
      }
      False -> StaticSegment(name: segment)
    }
  })
}

/// Generate a phantom type name from path segments
pub fn generate_phantom_type(segments: List(PathSegment)) -> String {
  segments
  |> list.map(fn(seg) {
    case seg {
      StaticSegment(name) -> to_pascal_case(name)
      ParameterSegment(name, _) -> {
        to_pascal_case(name) <> "Param"
      }
    }
  })
  |> string.join("")
  |> fn(s) { s <> "Resource" }
}

/// Convert snake_case or kebab-case to PascalCase
pub fn to_pascal_case(s: String) -> String {
  case string.contains(s, "_") {
    True ->
      s
      |> string.replace("-", "_")
      |> string.split("_")
      |> list.map(string.capitalise)
      |> string.join("")
    False -> {
      let assert Ok(first) = string.first(s)
      let rest = string.slice(s, 1, string.length(s))
      string.join([string.uppercase(first), rest], "")
    }
  }
}

/// Convert to snake_case (poor mans no regex version)
pub fn to_snake_case(s: String) -> String {
  s
  |> string.replace("-", "_")
  |> string.to_graphemes()
  |> list.map(fn(g) {
    case string.uppercase(g) == g {
      True -> string.concat(["_", string.lowercase(g)])
      _ -> g
    }
  })
  |> string.join("")
}

/// Extract all unique resource types from the spec
pub fn extract_resource_types(spec: OpenApiSpec) -> List(String) {
  spec.paths
  |> dict.to_list()
  |> list.map(fn(path_entry) {
    let #(path, _path_item) = path_entry
    let segments = parse_path(path)
    let assert Ok(rest) = list.last(build_segment_chain(segments))
    let #(prev, resource) = rest
    [prev, resource]
  })
  |> list.flatten()
  |> list.unique()
}

/// Build the chain of segments for an endpoint
pub fn build_segment_chain(
  segments: List(PathSegment),
) -> List(#(String, String)) {
  segments
  |> list.index_map(fn(_seg, idx) {
    let prev_type = case idx {
      0 -> "Nil"
      _ -> generate_phantom_type(list.take(segments, idx))
    }
    let current_type = generate_phantom_type(list.take(segments, idx + 1))
    #(prev_type, current_type)
  })
}

/// Generate phantom type declarations
pub fn generate_phantom_types(spec: OpenApiSpec) -> String {
  let types = extract_resource_types(spec)

  let type_declarations =
    types
    |> list.map(fn(t) { "pub type " <> t })
    |> string.join("\n")

  "// Phantom types for type-safe API building\n" <> type_declarations
}

/// Generate a builder function for a segment
pub fn generate_builder_function(
  segment: PathSegment,
  from_type: String,
  to_type: String,
) -> String {
  case segment {
    StaticSegment(name) -> {
      let fn_name = to_snake_case(name)
      "pub fn "
      <> fn_name
      <> "(builder: ApiBuilder("
      <> from_type
      <> ")) -> ApiBuilder("
      <> to_type
      <> ") {
  let new_segments = list.append(builder.segments, [\""
      <> name
      <> "\"])
  ApiBuilder(path: builder.path, segments: new_segments)
}"
    }
    ParameterSegment(name, param_type) -> {
      let fn_name = "by_" <> to_snake_case(name)
      "pub fn "
      <> fn_name
      <> "(builder: ApiBuilder("
      <> from_type
      <> "), id: "
      <> param_type
      <> ") -> ApiBuilder("
      <> to_type
      <> ") {
  let id_str = int.to_string(id)
  let new_segments = list.append(builder.segments, [id_str])
  ApiBuilder(path: builder.path, segments: new_segments)
}"
    }
  }
}

/// Generate all builder functions for the spec
pub fn generate_builder_functions(spec: OpenApiSpec) -> String {
  let functions =
    spec.paths
    |> dict.to_list()
    |> list.flat_map(fn(path_entry) {
      let #(path, _path_item) = path_entry
      let segments = parse_path(path)
      let chain = build_segment_chain(segments)

      list.zip(segments, chain)
      |> list.map(fn(entry) {
        let #(seg, #(from, to)) = entry
        generate_builder_function(seg, from, to)
      })
    })
    |> list.unique()
    |> string.join("\n\n")

  "// Builder functions\n" <> functions
}

/// Generate usage examples
pub fn generate_examples(spec: OpenApiSpec) -> String {
  let examples =
    spec.paths
    |> dict.to_list()
    |> list.filter_map(fn(path_entry) {
      let #(path, path_item) = path_entry

      case path_item.get {
        Some(_op) -> {
          let segments = parse_path(path)
          let chain =
            segments
            |> list.map(fn(seg) {
              case seg {
                StaticSegment(name) -> to_snake_case(name) <> "()"
                ParameterSegment(name, _) ->
                  "by_" <> to_snake_case(name) <> "(123)"
              }
            })
            |> string.join(" |> ")

          let example =
            "  // GET "
            <> path
            <> "\n  let request = api() |> "
            <> chain
            <> " |> get()"
          Ok(example)
        }
        None -> Error(Nil)
      }
    })
    |> string.join("\n\n")

  "// Usage examples\npub fn examples() {\n" <> examples <> "\n}"
}

/// Main generation function
pub fn generate_client(spec: OpenApiSpec) -> GeneratedClient {
  let types = generate_phantom_types(spec)
  let builders = generate_builder_functions(spec)
  let examples = generate_examples(spec)

  GeneratedClient(types: types, builders: builders, examples: examples)
}

/// Generate the complete client code
pub fn generate_complete_client(spec: OpenApiSpec) -> String {
  let client = generate_client(spec)

  let base_types =
    "import gleam/list
import gleam/string
import gleam/int

// Base API builder types
pub type ApiBuilder(resource_type) {
  ApiBuilder(path: String, segments: List(String))
}

pub type HttpMethod {
  Get
  Post
  Put
  Delete
  Patch
}

pub type ApiRequest {
  ApiRequest(method: HttpMethod, path: String)
}

// Initialize the API builder
pub fn api() -> ApiBuilder(Nil) {
  ApiBuilder(path: \"/api\", segments: [])
}

// Build the final path
pub fn build_path(builder: ApiBuilder(a)) -> String {
  case builder.segments {
    [] -> builder.path
    segments -> {
      let joined_segments = string.join(segments, \"/\")
      builder.path <> \"/\" <> joined_segments
    }
  }
}

// HTTP methods
pub fn get(builder: ApiBuilder(a)) -> ApiRequest {
  ApiRequest(method: Get, path: build_path(builder))
}

pub fn post(builder: ApiBuilder(a)) -> ApiRequest {
  ApiRequest(method: Post, path: build_path(builder))
}

pub fn put(builder: ApiBuilder(a)) -> ApiRequest {
  ApiRequest(method: Put, path: build_path(builder))
}

pub fn delete(builder: ApiBuilder(a)) -> ApiRequest {
  ApiRequest(method: Delete, path: build_path(builder))
}

"

  string.join(
    [
      base_types,
      client.types,
      "",
      client.builders,
      "",
      client.examples,
    ],
    "\n\n",
  )
}

// ============================================================================
// Example Usage
// ============================================================================

pub fn main() {
  case argv.load().arguments {
    [infile, outfile] -> {
      let assert Ok(js) = simplifile.read(from: infile)
      let assert Ok(spec) = parse_openapi_spec(js)
      let generated_code = generate_complete_client(spec)
      let assert Ok(_) = simplifile.write(to: outfile, contents: generated_code)
      Nil
    }
    _ ->
      io.println(
        "usage: ./glintstone 'path/to/openapi.json' 'path/to/client.gleam'",
      )
  }
}
