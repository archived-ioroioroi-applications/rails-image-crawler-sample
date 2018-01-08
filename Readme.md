# Img Picker

RMagickを使って何かやりたかった...

## Config

## Issues
- <解決済み> 拾ったURLが "/.../..."のようなディレクトリパス形式だとルーティングできず死ぬ
  * A: そのサイトのFQDNをくっつけて、https://---/.../.../ とする

- 画像がbackground{url:...}みたいな感じでimgタグ以外の場合がある
  ex.) <div class="related-thumb" style="background-image: url('https://cdn.image.st-hatena.com/image/square/59f747346f438d8ebba86cf2f90a16e4506f2e83/backend=imagemagick;height=120;version=1;width=120/https%3A%2F%2Fcdn-ak.f.st-hatena.com%2Fimages%2Ffotolife%2Ff%2Ffoodcreative%2F20170630%2F20170630121350.jpg');"></div>
  * A: imgタグで取ってくるのではなくpng, jpgなど画像拡張子をキーワードに正規表現で取得してくる？

- URLが不正だとopenuriの処理のときに死ぬ
  * A:

- スクレイピングするopenuri、nokogiriの処理のときに（多分アクセス回数のせいで）対象サイトから弾かれる場合がある
  * A:スクレイピングの前にsleepを入れるか、リトライ処理を実装するか

## UseCase
