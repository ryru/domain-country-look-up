# Domain Country Look-up

Simple bash script that eats a file full of domains and prints out the country code (ISO 3166) of every entry based on a [geo ip database](http://ip-api.com/) and a short summary over all domains/servers.

This script is heavily inspired by [NDG-Lieblingswebsite](https://github.com/mritzmann/NDG-Lieblingswebsite) by [@RitzmannMarkus](https://twitter.com/RitzmannMarkus). It also uses [JSON.sh](https://github.com/dominictarr/JSON.sh) by [@dominictarr](http://twitter.com/dominictarr) for parsing the json data.

## Usage
```
$ ./domain-country-look-up.sh res/sample.txt 

Processing res/sample.txt (3 entries)
  1.  US  google.ch
  2.  US  youtube.com
  3.  US  facebook.com

3 domains (100%) are not hosted at Schweiz.
0 lookups failed
```

Content of sample.txt
```
$ cat res/sample.txt 
google.ch
youtube.com
facebook.com
```

## License

This software is available under the following licenses: BSD 3-Clause license (see License).
It also contains 3rd party libraries under other licenses (see LICENSE-3RD-PARTY.txt).


