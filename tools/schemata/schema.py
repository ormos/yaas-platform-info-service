import jsl
from urlparse import urljoin

DocumentRole = 'document'

def createDocumentId(document):
    return 'YPI://{URL}/meta-data/schemas/' + document

# link field class - with special handling for ${UR} variable
class LinkField(jsl.UriField):
    """A link field."""

    def __init__(self,
                 name = '_link_',
                 pattern=jsl.Var( { DocumentRole : r"^(({URL})|(https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{2,256}\.[a-z]{2,6}))(\/[-a-zA-Z0-9@:%_\+.~#?&//=]*)?$" } ),
                 format=jsl.Var( { jsl.not_(DocumentRole) : 'uri' } ),
                 max_length=512,
                 min_length=None, **kwargs):
        super(LinkField, self).__init__(name = name, pattern = pattern, format = format,
                                        max_length = max_length, min_lenght = min_length,
                                        **kwargs)


class RefDocumentField(jsl.RefField):
    """A reference field to external documents."""

    def __init__(self, cls, **kwargs):
        ptr = cls._options.id
        super(RefDocumentField, self).__init__(ptr, **kwargs)


# document metadata schema
class Metadata(jsl.Document):
    class Options(object):
        definition_id = 'metadata'
        description = 'Metadata definition'
        additional_properties = True

    authors       = jsl.ArrayField(jsl.EmailField(), min_items=1, unique_items=True, required=True)
    last_modified = jsl.DateTimeField(name='last-modified', required=True)
    version       = jsl.StringField(required=True,
                                    pattern=r"^v?((0|([1-9][0-9]*))\.(0|([1-9][0-9]*))\.(0|([1-9][0-9]*)))((-([0-9A-Za-z\-]+))(\.([0-9A-Za-z\-]+))*((\+([0-9A-Za-z\-]+))(\.([0-9A-Za-z\-]+))*)?)?$")
    comment       = jsl.StringField(required=False, max_length=1024)


class MetadataDocument(jsl.Document):
    class Options(object):
        description = 'Document metadata definition'

    metadata = jsl.DocumentField(Metadata, as_ref=True, name='@metadata')