# Browsernizer

Want friendly "please upgrade your browser" page? This gem is for you.

You can redirect your visitors to any page you like (static or dynamic).
Just specify `config.location` option in initializer file.


## Installation

Add following line to your `Gemfile`:

    gem 'browsernizer'

Hook it up:

    rails generate browsernizer:install

Configure browser support in `config/initializers/browsernizer.rb` file.


## Configuration

Initializer file is pretty self explanatory. Here is the default one:

    Rails.application.config.middleware.use Browsernizer::Router do |config|
      config.supported "Internet Explorer", "9"
      config.supported "Firefox", "4"
      config.supported "Opera", "11.1"
      config.supported "Chrome", "7"
      config.location  "/browser.html"
    end

It states that IE9+, FF4+, Opera 11.1+ and Chrome 7+ are supported.
Non listed browsers will be considered to be supported regardless of their version.
Unsupported browsers will be redirected to `/browser.html` page.

If you wish to completely prevent some browsers from accessing website
(regardless of their version), for now you can specify some really high
version number (e.g. "666").


## Browsers

You should specify browser name as a string. Here are the available options:

* Chrome
* Firefox
* Safari
* Opera
* Internet Explorer

And some less popular:

* Android
* webOS
* BlackBerry
* Symbian
* Camino
* Iceweasel
* Seamonkey

Browser detection is done using [useragent gem](https://github.com/josh/useragent).



## Credits and License

Developed by Milovan Zogovic.

I don't believe in licenses and other legal crap.
Do whatever you want with this :)
