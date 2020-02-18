# author: Ethosa
import httpclient
import asyncdispatch
from base64 import encode
from uri import encodeUrl
from streams import newFileStream, readAll
import json
export json


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


proc image_preview_url*(t: TraceMoeRef, response: JsonNode,
                        index=0, page="thumbnail.php"): string =
  ## Gets an image preview URL.
  ##
  ## Using this URL you can download image preview in the file.
  var r = response["docs"][index]
  result = MAIN_URL & page & "?anilist_id=" & $r["anilist_id"]
  result &= "&file=" & r["filename"].getStr
  result &= "&t=" & $r["at"] & "&token=" & r["tokenthumb"].getStr

proc image_preview_url*(t: ATraceMoeRef, response: JsonNode,
                        index=0, page="thumbnail.php"): Future[string] {.async.} =
  ## Gets an image preview URL.
  ##
  ## Using this URL you can download image preview in the file.
  var r = response["docs"][index]
  result = MAIN_URL & page & "?anilist_id=" & $r["anilist_id"]
  result &= "&file=" & r["filename"].getStr
  result &= "&t=" & $r["at"] & "&token=" & r["tokenthumb"].getStr


proc video_preview_url*(t: TraceMoeRef, response: JsonNode,
                        index=0): string =
  ## gets a video preview URL.
  ##
  ## Using this URL you can download video preview in the file.
  result = t.image_preview_url(response, index, "preview.php")

proc video_preview_url*(t: ATraceMoeRef, response: JsonNode,
                        index=0): Future[string] {.async.} =
  ## gets a video preview URL.
  ##
  ## Using this URL you can download video preview in the file.
  result = await t.image_preview_url(response, index, "preview.php")


proc video_preview_natural*(t: TraceMoeRef, response: JsonNode,
                            index=0): string =
  ## Gets natural video preview.
  ##
  ## Using this URL you can download natural video preview in the file.
  var r = response["docs"][index]
  result = MEDIA_URL & "video/" & $r["anilist_id"] & "/"
  result &= r["filename"].getStr & "?t=" & $r["at"]
  result &= "&token=" & r["tokenthumb"].getStr

proc video_preview_natural*(t: ATraceMoeRef, response: JsonNode,
                            index=0): Future[string] {.async.} =
  ## Gets natural video preview.
  ##
  ## Using this URL you can download natural video preview in the file.
  var r = response["docs"][index]
  result = MEDIA_URL & "video/" & $r["anilist_id"] & "/"
  result &= r["filename"].getStr & "?t=" & $r["at"]
  result &= "&token=" & r["tokenthumb"].getStr


proc search*(t: ATraceMoeRef, file: string,
             search_filter=0, is_url=false): Future[JsonNode] {.async.} =
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
