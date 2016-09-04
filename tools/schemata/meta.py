import jsl


# document meta data schema
class Meta_Schemata(jsl.Document):
    authors = jsl.ArrayField(
        jsl.EmailField(), min_items=1, unique_items=True, required=True)
    last_modified = jsl.DateTimeField(name='last-modified', required=True)
    version = jsl.StringField(
        required=True, pattern="^(\([0-9]{3}\\))?[0-9]{3}-[0-9]{4}$")
    comment = jsl.StringField(required=False, min_length=1, max_length=132)
