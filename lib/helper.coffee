crypto = require "crypto"
qs = require "querystring"

buildSig = (params, secret) ->
  sortedNames = Object.keys(params).sort (a, b) -> a.localeCompare(b)
  sortedValues = []

  for name in sortedNames
    sortedValues.push "#{name}=#{params[name]}"

  reqString = sortedValues.join ""
  reqString += secret

  md5 = crypto.createHash "md5"

  md5.update reqString

  return md5.digest "hex"

module.exports = (opts) ->
  if !opts or !opts.apiKey or !opts.apiSecret
    throw new Error("missing apiKey or apiSecret!")

  key = opts.apiKey
  secret = opts.apiSecret

  # default to 5 mins
  opts.expires ||= 1200

  return (mixUrl, params) ->
    params.expire = Math.floor(Date.now()/1000) + opts.expires
    params.api_key = key

    for pn, val of params
      if Array.isArray val
        params[pn] = JSON.stringify val

    params["sig"] = buildSig params, secret

    return "#{mixUrl}?#{qs.stringify(params)}"
