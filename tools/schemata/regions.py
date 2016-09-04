import jsl
from pycountry import countries
from base import Base_Schemata

BETA_ID = '_beta_'

def regions_ids():
    # Region based on ICANN defintion
    return [ 'AF', # Africa
             'AP', # Asia / Australia / Pacific
             'EU', # Europe
             'LA', # Latin America / Carribbean
             'NA'  # North America
           ] + [BETA_ID]

def country_ids():
    return [c.alpha2.lower() for c in list(countries)] + [BETA_ID]


def country_ids_regex():
    pattern = '^' + '|'.join(region_ids()) + '$'
    return pattern

# region schema definition
class Region(jsl.Document):
    class Options(object):
        description = 'YaaS region definition'

    id = jsl.StringField(required=True, enum=region_ids(), description='Id of the region')
    name = jsl.StringField(required=True, min_length=4, max_length=32, description='Name of the region')
    description = jsl.StringField(required=True, min_length=4, max_length=256,
                                  description='Text describing the region')
    domain = jsl.StringField(
        required=True, pattern="^(([0-9a-z-]+)\\.){1,}([a-z]{2,6})$",
        description='Domain of the region')

Regions = jsl.fields.DictField(properties={p: jsl.RefField('regions_schema.json#') for p in region_ids()})


class Regions_Schemata(Base_Schemata):

    @staticmethod
    def generate():
        Base_Schemata.generate({'region_schema.json': Region})
        Base_Schemata.generate({'regions_schema.json': Regions})
