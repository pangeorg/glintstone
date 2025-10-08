import argv
import glintstone/internal/lib
import simplifile
import gleam/io

// ============================================================================
// Example Usage
// ============================================================================

pub fn main() {
  case argv.load().arguments {
    [infile, outfile] -> {
      let assert Ok(js) = simplifile.read(from: infile)
      let assert Ok(spec) = lib.parse_openapi_spec(js)
      let generated_code = lib.generate_complete_client(spec)
      let assert Ok(_) = simplifile.write(to: outfile, contents: generated_code)
      Nil
    }
    _ ->
      io.println(
        "usage: ./glintstone 'path/to/openapi.json' 'path/to/client.gleam'",
      )
  }
}
