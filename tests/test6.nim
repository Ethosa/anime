# author: Ethosa
# download video preview
import httpclient
import anime

var tr = TraceMoe()
var response = tr.search(
  "https://i.ytimg.com/vi/xNRn5o9lvJY/maxresdefault.jpg",
  is_url=true
)

tr.client.downloadFile(tr.video_preview_natural response, "image.mp4")
