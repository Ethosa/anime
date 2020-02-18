# author: Ethosa
import httpclient
import asyncdispatch
from base64 import encode
import json
export json
import uri
import streams


const
  MAIN_URL: string = "https://trace.moe/"
  MEDIA_URL: string = "https://media.trace.moe/"
  ME_URL: string = "https://trace.moe/api/me"
  SEARCH_URL: string = "https://trace.moe/api/search"


type
  TraceMoeObj[HType] = ref object
    access_token: string
    client*: HType

  TraceMoeRef* = TraceMoeObj[HttpClient]
  ATraceMoeRef* = TraceMoeObj[AsyncHttpClient]


proc TraceMoe*(access_token=""): TraceMoeRef =
  ## Creates a new TraceMoeRef object.
  ##
  ## Arguments:
  ## -   ``access_token`` -- access token, if available.
  TraceMoeRef(access_token: access_token, client: newHttpClient())

proc ATraceMoe*(access_token=""): ATraceMoeRef =
  ## Creates a new ATraceMoeRef object.
  ##
  ## Arguments:
  ## -   ``access_token`` -- access token, if available.
  ATraceMoeRef(access_token: access_token, client: newAsyncHttpClient())


proc me*(t: ATraceMoeRef): Future[JsonNode] {. async .} =
  ## Gets limit info
  var url = ME_URL
  url &= "?token=" & t.access_token
  result = parseJson await t.client.getContent(url)

proc me*(t: TraceMoeRef): JsonNode =
  ## Gets limit info
  var url = ME_URL
  url &= "?token=" & t.access_token
  result = parseJson t.client.getContent(url)


proc search*(t: ATraceMoeRef, file: string,
             search_filter=0, is_url=false): JsonNode =
  ## Searchs anime by image or image URL.
  ##
  ## Arguments:
  ## -   ``file`` -- file path or URL.
  var url = SEARCH_URL
  url &= "?token=" & t.access_token

  if is_url:
    result = parseJson await t.client.getContent(
      url & "&url=" & encodeUrl file)
  else:
    var 
      mpdata = newMultipartData()
      strm = newFileStream(file, fmRead)
      encoded = encode strm.readAll
    strm.close
    mpdata["image"] = encoded
    mpdata["search_filter"] = $search_filter
    result = parseJson await t.client.postContent(url, multipart=mpdata)

proc search*(t: TraceMoeRef, file: string,
             search_filter=0, is_url=false): JsonNode =
  ## Searchs anime by image or image URL.
  ##
  ## Arguments:
  ## -   ``file`` -- file path or URL.
  var url = SEARCH_URL
  url &= "?token=" & t.access_token

  if is_url:
    result = parseJson t.client.getContent(
      url & "&url=" & encodeUrl file)
  else:
    var
      mpdata = newMultipartData()
      strm = newFileStream(file, fmRead)
      encoded = encode strm.readAll
    strm.close
    mpdata["image"] = encoded
    mpdata["search_filter"] = $search_filter
    result = parseJson t.client.postContent(url, multipart=mpdata)
