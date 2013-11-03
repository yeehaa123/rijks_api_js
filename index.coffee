https = require('https')
XmlDocument = require('xmldoc').XmlDocument

Artwork = (data) ->
  _id: data.childNamed('dc:identifier').val
  url: data.childNamed('dc:format').val
  language: data.childNamed('dc:language')?.val
  date: data.childNamed('dc:date')?.val
  description: data.childNamed('dc:description')?.val
  creator: data.childNamed('dc:creator')?.val.split(': ')[1]
  type: data.childNamed('dc:type')?.val
  title: data.childNamed('dc:title')?.val

RijksAPI =->
  _getRecords = (resumptionToken, callback)->
    xmlString = ""
    baseUrl = "https://www.rijksmuseum.nl/api/oai/97389c4c-f661-4736-8091-be1a8fd6e3fd/?verb=ListRecords" 
    
    if resumptionToken == "new"
      url = "#{baseUrl}&set=collectie_online&metadataPrefix=oai_dc"
    else
      url = "#{baseUrl}&resumptiontoken=#{resumptionToken}"

    https.get url, (res)->
      res.on 'data', (chunk) ->
        xmlString += chunk
      res.on 'end', ->
        xmlString = xmlString.toString('utf8')
        process.nextTick ->
          callback(xmlString)
    .on 'error', (e) ->
        console.log(e)

  _parseRecords = (resumptionToken, callback) ->
    _getRecords resumptionToken, (data) ->
      xmlRecords = new XmlDocument(data).childNamed('ListRecords').children
      newResumptionToken = xmlRecords.pop().val
      process.nextTick ->
        callback({records: xmlRecords, resumptionToken: newResumptionToken})

  _makeArtworks = (resumptionToken, callback) ->
    _parseRecords resumptionToken, (data) ->
      artworks = data.records.map (record)->
        metadata = record.childNamed('metadata').firstChild
        new Artwork(metadata)
      process.nextTick ->
        callback({records: artworks, resumptionToken: data.resumptionToken})

  _listRecords = (resumptionToken, callback) ->
    _makeArtworks resumptionToken, (data) ->
      process.nextTick ->
        callback(data)

  listRecords: _listRecords

module.exports = new RijksAPI()
