# author: Ethosa
# download image preview
import httpclient
import anime

var tr = TraceMoe()
var response = tr.search(
  "https://i.ytimg.com/vi/xNRn5o9lvJY/maxresdefault.jpg",
  is_url=true
)

tr.client.downloadFile(tr.image_preview_url response, "image.png")
