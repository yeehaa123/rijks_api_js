expect = require('chai').expect
api    = require('../index')

describe 'RijksAPI', ->

  resumptionToken = "fHxjb2xsZWN0aWVfb25saW5lfG9haV9kY3xjb2xsZWN0aW9uLjk0fDExNw=="

  describe 'listRecords without resumption token', ->

    it 'calls the module', (done)->
      api.listRecords "new", (data) ->
        expect(data.records).length.to.be(10)
        done()

    it 'has records with the right properties', (done) ->
      api.listRecords "new", (data) ->
        keys = ['url', 'language', 'date', 'description', 'creator', 'type', 'title']
        expect(data.records[9]).to.have.keys(keys)
        done()

    it 'has a resumption token', (done)->
      api.listRecords "new", (data)->
        expect(data.resumptionToken).to.equal(resumptionToken)
        done()

  describe 'listRecords with resumption token', ->

    it 'returns 10 records', (done)->
      api.listRecords resumptionToken, (data) ->
        expect(data.records).length.to.be(10)
        done()

    it 'has records with the right properties', (done) ->
      api.listRecords resumptionToken, (data) ->
        keys = ['url', 'language', 'date', 'description', 'creator', 'type', 'title']
        expect(data.records[9]).to.have.keys(keys)
        done()

    it 'has a new resumption token', (done)->
      newResumptionToken = "fHxjb2xsZWN0aWVfb25saW5lfG9haV9kY3xjb2xsZWN0aW9uLjQ2NXwxMTc="
      api.listRecords resumptionToken, (data)->
        expect(data.resumptionToken).to.equal(newResumptionToken)
        done()
