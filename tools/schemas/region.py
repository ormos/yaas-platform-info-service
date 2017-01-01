import sys
import os
import jsl
import json

from schema import DocumentRole
from schema import LinkField, RefDocumentField, createDocumentId
from schema import MetadataDocument


BETA_ID = '_beta_'


def region_ids():
    # Region based on ICANN defintion
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


def region_ids_regex():
    return '^' + '|'.join(region_ids()) + '$'


# region schema definition
class Region(jsl.Document):
    class Options(object):
        id = createDocumentId('region_entity.json')
        definition_id = 'region'
        title = "SAP Hybris YaaS region"
        description = 'YaaS region definition'
        additional_properties = True

    id          = jsl.StringField(required=True, enum=region_ids(),
                                  description='Id of the region')
    name        = jsl.StringField(required=True, min_length=4, max_length=32,
                                  description='Name of the region')
    description = jsl.StringField(required=False, max_length=256,
                                  description='Text describing the region')
    link        = LinkField(required=True,
                            description='Link to ressource')
    domain      = jsl.StringField(required=True, max_length=512,
                                  pattern=r"^(([0-9a-z-]+)\.){1,}([a-z]{2,6})$",
                                  description='Domain of the region')


class Regions(jsl.Document):
    class Options(object):
        id = createDocumentId('regions_collection.json')
        definition_id = 'regions'
        title = "SAP Hybris YaaS regions"
        description = 'YaaS regions collection definition'
        # pattern_properties = { region_ids_regex() : jsl.DocumentField(Region, as_ref=True) }
        pattern_properties = { region_ids_regex() : RefDocumentField(Region) }


class RegionsDocument(MetadataDocument):
    class Options(object):
        id = createDocumentId('regions_document.json')
        title = "SAP Hybris YaaS regions document"
        description = 'YaaS regions document schema definition'

    regions = jsl.DocumentField(Regions, as_ref=True)


def isTargetOlder(target, timestamp):
    return not os.path.exists(target) or (os.path.getmtime(target) < timestamp)


def generate(filename, mtime, schema, context=jsl.DEFAULT_ROLE):
    with open(filename, 'w') as f:
        json.dump(schema.get_schema(role=context, ordered=True), f,
                  ensure_ascii=False, indent=4)


def main(argv):
    #folder = '../../rootfs/var/nginx/meta/schemas'
    folder = '.'
    if os.path.exists(folder) and os.path.isdir(folder):
        mtime = os.path.getmtime(argv[0])
        target = os.path.join(folder, 'region_entity.json')
        if isTargetOlder(target, mtime):
            generate('region_entity.json', mtime, Region)
        generate('regions_collection.json', mtime, Regions)
        generate('regions_document.json', mtime, RegionsDocument, DocumentRole)
    else:
        print "folder does not exists"
    pass

if __name__ == "__main__":
    main(sys.argv)
