import os
import json
import jsonref
from jsonschema import validate, RefResolver, Draft4Validator

folder = '.'
schema_file = 'region_schema.json'
data_file = 'region.json'

with open(os.path.join(folder, schema_file)) as f:
    schema = json.load(f)
with open(os.path.join(folder, data_file)) as f:
    data = json.load(f)

resolver = RefResolver('file://' + folder + '/', schema_file)

Draft4Validator(schema, resolver=resolver).validate(data)


resolver = RefResolver.from_schema(schema)
Validator = Draft4Validator(schema, resolver=resolver)
Validator.validate(data)

with open(os.path.join(folder, schema_file)) as f:
    schema = jsonref.load(f,
                          base_uri='file://' + folder + '/' + schema_file,
                          jsonschema=True)
# Then it can be used anywhere without worrying about refs e.g.
validate(data, schema)
