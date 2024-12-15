# Flickr Metadata Export for Windows

This is a fork of nickivanov's Flickr metadata tool, modified to work on Windows machines.  I only changed one line of code (191), but it's an important one, changing relative directory output to absolute directory output.

Here's how to run this on Windows

[From the Flickr Settings page](https://www.flickr.com/account/) click **Request my Flickr data**. In a day or two you
will receive an email with two links, one for the metadata archive and another for
the image archive.  Note that the metadata, which is what we're using here, is labeled as "Account Data" when downloading from Flickr.

1) Make sure you have [Python for Windows](https://www.python.org/downloads/windows/) installed.
   
3) In the file list above, locate map.json, run.bat, and meta2csv.py.  Right click on each and choose "Save Link As", then download them to the same directory as the files you got from Flickr.
   
5) Download [exiftool](https://exiftool.org/), extract the zip and copy exiftool(-k).exe to the same directory as the other three files.  **Rename** the file to exiftool.exe, removing (-k), just to make everything easier.
6) Extract the zip files you got from Flickr.  I'd recommend using [WinRar](https://www.win-rar.com/), which will allow you to simply highlight all your data-download zip files at once, right click, and by choosing "Extract to data-download-1", extract all the files to the same folder.
7) Make sure the metadata is in a folder called "metadata", and your photos are all together in a folder called "data-download-1"
8) Double-click run.bat.  This may take some time, but will generate you a CSV file called flickr.csv
9) Put flickr.csv inside your data-download-1 folder with your images
10) Click the address bar in Windows Explorer (where your current path is displayed), type cmd, press enter
11) Run the following code

```
exiftool.exe -overwrite_original -csv=flickr.csv -e jpg -e png .
```

If you prefer, you can omit the -overwrite_original flag, and backups will be created, named something like `photoname.jpg_original`

If you chose not to rename exiftool(-k).exe, make sure that is reflected in your command.

***

To put your photos into folders with the names of their original albums, run this command
```
exiftool -"Directory<Album" %f.%e -e jpg -e png .
```

Note that the double quotes are modified from the original readme's single quotes, which Windows cmd does not like.

***

Using the original readme below, you can adjust parameters, and do other things.  Just remember that step 2 below is handled by run.bat, no need to put those codes into cmd.  In fact, they won't work on cmd, which is why run.bat is necessary.

# Original Readme:

Flickr allows you to download your photos and metadata. Unfortunatley, the metadata
is not stored along with the images as EXIF, XMP, IPTC or other standard format; instead
it will be downloaded as a series of JSON files, one per image.

This tool allows you to convert all these JSON files into a single CSV file according
to the supplied mapping. The CSV file can then be used by [ExifTool](https://www.sno.phy.queensu.ca/~phil/exiftool/) to update image EXIF/XMP/whatever metadata.

From the Flickr **Settings** page click **Request my Flickr data**. In a day or two you
will receive an email with two links, one for the metadata archive and another for
the image archive.

Extract the two archives, which will create two directories, one containing metadata
and another containing images.

The process might look like this:

1. Update tag mapping (optional).

You can update the mapping of Flickr metadata properties to EXIF/XMP/IPTC image 
tags if you want. A sample mapping file, `map.json` is provided. Its `input_tags`
properties contains a JSON array of strings that correspond to the Flickr metadata
properties, and the `output_tags` array contains the image tags to be set. Output 
tags can contain group name, e.g. `"EXIF:Make"`, following the ExifTool tag syntax.

Example input tag specifications and JSON they match:

- `"name"`
   Matches `{"name": "foobar"}`

- `"exif.Make"`
   Matches `{"exif": {"Make": "samsung"}}`

- `"albums[0].name"`
   Matches the `name` property of the first `albums` element, that is, will return
   `"album1"` given the following input: 
   `{"albums": [{"name": "album1"}, {"name": "album2"}]}

- `"tags[*].tag"`
   Matches the `tag` property of all `tags` element then joins them in a single
   string, separated by spaces. This will return `"foo bar"` given the following input: 
   `{"tags": [{"tag": "foo"}, {"tag": "bar"}]}

- `"exif.Make=foobar"`
   Supplies the default value for `"exif.Make"`, that is, will return `"foobar"`
   if there is no `Make` in `exif` or if there's no `exif`.


2. Extract Flickr metadata.

Flickr metadata does not follow any standard image metadata format, and I'm 
using Phil Harvey's [ExifTool](https://www.sno.phy.queensu.ca/~phil/exiftool/) to
update image files. As the first step I convert Flickr metadata into a format
ExifTool can consume -- a CSV file. This is where the Python program comes in.

    PYTHONIOENCODING=utf-8 \
    IMG_DIR=/path/to/image/files TAG_MAP=./map.json \
    ./meta2csv.py "/path/to/metadata/files/photo_*json" \
    >/path/to/image/files/meta.csv

Note that you need to put the metadata file pattern in quotes to avoid the shell 
globbing.

For example:

```
PYTHONIOENCODING=utf-8 \
IMG_DIR=/Volumes/media/downloads/data-download-1 TAG_MAP=./map.json \
./meta2csv.py "/Volumes/media/downloads/flickr-export/meta/photo_*json" \
>/Volumes/media/downloads/data-download-1/meta.csv
```

Two environment variables that control the program behaviour are:

- `IMG_DIR`: Indicates the directory path where the actual image files have been
  extracted from the Flickr export. If not specified the current directory is assumed.

- `TAG_MAP`: Points to the customized tag map file. If not specified, the default
  mapping hard-coded in the program is used.

Set `PYTHONIOENCODING` if any of your Flickr metadata -- image titles, descriptions,
tags etc. -- contain non-ASCII characters, otherwise Python stdout redirection 
will fail to print such characters.

3. Update image metadata with ExifTool.

Once the Flickr metadata is saved in a CSV file that can be understood by ExifTool,
you can update the image files. The command below will read the CSV file created
in the previous step, update each matching file's metadata with tags from that 
CSV file, and copy the file into a directory named after the Flickr album it belongs to.

It should run from the directory where image files have been extracted. 

    /path/to/exiftool -csv=<CSV file name> -e jpg -e png .

4. Separate images into albums.

Optionally you can now sort your images into directories based on the Flickr albums 
they were in. Note that if any of your images belongs to multiple albums on Flickr,
only the first album will be used to set the image metadata in step 2 above.

    /path/to/exiftool -"Directory<Album" -o %f.%e -e jpg -e png .

Note that this command will create a new subdirectory for each Flickr album; make sure 
that you run it from the directory where you want these album subdirectories to 
be created.
