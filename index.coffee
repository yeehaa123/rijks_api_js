https = require('https')
XmlDocument = require('xmldoc').XmlDocument

Artwork = (data) ->
  url: data.childNamed('dc:format').val
  language: data.childNamed('dc:language')?.val
  date: data.childNamed('dc:date')?.val
  description: data.childNamed('dc:description')?.val
  creator: data.childNamed('dc:creator')?.val
  type: data.childNamed('dc:type')?.val
  title: data.childNamed('dc:title')?.val

RijksAPI =->
  _getRecords = (resumptionToken, callback)->
    xmlString = ""
    
    if resumptionToken == "new"
      url = "https://www.rijksmuseum.nl/api/oai/97389c4c-f661-4736-8091-be1a8fd6e3fd/?verb=ListRecords&set=collectie_online&metadataPrefix=oai_dc"
    else
      url = "https://www.rijksmuseum.nl/api/oai/97389c4c-f661-4736-8091-be1a8fd6e3fd/?verb=ListRecords&resumptiontoken=#{resumptionToken}"

    https.get url, (res)->
      res.on 'data', (chunk) ->
        xmlString += chunk
      res.on 'end', ->
        xmlString = xmlString.toString('utf8')
        callback(xmlString)
    .on 'error', (e) ->
        console.log(e)

  _parseRecords = (resumptionToken, callback) ->
    _getRecords resumptionToken, (data) ->
      xmlRecords = new XmlDocument(data).childNamed('ListRecords').children
      newResumptionToken = xmlRecords.pop().val
      callback({records: xmlRecords, resumptionToken: newResumptionToken})

  _makeArtworks = (resumptionToken, callback) ->
    _parseRecords resumptionToken, (data) ->
      artworks = data.records.map (record)->
        metadata = record.childNamed('metadata').firstChild
        new Artwork(metadata)
      callback({records: artworks, resumptionToken: data.resumptionToken})

  _listRecords = (resumptionToken, callback) ->
    _makeArtworks resumptionToken, (data) ->
      callback(data)


  {
    listRecords: _listRecords
  }
module.exports = new RijksAPI()

