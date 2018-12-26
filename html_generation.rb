def images
  Dir["#{__dir__}/dl/*"].map { |i| i.sub(__dir__, '.') }
end

def generate_slideshow background_color: 'black', interval: 3000
  html_string = <<-HTML
    <!DOCTYPE html>
    <html lang="en">
      <head>
        <meta charset="UTF-8">
        <title>Fancy Slideshow</title>
        <link rel="stylesheet" href="reveal/css/reveal.css">
        <link rel="stylesheet" href="reveal/css/theme/black.css">
      </head>
      <body>
        <div class="reveal">
          <div class="slides">
            #{
              images.map do |x|
                "<section><img data-src=\"#{x}\"></section>"
              end.join("\n")
            }
          </div>
        </div>
        <script src="reveal/js/reveal.js"></script>
        <script>
          const initialSlideIndex = localStorage.getItem('initialSlideIndex')

          Reveal.initialize({
            transition: 'fade',
            autoSlide: '3000',
            slideNumber: true
          });

          Reveal.slide(initialSlideIndex)

          Reveal.addEventListener('slidechanged', function( event ) {
            localStorage.setItem('initialSlideIndex', event.indexh)
          });
        </script>
      </body>
    </html>
  HTML

  File.write 'slideshow.html', html_string.gsub(/^\s+/, '')
end

def generate_new_tab
  html_string = <<-HTML
    <!DOCTYPE html>
    <html lang="en">
    <head>
      <meta charset="UTF-8">
      <title>Randomized</title>
      <link href="favicon.ico" rel="icon" type="image/x-icon" />
      <style>
        .blur {
          position: absolute;
          top: 0;
          bottom: 0;
          left: 0;
          right: 0;
          background-color: black;
          filter: blur(10px);
        }
        img {
          position: absolute;
          top: 0;
          bottom: 0;
          left: 0;
          right: 0;
          max-width: 100%;
          max-height: 100%;
          margin: auto;
          overflow: auto;
          filter: blur(0px);
        }
      </style>
    </head>
    <body>
      <div class="blur">
      </div>
      <div class="not-blur">
        <img>
      </div>
      <script>
        const images = #{images}

        function setImage() {
          let imagesAlreadySeen = new Set(JSON.parse(localStorage.getItem('imagesAlreadySeen')))
          imagesAlreadySeen.size == images.length && imagesAlreadySeen.clear()

          let selectedImage

          do {
            selectedImage = images[Math.floor(Math.random() * images.length)]
          } while (imagesAlreadySeen.has(selectedImage))

          document.querySelector('.blur').style.background = `url(${selectedImage}) no-repeat center center fixed`
          const notBlur = document.querySelector('.not-blur img')
          notBlur.src = selectedImage
          notBlur.title = `Seen: ${imagesAlreadySeen.size} of ${images.length}`

          localStorage.setItem('imagesAlreadySeen', JSON.stringify([...imagesAlreadySeen.values(), selectedImage]))
        }

        setImage()
        document.addEventListener('click', setImage)
        setInterval(setImage, 3000)
      </script>
    </body>
    </html>
  HTML

  File.write 'randomized.html', html_string.gsub(/^\s+/, '')
end