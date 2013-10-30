api = require('./index')
fs = require('fs')

RijksHarvester =->
  _harvester = (resumptionToken, callback) ->
    if resumptionToken
      api.listRecords resumptionToken, (data) ->
        for record in data.records
          json = JSON.stringify(record)
          fs.appendFile 'collection.json', json
          fs.appendFile 'collection.json', "\n"
        _harvester(data.resumptionToken, callback)
    else
      console.log("archive has been harvested")

  {
    harvester: _harvester
  }

module.exports = new RijksHarvester()
