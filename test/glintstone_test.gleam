import gleam/json
import gleam/option.{type Option, None, Some}
import gleeunit
import glintstone

pub fn main() -> Nil {
  gleeunit.main()
}

pub fn parse_info_test() {
  let json_string = "{\"title\": \"some title\", \"version\": \"3.0.1\"}"
  let assert Ok(_) = json.parse(json_string, glintstone.info_decoder())
}

pub fn parse_servers_test() {
  let json_string =
    "{
      \"url\": \"https://api.demo-ecommerce.com/v1\",
      \"description\": \"Production environment\"
    }"
  let assert Ok(_) = json.parse(json_string, glintstone.server_info_decoder())
}

pub fn parse_object_test() {
  let json_string =
    "{
		  \"type\": \"object\",
		  \"required\": [
		  	\"id\",
		  	\"name\",
		  	\"price\",
		  	\"stock\",
		  	\"category\"
		  ],
		  \"properties\": {
		  	\"id\": {
		  		\"type\": \"string\",
		  		\"format\": \"uuid\",
		  		\"example\": \"eda5cbc1-a615-4da5-ae73-4a33a9acfb6a\"
		  	},
		  	\"name\": {
		  		\"type\": \"string\",
		  		\"example\": \"Worry Management\"
		  	},
		  	\"description\": {
		  		\"type\": \"string\",
		  		\"example\": \"Mr street sell would civil. People through shake southern force.\"
		  	},
		  	\"price\": {
		  		\"type\": \"number\",
		  		\"format\": \"float\",
		  		\"example\": 91.37
		  	},
		  	\"category\": {
		  		\"type\": \"string\",
		  		\"example\": \"wrong\"
		  	},
		  	\"image_url\": {
		  		\"type\": \"string\",
		  		\"format\": \"uri\",
		  		\"example\": \"https://dummyimage.com/766x809\"
		  	},
		  	\"stock\": {
		  		\"type\": \"integer\",
		  		\"example\": 94
		  	},
		  	\"created_at\": {
		  		\"type\": \"string\",
		  		\"format\": \"date-time\"
		  	},
		  	\"updated_at\": {
		  		\"type\": \"string\",
		  		\"format\": \"date-time\"
		  	}
		  }
		}
	"
  let assert Ok(_) = json.parse(json_string, glintstone.object_schema_decoder())
}

pub fn parse_types_schema_string_test() {
  let json_string =
    "{
				\"type\": \"string\",
				\"format\": \"uri\",
				\"example\": \"https://dummyimage.com/766x809\"
			}
	"
  let assert Ok(glintstone.StringSchema(
    format: Some("uri"),
    example: Some("https://dummyimage.com/766x809"),
  )) = json.parse(json_string, glintstone.typed_schema_decoder())
}

pub fn parse_path_test() {
  let json_string =
    "
		{
      \"get\": {
        \"summary\": \"Get your saved addresses\",
        \"security\": [
          {
            \"BearerAuth\": []
          }
        ],
        \"responses\": {
          \"200\": {
            \"description\": \"List of saved addresses\",
            \"content\": {
              \"application/json\": {
                \"schema\": {
                  \"type\": \"array\",
                  \"items\": {
                    \"$ref\": \"#/components/schemas/Address\"
                  }
                }
              }
            }
          }
        }
      },
      \"post\": {
        \"summary\": \"Add a new address\",
        \"security\": [
          {
            \"BearerAuth\": []
          }
        ],
        \"requestBody\": {
          \"required\": true,
          \"content\": {
            \"application/json\": {
              \"schema\": {
                \"$ref\": \"#/components/schemas/Address\"
              }
            }
          }
        },
        \"responses\": {
          \"201\": {
            \"description\": \"Address added\"
          }
        }
      }
    }
	"
  let assert Ok(_) = json.parse(json_string, glintstone.path_item_decoder())
}
