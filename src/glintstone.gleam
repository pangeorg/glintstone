import gleam/dict.{type Dict}
import gleam/dynamic.{type Dynamic}
import gleam/dynamic/decode
import gleam/io
import gleam/json
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result
import gleam/string
import gleam/string_tree

// Core OpenAPI spec types
pub type OpenApiSpec {
  OpenApiSpec(
    info: Info,
    paths: Dict(String, PathItem),
    components: Option(Components),
  )
}

pub type Info {
  Info(title: String, version: String)
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

pub type Schema {
  ObjectSchema(properties: Dict(String, Schema), required: List(String))
  ArraySchema(items: Schema)
  StringSchema
  IntegerSchema
  BooleanSchema
  RefSchema(ref: String)
}

// ============================================================================
// Code Generation Types
// ============================================================================

pub type GeneratedClient {
  GeneratedClient(
    types: String,
    builders: String,
    operations: String,
    examples: String,
  )
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
  use components <- decode.optional_field(
    "components",
    None,
    decode.optional(components_decoder()),
  )
  decode.success(OpenApiSpec(info: info, paths: paths, components: components))
}

pub fn info_decoder() -> decode.Decoder(Info) {
  use title <- decode.field("title", decode.string)
  use version <- decode.field("version", decode.string)
  decode.success(Info(title:, version:))
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
  use operation_id <- decode.field(
    "operationId",
    decode.optional(decode.string),
  )
  use summary <- decode.field("summary", decode.optional(decode.string))
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
  use responses <- decode.field("responses", dict_decoder(response_decoder()))
  decode.success(Operation(
    operation_id: operation_id,
    summary: summary,
    parameters: parameters,
    request_body: request_body,
    responses: responses,
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

pub fn typed_schema_decoder() {
  use tag <- decode.field("type", decode.string)
  case tag {
    "object" -> object_schema_decoder()
    "string" -> decode.success(StringSchema)
    "integer" -> decode.success(IntegerSchema)
    "boolean" -> decode.success(BooleanSchema)
    "array" -> array_schema_decoder()
    _ -> decode.failure(StringSchema, "Unknown schema type")
  }
}

pub fn schema_decoder() -> decode.Decoder(Schema) {
  decode.one_of(
    // Try $ref first
    ref_schema_decoder(),
    or: [
      // Try object schema
      typed_schema_decoder(),
    ],
  )
}

fn dict_decoder(
  value_decoder: decode.Decoder(a),
) -> decode.Decoder(Dict(String, a)) {
  decode.dict(decode.string, value_decoder)
}

// ============================================================================
// Code Generation - Main Entry Point
// ============================================================================

pub fn generate_client_from_spec(spec: OpenApiSpec) -> GeneratedClient {
  let endpoints = extract_endpoints(spec)
  let type_definitions = generate_type_definitions(spec.components)
  let builder_types = generate_tree_types(endpoints)
  let operation_functions = generate_operation_functions(endpoints)
  let usage_examples = generate_usage_examples(endpoints)

  GeneratedClient(
    types: type_definitions,
    builders: builder_types,
    operations: operation_functions,
    examples: usage_examples,
  )
}

// ============================================================================
// Endpoint Extraction
// ============================================================================

fn extract_endpoints(spec: OpenApiSpec) -> List(ApiEndpoint) {
  spec.paths
  |> dict.to_list()
  |> list.flat_map(fn(path_entry) {
    let #(path, path_item) = path_entry
    let path_segments = parse_path_segments(path)

    []
    |> maybe_add_endpoint(path_segments, path_item.get, "get")
    |> maybe_add_endpoint(path_segments, path_item.post, "post")
    |> maybe_add_endpoint(path_segments, path_item.put, "put")
    |> maybe_add_endpoint(path_segments, path_item.delete, "delete")
  })
}

fn maybe_add_endpoint(
  endpoints: List(ApiEndpoint),
  path_segments: List(PathSegment),
  operation: Option(Operation),
  method_prefix: String,
) -> List(ApiEndpoint) {
  case operation {
    None -> endpoints
    Some(op) -> {
      let operation_id = generate_operation_id(path_segments, method_prefix)
      let response_type = extract_response_type(op.responses)
      let builder_chain = generate_tree_chain(path_segments)

      let endpoint =
        ApiEndpoint(
          path_segments: path_segments,
          method: string_to_http_method(method_prefix),
          operation_id: operation_id,
          parameters: op.parameters,
          request_body: op.request_body,
          response_type: response_type,
          builder_chain: builder_chain,
        )

      [endpoint, ..endpoints]
    }
  }
}

fn parse_path_segments(path: String) -> List(PathSegment) {
  path
  |> string.split("/")
  |> list.filter(fn(segment) { segment != "" })
  |> list.map(fn(segment) {
    case string.starts_with(segment, "{") && string.ends_with(segment, "}") {
      True -> {
        let param_name =
          segment
          |> string.drop_start(1)
          |> string.drop_end(1)
        ParameterSegment(param_name, "Int")
        // Simplified - would need type inference
      }
      False -> StaticSegment(segment)
    }
  })
}

fn generate_operation_id(segments: List(PathSegment), method: String) -> String {
  let path_parts =
    segments
    |> list.map(fn(segment) {
      case segment {
        StaticSegment(name) -> to_pascal_case(name)
        ParameterSegment(name, _) -> "By" <> to_pascal_case(name)
      }
    })
    |> string.join("")

  method <> path_parts
}

fn generate_tree_chain(segments: List(PathSegment)) -> List(String) {
  segments
  |> list.scan("", fn(acc, segment) {
    case segment {
      StaticSegment(name) -> acc <> to_pascal_case(name)
      ParameterSegment(name, _) -> acc <> "By" <> to_pascal_case(name)
    }
  })
  |> list.drop(1)
  // Remove empty first element
  |> list.map(fn(name) { name <> "Builder" })
}

fn extract_response_type(responses: Dict(String, Response)) -> String {
  // Simplified - look for 200 response and try to extract type
  case dict.get(responses, "200") {
    Ok(response) -> {
      case response.content {
        Some(content) -> {
          case dict.get(content, "application/json") {
            Ok(media_type) -> schema_to_type_name(media_type.schema)
            Error(_) -> "String"
          }
        }
        None -> "Nil"
      }
    }
    Error(_) -> "String"
  }
}

fn schema_to_type_name(schema: Option(Schema)) -> String {
  case schema {
    Some(RefSchema(ref)) -> extract_type_name_from_ref(ref)
    Some(ArraySchema(items)) ->
      "List(" <> schema_to_type_name(Some(items)) <> ")"
    Some(StringSchema) -> "String"
    Some(IntegerSchema) -> "Int"
    Some(BooleanSchema) -> "Bool"
    Some(ObjectSchema(_, _)) -> "Dict(String, String)"
    _ -> "Dict(String, String)"
    // Simplified
  }
}

fn extract_type_name_from_ref(ref: String) -> String {
  ref
  |> string.split("/")
  |> list.last()
  |> result.unwrap("Unknown")
}

// ============================================================================
// Code Generation Functions
// ============================================================================

fn generate_type_definitions(components: Option(Components)) -> String {
  case components {
    None -> ""
    Some(comps) -> {
      let sb =
        string_tree.new()
        |> string_tree.append(
          "// ============================================================================\n",
        )
        |> string_tree.append("// Generated Types\n")
        |> string_tree.append(
          "// ============================================================================\n\n",
        )

      dict.fold(comps.schemas, sb, fn(acc, name, schema) {
        acc
        |> string_tree.append("pub type ")
        |> string_tree.append(name)
        |> string_tree.append(" {\n")
        |> string_tree.append(generate_type_constructor(name, schema))
        |> string_tree.append("}\n\n")
      })
      |> string_tree.to_string()
    }
  }
}

fn generate_type_constructor(type_name: String, schema: Schema) -> String {
  case schema {
    ObjectSchema(properties, _required) -> {
      let fields =
        dict.fold(properties, [], fn(acc, field_name, field_schema) {
          let field_type = schema_to_type_name(Some(field_schema))
          let field_def =
            "    " <> to_snake_case(field_name) <> ": " <> field_type
          [field_def, ..acc]
        })
        |> list.reverse()
        |> string.join(",\n")

      "  " <> type_name <> "(\n" <> fields <> "\n  )"
    }
    _ -> "  " <> type_name <> "(String)"
    // Fallback
  }
}

fn generate_tree_types(endpoints: List(ApiEndpoint)) -> String {
  let unique_trees =
    endpoints
    |> list.flat_map(fn(endpoint) { endpoint.builder_chain })
    |> list.unique()

  let sb =
    string_tree.new()
    |> string_tree.append(
      "// ============================================================================\n",
    )
    |> string_tree.append("// Generated Builder Types\n")
    |> string_tree.append(
      "// ============================================================================\n\n",
    )

  list.fold(unique_trees, sb, fn(acc, builder_name) {
    acc
    |> string_tree.append("pub type ")
    |> string_tree.append(builder_name)
    |> string_tree.append(" {\n")
    |> string_tree.append("  ")
    |> string_tree.append(builder_name)
    |> string_tree.append("(client: ApiClient")
    |> string_tree.append(generate_builder_fields(builder_name))
    |> string_tree.append(")\n}\n\n")
  })
  |> string_tree.to_string()
}

fn generate_builder_fields(builder_name: String) -> String {
  // Simplified - would analyze the builder name to determine what fields it needs
  case string.contains(builder_name, "ById") {
    True -> ", id: Int"
    False -> ""
  }
}

fn generate_operation_functions(endpoints: List(ApiEndpoint)) -> String {
  let sb =
    string_tree.new()
    |> string_tree.append(
      "// ============================================================================\n",
    )
    |> string_tree.append("// Generated Operations\n")
    |> string_tree.append(
      "// ============================================================================\n\n",
    )

  list.fold(endpoints, sb, fn(acc, endpoint) {
    acc
    |> string_tree.append(generate_single_operation(endpoint))
    |> string_tree.append("\n")
  })
  |> string_tree.to_string()
}

fn generate_single_operation(endpoint: ApiEndpoint) -> String {
  let function_name = to_snake_case(endpoint.operation_id)
  let path_string = generate_path_string(endpoint.path_segments)
  let builder_type = case list.last(endpoint.builder_chain) {
    Ok(last) -> last
    Error(_) -> "ApiClient"
  }
  let method_name = http_method_to_string(endpoint.method)

  "pub fn "
  <> function_name
  <> "(builder: "
  <> builder_type
  <> ") -> "
  <> method_name
  <> "Request("
  <> endpoint.response_type
  <> ") {\n"
  <> "  let path = \""
  <> path_string
  <> "\"\n"
  <> "  "
  <> method_name
  <> "Request(builder.client, path, "
  <> generate_phantom_value(endpoint.response_type)
  <> ")\n"
  <> "}"
}

fn generate_path_string(segments: List(PathSegment)) -> String {
  "/"
  <> segments
  |> list.map(fn(segment) {
    case segment {
      StaticSegment(name) -> name
      ParameterSegment(name, _) ->
        "\" <> int.to_string(builder." <> to_snake_case(name) <> ") <> \""
    }
  })
  |> string.join("/")
}

fn generate_phantom_value(type_name: String) -> String {
  case type_name {
    "String" -> "\"\""
    "Int" -> "0"
    "Bool" -> "False"
    "Nil" -> "Nil"
    _ ->
      case string.starts_with(type_name, "List(") {
        True -> "[]"
        False -> type_name <> "()"
        // Constructor call
      }
  }
}

fn generate_usage_examples(endpoints: List(ApiEndpoint)) -> String {
  let sb =
    string_tree.new()
    |> string_tree.append(
      "// ============================================================================\n",
    )
    |> string_tree.append("// Generated Usage Examples\n")
    |> string_tree.append(
      "// ============================================================================\n\n",
    )
    |> string_tree.append("pub fn example_usage() {\n")
    |> string_tree.append(
      "  let client = new_client(\"https://api.example.com\")\n\n",
    )

  list.take(endpoints, 5)
  // Just show first 5 examples
  |> list.fold(sb, fn(acc, endpoint) {
    acc
    |> string_tree.append("  // " <> endpoint.operation_id <> "\n")
    |> string_tree.append("  let _result = client\n")
    |> string_tree.append(generate_example_chain(endpoint))
    |> string_tree.append(
      "    |> execute_"
      <> string.lowercase(http_method_to_string(endpoint.method))
      <> "()\n\n",
    )
  })
  |> string_tree.append("  Nil\n}")
  |> string_tree.to_string()
}

fn generate_example_chain(endpoint: ApiEndpoint) -> String {
  endpoint.path_segments
  |> list.fold("", fn(acc, segment) {
    case segment {
      StaticSegment(name) -> acc <> "    |> " <> to_snake_case(name) <> "()\n"
      ParameterSegment(name, _) ->
        acc <> "    |> by_" <> to_snake_case(name) <> "(123)\n"
    }
  })
  <> "    |> "
  <> to_snake_case(endpoint.operation_id)
  <> "()\n"
}

// ============================================================================
// Utility Functions
// ============================================================================

fn to_pascal_case(input: String) -> String {
  input
  |> string.split("_")
  |> list.map(string.capitalise)
  |> string.join("")
}

fn to_snake_case(input: String) -> String {
  // Simplified conversion - would need more sophisticated logic for real use
  input
  |> string.lowercase()
  |> string.replace("-", "_")
}

fn string_to_http_method(method: String) -> HttpMethod {
  case method {
    "get" -> Get
    "post" -> Post
    "put" -> Put
    "delete" -> Delete
    _ -> Get
  }
}

fn http_method_to_string(method: HttpMethod) -> String {
  case method {
    Get -> "Get"
    Post -> "Post"
    Put -> "Put"
    Delete -> "Delete"
  }
}

// ============================================================================
// Example Usage
// ============================================================================

pub fn example_openapi_spec() -> String {
  "{
    \"openapi\": \"3.0.0\",
    \"info\": {
      \"title\": \"Example API\",
      \"version\": \"1.0.0\"
    },
    \"paths\": {
      \"/users\": {
        \"get\": {
          \"operationId\": \"getUsers\",
          \"responses\": {
            \"200\": {
              \"description\": \"Success\",
              \"content\": {
                \"application/json\": {
                  \"schema\": {
                    \"type\": \"array\",
                    \"items\": {
                      \"$ref\": \"#/components/schemas/User\"
                    }
                  }
                }
              }
            }
          }
        },
        \"post\": {
          \"operationId\": \"createUser\",
          \"requestBody\": {
            \"content\": {
              \"application/json\": {
                \"schema\": {
                  \"$ref\": \"#/components/schemas/User\"
                }
              }
            }
          },
          \"responses\": {
            \"201\": {
              \"description\": \"Created\",
              \"content\": {
                \"application/json\": {
                  \"schema\": {
                    \"$ref\": \"#/components/schemas/User\"
                  }
                }
              }
            }
          }
        }
      },
      \"/users/{id}\": {
        \"get\": {
          \"operationId\": \"getUserById\",
          \"parameters\": [
            {
              \"name\": \"id\",
              \"in\": \"path\",
              \"required\": true,
              \"schema\": {
                \"type\": \"integer\"
              }
            }
          ],
          \"responses\": {
            \"200\": {
              \"description\": \"Success\",
              \"content\": {
                \"application/json\": {
                  \"schema\": {
                    \"$ref\": \"#/components/schemas/User\"
                  }
                }
              }
            }
          }
        }
      }
    },
    \"components\": {
      \"schemas\": {
        \"User\": {
          \"type\": \"object\",
          \"properties\": {
            \"id\": {
              \"type\": \"integer\"
            },
            \"name\": {
              \"type\": \"string\"
            },
            \"email\": {
              \"type\": \"string\"
            }
          },
          \"required\": [\"id\", \"name\", \"email\"]
        }
      }
    }
  }"
}

pub fn main() -> Result(String, String) {
  let spec_json = example_openapi_spec()

  let assert Ok(spec) = parse_openapi_spec(spec_json)
  let generated = generate_client_from_spec(spec)

  let complete_client =
    string_tree.new()
    |> string_tree.append("// Generated Gleam API Client\n")
    |> string_tree.append("// Generated from OpenAPI specification\n\n")
    |> string_tree.append(generated.types)
    |> string_tree.append("\n")
    |> string_tree.append(generated.builders)
    |> string_tree.append("\n")
    |> string_tree.append(generated.operations)
    |> string_tree.append("\n")
    |> string_tree.append(generated.examples)
    |> string_tree.to_string()
  io.print(complete_client)

  Ok(complete_client)
}
