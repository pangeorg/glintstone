import gleam/dict
import gleam/json
import gleam/result
import gleeunit
import glintstone

pub fn main() -> Nil {
  gleeunit.main()
}

pub fn parse_info_test() {
  let json_string = "{\"title\": \"some title\", \"version\": \"3.0.1\"}"
  let assert Ok(info) = json.parse(json_string, glintstone.info_decoder())
  assert info.title == "some title"
  assert info.version == "3.0.1"
}

pub fn schema_test() {
  let ref_string = "{\"$ref\": \"/some/str/\"}"
  let assert Ok(ref) =
    json.parse(from: ref_string, using: glintstone.schema_decoder())
  assert ref == glintstone.RefSchema("/some/str/")

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

pub fn openapi_spec_test() {
  let json_string =
    "{
    \"openapi\": \"3.0.0\",
    \"info\": {
      \"title\": \"Simple API overview\",
      \"version\": \"2.0.0\"
    },
    \"paths\": {
      \"/\": {
        \"get\": {
          \"operationId\": \"listVersionsv2\",
          \"summary\": \"List API versions\",
          \"responses\": {
            \"200\": {
              \"description\": \"200 response\",
              \"content\": {
                \"application/json\": {
                  \"examples\": {
                    \"foo\": {
                      \"value\": {
                        \"versions\": [
                          {
                            \"status\": \"CURRENT\",
                            \"updated\": \"2011-01-21T11:33:21Z\",
                            \"id\": \"v2.0\",
                            \"links\": [
                              {
                                \"href\": \"http://127.0.0.1:8774/v2/\",
                                \"rel\": \"self\"
                              }
                            ]
                          },
                          {
                            \"status\": \"EXPERIMENTAL\",
                            \"updated\": \"2013-07-23T11:33:21Z\",
                            \"id\": \"v3.0\",
                            \"links\": [
                              {
                                \"href\": \"http://127.0.0.1:8774/v3/\",
                                \"rel\": \"self\"
                              }
                            ]
                          }
                        ]
                      }
                    }
                  }
                }
              }
            },
            \"300\": {
              \"description\": \"300 response\",
              \"content\": {
                \"application/json\": {
                  \"examples\": {
                    \"foo\": {
                      \"value\": {
                        \"versions\": [
                          {
                            \"status\": \"CURRENT\",
                            \"updated\": \"2011-01-21T11:33:21Z\",
                            \"id\": \"v2.0\",
                            \"links\": [
                              {
                                \"href\": \"http://127.0.0.1:8774/v2/\",
                                \"rel\": \"self\"
                              }
                            ]
                          },
                          {
                            \"status\": \"EXPERIMENTAL\",
                            \"updated\": \"2013-07-23T11:33:21Z\",
                            \"id\": \"v3.0\",
                            \"links\": [
                              {
                                \"href\": \"http://127.0.0.1:8774/v3/\",
                                \"rel\": \"self\"
                              }
                            ]
                          }
                        ]
                      }
                    }
                  }
                }
              }
            }
          }
        }
      },
      \"/v2\": {
        \"get\": {
          \"operationId\": \"getVersionDetailsv2\",
          \"summary\": \"Show API version details\",
          \"responses\": {
            \"200\": {
              \"description\": \"200 response\",
              \"content\": {
                \"application/json\": {
                  \"examples\": {
                    \"foo\": {
                      \"value\": {
                        \"version\": {
                          \"status\": \"CURRENT\",
                          \"updated\": \"2011-01-21T11:33:21Z\",
                          \"media-types\": [
                            {
                              \"base\": \"application/xml\",
                              \"type\": \"application/vnd.openstack.compute+xml;version=2\"
                            },
                            {
                              \"base\": \"application/json\",
                              \"type\": \"application/vnd.openstack.compute+json;version=2\"
                            }
                          ],
                          \"id\": \"v2.0\",
                          \"links\": [
                            {
                              \"href\": \"http://127.0.0.1:8774/v2/\",
                              \"rel\": \"self\"
                            },
                            {
                              \"href\": \"http://docs.openstack.org/api/openstack-compute/2/os-compute-devguide-2.pdf\",
                              \"type\": \"application/pdf\",
                              \"rel\": \"describedby\"
                            },
                            {
                              \"href\": \"http://docs.openstack.org/api/openstack-compute/2/wadl/os-compute-2.wadl\",
                              \"type\": \"application/vnd.sun.wadl+xml\",
                              \"rel\": \"describedby\"
                            },
                            {
                              \"href\": \"http://docs.openstack.org/api/openstack-compute/2/wadl/os-compute-2.wadl\",
                              \"type\": \"application/vnd.sun.wadl+xml\",
                              \"rel\": \"describedby\"
                            }
                          ]
                        }
                      }
                    }
                  }
                }
              }
            },
            \"203\": {
              \"description\": \"203 response\",
              \"content\": {
                \"application/json\": {
                  \"examples\": {
                    \"foo\": {
                      \"value\": {
                        \"version\": {
                          \"status\": \"CURRENT\",
                          \"updated\": \"2011-01-21T11:33:21Z\",
                          \"media-types\": [
                            {
                              \"base\": \"application/xml\",
                              \"type\": \"application/vnd.openstack.compute+xml;version=2\"
                            },
                            {
                              \"base\": \"application/json\",
                              \"type\": \"application/vnd.openstack.compute+json;version=2\"
                            }
                          ],
                          \"id\": \"v2.0\",
                          \"links\": [
                            {
                              \"href\": \"http://23.253.228.211:8774/v2/\",
                              \"rel\": \"self\"
                            },
                            {
                              \"href\": \"http://docs.openstack.org/api/openstack-compute/2/os-compute-devguide-2.pdf\",
                              \"type\": \"application/pdf\",
                              \"rel\": \"describedby\"
                            },
                            {
                              \"href\": \"http://docs.openstack.org/api/openstack-compute/2/wadl/os-compute-2.wadl\",
                              \"type\": \"application/vnd.sun.wadl+xml\",
                              \"rel\": \"describedby\"
                            }
                          ]
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  }"

  let assert Ok(_) =
    json.parse(from: json_string, using: glintstone.openapi_decoder())
}
