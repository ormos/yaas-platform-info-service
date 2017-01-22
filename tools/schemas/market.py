import sys

import jsl
import json
from pycountry import countries

from base import BaseSchemata
from region import RegionSchemata

BETA_ID = '_beta_'

def region_ids():
    # Region based on ICANN definition
    return [ 'AF', # Africa
             'AN', # Antarctica
             'AS', # Asia / Australia / Pacific
             'EU', # Europe
             'NA', # North America
             'OC', # Oceania
             'SA', # South America
           ] + [ 'US', # YaaS US region (North America)
                 BETA_ID
               ]

def country_ids():
    return [c.alpha2.lower() for c in list(countries)] + [BETA_ID]


def country_ids_regex():
    pattern = '^' + '|'.join(region_ids()) + '$'
    return pattern

# region schema definition
class Region(jsl.Document):
    class Options(object):
        description = 'YaaS region definition'

    id = jsl.StringField(required=True, enum=region_ids(),
                         description='Id of the region')
    name = jsl.StringField(required=True, min_length=4, max_length=32,
                           description='Name of the region')
    description = jsl.StringField(required=False, max_length=256,
                                  description='Text describing the region')
    _link_ = jsl.StringField(required=True, max_length=512,
                             format='uri',
                             description='Link to ressource')
    domain = jsl.StringField(required=True, max_length=512,
                             pattern=r"^(([0-9a-z-]+)\\.){1,}([a-z]{2,6})$",
                             description='Domain of the region')

Regions = jsl.fields.DictField(properties={p: jsl.RefField('regions_schema.json#') for p in region_ids()})


def generate(schemata):
    for filename, schema in schemata.iteritems():
        with open(filename, 'w') as f:
            json.dump(schema.get_schema(ordered=True), f,
                      ensure_ascii=False, indent=4)

def main(argv):
    generate({'region_schema.json': Region,
              'regions_schema.json': Regions})
    pass

if __name__ == "__main__":
    main(sys.argv)
