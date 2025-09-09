import gleam/dict
import gleam/json
import gleam/result
import gleeunit
import glintstone

pub fn main() -> Nil {
  gleeunit.main()
}

pub fn parse_info_test() {
  let json_string = "{'title': 'some title', 'version': '3.0.1'}"
  let _ =
    json.parse(from: json_string, using: glintstone.info_decoder())
    |> result.map(fn(r) {
      assert r.title == "some title"
      assert r.version == "3.0.1"
      Ok(r)
    })
}

pub fn schema_test() {
  let ref_string = "{'$ref': '/some/str/'}"
  let _ =
    json.parse(from: ref_string, using: glintstone.schema_decoder())
    |> result.map(fn(r) {
      assert r == glintstone.RefSchema("/some/str/")
      Ok(r)
    })

  let obj_string =
    "{
			'type': 'object',
			'properties' : {
				'name' : {
					'type': 'string'
				},
				'age' : {
					'type': 'integer'
				}
			}
		}"
  let _ =
    json.parse(from: obj_string, using: glintstone.object_schema_decoder())
    |> result.map(fn(r) {
      assert r
        == glintstone.ObjectSchema(
          properties: dict.from_list([
            #("name", glintstone.StringSchema),
            #("value", glintstone.IntegerSchema),
          ]),
          required: [],
        )
      Ok(r)
    })
}
// pub fn openapi_spec_test() {
//   let json_string =
//     "{
//     \"openapi\": \"3.0.0\",
//     \"info\": {
//       \"title\": \"Example API\",
//       \"version\": \"1.0.0\"
//     },
//     \"paths\": {
//       \"/users\": {
//         \"get\": {
//           \"operationId\": \"getUsers\",
//           \"responses\": {
//             \"200\": {
//               \"description\": \"Success\",
//               \"content\": {
//                 \"application/json\": {
//                   \"schema\": {
//                     \"type\": \"array\",
//                     \"items\": {
//                       \"$ref\": \"#/components/schemas/User\"
//                     }
//                   }
//                 }
//               }
//             }
//           }
//         },
//         \"post\": {
//           \"operationId\": \"createUser\",
//           \"requestBody\": {
//             \"content\": {
//               \"application/json\": {
//                 \"schema\": {
//                   \"$ref\": \"#/components/schemas/User\"
//                 }
//               }
//             }
//           },
//           \"responses\": {
//             \"201\": {
//               \"description\": \"Created\",
//               \"content\": {
//                 \"application/json\": {
//                   \"schema\": {
//                     \"$ref\": \"#/components/schemas/User\"
//                   }
//                 }
//               }
//             }
//           }
//         }
//       },
//       \"/users/{id}\": {
//         \"get\": {
//           \"operationId\": \"getUserById\",
//           \"parameters\": [
//             {
//               \"name\": \"id\",
//               \"in\": \"path\",
//               \"required\": true,
//               \"schema\": {
//                 \"type\": \"integer\"
//               }
//             }
//           ],
//           \"responses\": {
//             \"200\": {
//               \"description\": \"Success\",
//               \"content\": {
//                 \"application/json\": {
//                   \"schema\": {
//                     \"$ref\": \"#/components/schemas/User\"
//                   }
//                 }
//               }
//             }
//           }
//         }
//       }
//     },
//     \"components\": {
//       \"schemas\": {
//         \"User\": {
//           \"type\": \"object\",
//           \"properties\": {
//             \"id\": {
//               \"type\": \"integer\"
//             },
//             \"name\": {
//               \"type\": \"string\"
//             },
//             \"email\": {
//               \"type\": \"string\"
//             }
//           },
//           \"required\": [\"id\", \"name\", \"email\"]
//         }
//       }
//     }
//   }"
//
//   let _ =
//     json.parse(from: json_string, using: glintstone.openapi_decoder())
//     |> result.map(fn(r) {
//       assert r.info.title == "Example API"
//       Ok(r)
//     })
// }
