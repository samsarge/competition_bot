To teach security principles about captchas

* `brew install selenium-webdriver`
* `brew install chromedriver`
typically you'll get some error saying the webdrivers aren't installed, when they are, to solve this just make sure
your laptop has permission; usually it's untrusted.
* `xattr -d com.apple.quarantine /usr/local/bin/chromedriver`
* `bundle`

Not focusing on the obvious improvements
* Sleeps can be improved by waiting for text to appear
* Create storage.yml if it doesnt yet exist
* Make the code nice etc
