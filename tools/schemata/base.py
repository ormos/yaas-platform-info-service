
import json


class Base_Schemata(object):

    @staticmethod
    def generate(schemata):
        for filename, schema in schemata.iteritems():
            with open(filename, 'w') as f:
                json.dump(schema.get_schema(ordered=True), f,
                          ensure_ascii=False, indent=4)
