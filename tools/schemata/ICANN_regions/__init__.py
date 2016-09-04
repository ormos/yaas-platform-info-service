# vim:fileencoding=utf-8
"""ICANN_regions"""

import os.path
from pprint import pprint

import ICANN_regions.db

try:
    from pkg_resources import resource_filename
except ImportError:
    def resource_filename(package_or_requirement, resource_name):
        return os.path.join(os.path.dirname(__file__), resource_name)


DATABASE_DIR = resource_filename('ICANN_regions', 'databases')


class Countries(ICANN_regions.db.Database):
    """Providess access to ICANN region database."""

    field_map = dict(alpha_2_code='alpha2',
                     ICANN_region='region',
                     geographic_region='geo_region',
                     comment='comment')
    no_index = ['region', 'geo_region', 'comment'] 
    data_class_name = 'Country'
    xml_tags = 'ICANN_region_entry'

class Region(ICANN_regions.db.Data):

    def __init__(self, element, **kw):
        super(Region, self).__init__(element, **kw)
        self.countries = []

class Regions(ICANN_regions.db.Database):

    def _load(self):
        self.objects = []
        self.indices = { 'region': {} }

        for c in countries:
            pprint (vars(c))
            if c.region in self.indices['region']:
                r = self.indices['region'][c.region]
            else:
                r = Region(c)
                self.objects.append(r)
                self.indices['region'][c.region] = r
            pprint (vars(r))
            r.countries.append(c.alpha2)
        
        self._is_loaded = True
            
countries = Countries(os.path.join(DATABASE_DIR, 'ICANN_regions.xml'))
regions = Regions(None)