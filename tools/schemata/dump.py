import ICANN_regions

for i in ICANN_regions.regions.db.indices['region']:
    print 'region=' + i
    r = ICANN_regions.regions.get(region=i)
    for c in r.countries:
        print c

